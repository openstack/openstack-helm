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
  # Selecting containers with "ceph-osd-default" name and
  # counting them based on "ready" field.
  count_pods=".items | map(.status.containerStatuses | .[] | \
              select(.name==\"ceph-osd-default\")) | \
              group_by(.ready) | map({(.[0].ready | tostring): length}) | .[]"
  min_osds="add | if .true >= (.false + .true)*${REQUIRED_PERCENT_OF_OSDS}/100 \
           then \"pass\" else \"fail\" end"
  while true; do
      # Leaving while loop if minimum amount of OSDs are ready.
      # It allows to proceed even if some OSDs are not ready
      # or in "CrashLoopBackOff" state
      state=$(kubectl get pods --namespace="${1}" -l component=osd -o json | jq "${count_pods}")
      osd_state=$(jq -s "${min_osds}" <<< "${state}")
      if [[ "${osd_state}" == \"pass\" ]]; then
        break
      fi
      sleep 5

      if [ $(date -u +%s) -gt $end ] ; then
          echo -e "Containers failed to start after $timeout seconds\n"
          kubectl get pods --namespace "${1}" -o wide -l component=osd
          exit 1
      fi
  done
}

function check_ds() {
 for ds in `kubectl get ds --namespace=$CEPH_NAMESPACE -l component=osd --no-headers=true|awk '{print $1}'`
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
       echo "few pods under daemonset  $ds are  not yet ready"
       exit
     else
       echo "all pods ubder deamonset $ds are ready"
     fi
   else
     echo "this are no osds under daemonset $ds"
   fi
 done
}

function wait_for_pgs () {
  echo "#### Start: Checking pgs ####"

  pgs_ready=0
  pgs_inactive=0
  query='map({state: .state}) | group_by(.state) | map({state: .[0].state, count: length}) | .[] | select(.state | contains("active") | not)'

  if [[ $(ceph mon versions | awk '/version/{print $3}' | cut -d. -f1) -ge 14 ]]; then
    query=".pg_stats | ${query}"
  fi

  # Loop until all pgs are active
  while [[ $pgs_ready -lt 3 ]]; do
    pgs_state=$(ceph --cluster ${CLUSTER} pg ls -f json | jq -c "${query}")
    if [[ $(jq -c '. | select(.state | contains("peering") | not)' <<< "${pgs_state}") ]]; then
      if [[ $pgs_inactive -gt 200 ]]; then
        # If inactive PGs aren't peering after ~10 minutes, fail
        echo "Failure, found inactive PGs that aren't peering"
        exit 1
      fi
      (( pgs_inactive+=1 ))
    else
      pgs_inactive=0
    fi
    if [[ "${pgs_state}" ]]; then
      pgs_ready=0
    else
      (( pgs_ready+=1 ))
    fi
    sleep 3
  done
}

function wait_for_degraded_objects () {
  echo "#### Start: Checking for degraded objects ####"

  # Loop until no degraded objects
    while [[ ! -z "`ceph --cluster ${CLUSTER} -s | grep 'degraded'`" ]]
    do
      sleep 3
      ceph -s
    done
}

function wait_for_degraded_and_misplaced_objects () {
  echo "#### Start: Checking for degraded and misplaced objects ####"

  # Loop until no degraded or misplaced objects
    while [[ ! -z "`ceph --cluster ${CLUSTER} -s | grep 'degraded\|misplaced'`" ]]
    do
      sleep 3
      ceph -s
    done
}

function restart_by_rack() {

  racks=`ceph osd tree | awk '/rack/{print $4}'`
  echo "Racks under ceph cluster are: $racks"
  for rack in $racks
  do
     hosts_in_rack=(`ceph osd tree | sed -n "/rack $rack/,/rack/p" | awk '/host/{print $4}' | tr '\n' ' '|sed 's/ *$//g'`)
     echo "hosts under rack "$rack" are: ${hosts_in_rack[@]}"
     echo "hosts count under $rack are: ${#hosts_in_rack[@]}"
     for host in ${hosts_in_rack[@]}
     do
       echo "host is : $host"
       if [[ ! -z "$host" ]]; then
         pods_on_host=`kubectl get po -n $CEPH_NAMESPACE -l component=osd -o wide |grep $host|awk '{print $1}'`
         echo "Restartig  the pods under host $host"
         kubectl delete  po -n $CEPH_NAMESPACE $pods_on_host
       fi
     done
     echo "waiting for the pods under rack $rack from restart"
     # The pods will not be ready in first 60 seconds. Thus we can reduce
     # amount of queries to kubernetes.
     sleep 60
     # Degraded objects won't recover with noout set unless pods come back and
     # PGs become healthy, so simply wait for 0 degraded objects
     wait_for_degraded_objects
     ceph -s
  done
}

if [[ "$DISRUPTIVE_OSD_RESTART" != "true" ]]; then
  wait_for_pods $CEPH_NAMESPACE
fi

require_upgrade=0
max_release=0

for ds in `kubectl get ds --namespace=$CEPH_NAMESPACE -l component=osd --no-headers=true|awk '{print $1}'`
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

# If flags are set that will prevent recovery, don't restart OSDs
ceph -s | grep "noup\|noin\|nobackfill\|norebalance\|norecover" > /dev/null
if [[ $? -ne 0 ]]; then
  if [[ "$UNCONDITIONAL_OSD_RESTART" == "true" ]] || [[ $max_release -gt 1  ]]; then
    if [[ "$UNCONDITIONAL_OSD_RESTART" == "true" ]] || [[  $require_upgrade -gt 0 ]]; then
      if [[ "$DISRUPTIVE_OSD_RESTART" == "true" ]]; then
        echo "restarting all osds simultaneously"
        kubectl -n $CEPH_NAMESPACE delete pod -l component=osd
        sleep 60
        echo "waiting for pgs to become active and for degraded objects to recover"
        wait_for_pgs
        wait_for_degraded_objects
        ceph -s
      else
        echo "waiting for inactive pgs and degraded objects before upgrade"
        wait_for_pgs
        wait_for_degraded_and_misplaced_objects
        ceph -s
        ceph osd "set" noout
        echo "lets restart the osds rack by rack"
        restart_by_rack
        ceph osd "unset" noout
      fi
    fi

    #lets check all the ceph-osd daemonsets
    echo "checking DS"
    check_ds
  else
    echo "No revisions found for upgrade"
  fi
else
  echo "Skipping OSD restarts because flags are set that would prevent recovery"
fi
