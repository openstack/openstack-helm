#!/bin/bash

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

export LC_ALL=C

: "${ADMIN_KEYRING:=/etc/ceph/${CLUSTER}.client.admin.keyring}"

if [[ ! -f /etc/ceph/${CLUSTER}.conf ]]; then
  echo "ERROR- /etc/ceph/${CLUSTER}.conf must exist; get it from your existing mon"
  exit 1
fi

if [[ ! -f ${ADMIN_KEYRING} ]]; then
   echo "ERROR- ${ADMIN_KEYRING} must exist; get it from your existing mon"
   exit 1
fi

ceph --cluster ${CLUSTER}  -s
function wait_for_pods() {
  timeout=${2:-1800}
  end=$(date -ud "${timeout} seconds" +%s)
  # Selecting containers with "ceph-mon" name and
  # counting them based on "ready" field.
  count_pods=".items | map(.status.containerStatuses | .[] | \
              select(.name==\"ceph-mon\")) | \
              group_by(.ready) | map({(.[0].ready | tostring): length}) | .[]"
  min_mons="add | if .true >= (.false + .true) \
           then \"pass\" else \"fail\" end"
  while true; do
      # Leave while loop if all mons are ready.
      state=$(kubectl get pods --namespace="${1}" -l component=mon -o json | jq "${count_pods}")
      mon_state=$(jq -s "${min_mons}" <<< "${state}")
      if [[ "${mon_state}" == \"pass\" ]]; then
        break
      fi
      sleep 5

      if [ $(date -u +%s) -gt $end ] ; then
          echo -e "Containers failed to start after $timeout seconds\n"
          kubectl get pods --namespace "${1}" -o wide -l component=mon
          exit 1
      fi
  done
}

function check_ds() {
 for ds in `kubectl get ds --namespace=$CEPH_NAMESPACE -l component=mon --no-headers=true|awk '{print $1}'`
 do
   ds_query=`kubectl get ds -n $CEPH_NAMESPACE $ds -o json|jq -r .status`
   if echo $ds_query |grep -i "numberAvailable" ;then
     currentNumberScheduled=`echo $ds_query|jq -r .currentNumberScheduled`
     desiredNumberScheduled=`echo $ds_query|jq -r .desiredNumberScheduled`
     numberAvailable=`echo $ds_query|jq -r .numberAvailable`
     numberReady=`echo $ds_query|jq -r .numberReady`
     updatedNumberScheduled=`echo $ds_query|jq -r .updatedNumberScheduled`
     ds_check=`echo "$currentNumberScheduled $desiredNumberScheduled $numberAvailable $numberReady $updatedNumberScheduled"| \
       tr ' ' '\n'|sort -u|wc -l`
     if [ $ds_check != 1 ]; then
       echo "Some pods in daemonset $ds are not ready"
       exit
     else
       echo "All pods in deamonset $ds are ready"
     fi
   else
     echo "There are no mons under daemonset $ds"
   fi
 done
}

function restart_mons() {
  mon_pods=`kubectl get po -n $CEPH_NAMESPACE -l component=mon --no-headers | awk '{print $1}'`

  for pod in ${mon_pods}
  do
    if [[ -n "$pod" ]]; then
      echo "Restarting pod $pod"
      kubectl delete pod -n $CEPH_NAMESPACE $pod
    fi
    echo "Waiting for the pod $pod to restart"
    # The pod will not be ready in first 60 seconds. Thus we can reduce
    # amount of queries to kubernetes.
    sleep 60
    wait_for_pods
    ceph -s
  done
}

wait_for_pods $CEPH_NAMESPACE

require_upgrade=0
max_release=0

for ds in `kubectl get ds --namespace=$CEPH_NAMESPACE -l component=mon --no-headers=true|awk '{print $1}'`
do
  updatedNumberScheduled=`kubectl get ds -n $CEPH_NAMESPACE $ds -o json|jq -r .status.updatedNumberScheduled`
  desiredNumberScheduled=`kubectl get ds -n $CEPH_NAMESPACE $ds -o json|jq -r .status.desiredNumberScheduled`
  if [[ $updatedNumberScheduled != $desiredNumberScheduled ]]; then
    if kubectl get ds -n $CEPH_NAMESPACE  $ds -o json|jq -r .status|grep -i "numberAvailable" ;then
      require_upgrade=$((require_upgrade+1))
      _release=`kubectl get ds -n $CEPH_NAMESPACE $ds  -o json|jq -r .status.observedGeneration`
      max_release=$(( max_release > _release ? max_release : _release ))
    fi
  fi
done

echo "Latest revision of the helm chart(s) is : $max_release"

if [[ "$UNCONDITIONAL_MON_RESTART" == "true" ]] || [[ $max_release -gt 1  ]]; then
  if [[ "$UNCONDITIONAL_MON_RESTART" == "true" ]] || [[  $require_upgrade -gt 0 ]]; then
    echo "Restart ceph-mon pods one at a time to prevent disruption"
    restart_mons
  fi

  # Check all the ceph-mon daemonsets
  echo "checking DS"
  check_ds
else
  echo "No revisions found for upgrade"
fi
