#!/bin/bash

set -x

{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}


COMMAND="${@:-rotate_job}"

namespace={{ .Release.Namespace }}
minDaysToExpiry={{ .Values.jobs.rotate.max_days_to_expiry }}

rotateBefore=$(($(date +%s) + (86400*$minDaysToExpiry)))

function rotate_and_get_certs_list(){
    # Rotate the certificates if the expiry date of certificates is within the
    # max_days_to_expiry days

    # List of secret and certificates rotated
    local -n secRotated=$1
    deleteAllSecrets=$2
    certRotated=()

    for certificate in $(kubectl get certificates -n ${namespace} --no-headers | awk '{ print $1 }')
    do
        certInfo=($(kubectl get certificate -n ${namespace} ${certificate} -o json | jq -r '.spec["secretName"],.status["notAfter"]'))
        secretName=${certInfo[0]}
        notAfter=$(date -d"${certInfo[1]}" '+%s')
        deleteSecret=false
        if ${deleteAllSecrets} || [ ${rotateBefore} -gt ${notAfter} ]
        then
            # Rotate the certificates/secrets and add to list.
            echo "Deleting secret: ${secretName}"
            kubectl delete secret -n ${namespace} $secretName
            secRotated+=(${secretName})
            certRotated+=(${certificate})
        fi
    done

    # Ensure certificates are re-issued
    if [ ! -z ${certRotated} ]
    then
        for cert in ${certRotated[@]}
        do
            counter=0
            retried=false
            while [ "$(kubectl get certificate -n ${namespace} ${cert} -o json | jq -r '.status.conditions[].status')" != "True" ]
            do
                # Wait for secret to become ready. Wait for 300 seconds maximum. Sleep for 10 seconds
                if [ ${counter} -ge 30 ]
                then
                    # Seems certificate is not in ready state yet, may be there is an issue be renewing the certificate.
                    # Try one more time before failing it. The name of the secret would be different at this time (when in
                    # process of issuing)
                    priSeckeyName=$(kubectl get certificate -n ${namespace} ${cert} -o json | jq -r '.status["nextPrivateKeySecretName"]')

                    if [ ${retried} = false ] && [ ! -z ${priSeckeyName} ]
                    then
                        echo "Deleting interim failed secret ${priSeckeyName} in namespace ${namespace}"
                        kubectl delete secret -n ${namespace} ${priSeckeyName}
                        retried=true
                        counter=0
                    else
                        # Tried 2 times to renew the certificate, something is not right. Log error and
                        # continue to check the status of next certificate. Once the status of all the
                        # certificates has been checked, the pods need to be restarted so that the successfully
                        # renewed certificates can be deployed.
                        echo "ERROR: Rotated certificate  ${cert} in ${namespace} is not ready."
                        break
                    fi
                fi
                echo "Rotated certificate ${cert} in ${namespace} is not ready yet ... waiting"
                counter=$((counter+1))
                sleep 10
            done

        done
    fi
}

function get_cert_list_rotated_by_cert_manager_rotate(){

    local -n secRotated=$1

    # Get the time when the last cron job was run successfully
    lastCronTime=$(kubectl get jobs -n ${namespace} --no-headers -l application=cert-manager,component=cert-rotate -o json | jq -r '.items[] | select(.status.succeeded != null) | .status.completionTime' | sort -r | head -n 1)

    if [ ! -z ${lastCronTime} ]
    then
        lastCronTimeSec=$(date -d"${lastCronTime}" '+%s')

        for certificate in $(kubectl get certificates -n ${namespace} --no-headers | awk '{ print $1 }')
        do
            certInfo=($(kubectl get certificate -n ${namespace} ${certificate} -o json | jq -r '.spec["secretName"],.status["notBefore"]'))
            secretName=${certInfo[0]}
            notBefore=$(date -d"${certInfo[1]}" '+%s')

            # if the certificate was created after last cronjob run means it was
            # rotated by the cert-manager, add to the list.
            if [[ ${notBefore} -gt ${lastCronTimeSec} ]]
            then
                secRotated+=(${secretName})
            fi
        done
    fi
}

function restart_the_pods(){

    local -n secRotated=$1

    if [ -z ${secRotated} ]
    then
        echo "All certificates are still valid in ${namespace} namespace. No pod needs restart"
        exit 0
    fi

    # Restart the pods using kubernetes rollout restart. This will restarts the applications
    # with zero downtime.
    for kind in statefulset deployment daemonset
    do
        # Need to find which kinds mounts the secret that has been rotated. To do this
        # for a kind (statefulset, deployment, or daemonset)
        # - get the name of the kind (which will index 1 = idx=0 of the output)
        # - get the names of the secrets mounted on this kind (which will be index 2 = idx+1)
        # - find if tls.crt was mounted to the container: get the subpaths of volumeMount in
        #   the container and grep for tls.crt. (This will be index 3 = idx+2)
        # - or, find if tls.crt was mounted to the initContainer (This will be index 4 = idx+3)

        resource=($(kubectl get ${kind} -n ${namespace} -o custom-columns='NAME:.metadata.name,SECRETS:.spec.template.spec.volumes[*].secret.secretName,TLS-CONTAINER:.spec.template.spec.containers[*].volumeMounts[*].subPath,TLS-INIT:.spec.template.spec.initContainers[*].volumeMounts[*].subPath' --no-headers | grep tls.crt || true))

        idx=0
        while [[ $idx -lt ${#resource[@]} ]]
        do
            # Name of the kind
            resourceName=${resource[$idx]}

            # List of secrets mounted to this kind
            resourceSecrets=${resource[$idx+1]}

            # For each secret mounted to this kind, check if it was rotated (present in
            # the list secRotated) and if it was, then trigger rolling restart for this kind.
            for secret in ${resourceSecrets//,/ }
            do
                if [[ "${secRotated[@]}" =~ "${secret}" ]]
                then
                    echo "Restarting ${kind} ${resourceName} in ${namespace} namespace."
                    kubectl rollout restart -n ${namespace} ${kind} ${resourceName}
                    break
                fi
            done

            # Since we have 4 custom columns in the output, every 5th index will be start of new tuple.
            # Jump to the next tuple.
            idx=$((idx+4))
        done
    done
}

function rotate_cron(){
    # Rotate cronjob invoked this script.
    # 1. If the expiry date of certificates is within the max_days_to_expiry days
    #    the rotate the certificates and restart the pods
    # 2. Else if the certificates were rotated by cert-manager, then restart
    #    the pods.

    secretsRotated=()
    deleteAllSecrets=false

    rotate_and_get_certs_list secretsRotated $deleteAllSecrets

    if [ ! -z ${secretsRotated} ]
    then
        # Certs rotated, restart pods
        restart_the_pods secretsRotated
    else
        # Check if the certificates were rotated by the cert-manager and get the list of
        # rotated certificates so that the corresponding pods can be restarted
        get_cert_list_rotated_by_cert_manager_rotate secretsRotated
        if [ ! -z ${secretsRotated} ]
        then
            restart_the_pods secretsRotated
        else
            echo "All certificates are still valid in ${namespace} namespace"
        fi
    fi
}

function rotate_job(){
    # Rotate job invoked this script.
    # 1. Rotate all certificates by deleting the secrets and restart the pods

    secretsRotated=()
    deleteAllSecrets=true

    rotate_and_get_certs_list secretsRotated $deleteAllSecrets

    if [ ! -z ${secretsRotated} ]
    then
        # Certs rotated, restart pods
        restart_the_pods secretsRotated
    else
        echo "All certificates are still valid in ${namespace} namespace"
    fi
}

$COMMAND
exit 0
