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
  end=$(date +%s)
  timeout=${2:-1800}
  end=$((end + timeout))
  while true; do
      kubectl get pods --namespace=$1 -l component=osd -o json | jq -r \
          '.items[].status.phase' | grep Pending > /dev/null && \
          PENDING="True" || PENDING="False"
      query='.items[]|select(.status.phase=="Running")'
      pod_query="$query|.status.containerStatuses[].ready"
      init_query="$query|.status.initContainerStatuses[].ready"
      kubectl get pods --namespace=$1 -l component=osd -o json | jq -r "$pod_query" | \
          grep false > /dev/null && READY="False" || READY="True"
      kubectl get pods --namespace=$1 -o json | jq -r "$init_query" | \
          grep false > /dev/null && INIT_READY="False" || INIT_READY="True"
      kubectl get pods --namespace=$1  | grep -E 'Terminating|PodInitializing' \
          > /dev/null && UNKNOWN="True" || UNKNOWN="False"
      [ $INIT_READY == "True" -a $UNKNOWN == "False" -a $PENDING == "False" -a $READY == "True" ] && \
          break || true
      sleep 5
      now=$(date +%s)
      if [ $now -gt $end ] ; then
          echo "Containers failed to start after $timeout seconds"
          echo
          kubectl get pods --namespace $1 -o wide
          echo
          if [ $PENDING == "True" ] ; then
              echo "Some pods are in pending state:"
              kubectl get pods --field-selector=status.phase=Pending -n $1 -o wide
          fi
          [ $READY == "False" ] && echo "Some pods are not ready"
          exit -1
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

function wait_for_inactive_pgs () {
  echo "#### Start: Checking for inactive pgs ####"

  # Loop until all pgs are active
  if [[ $(ceph tell mon.* version | egrep -q "nautilus"; echo $?) -eq 0 ]]; then
    while [[ `ceph --cluster ${CLUSTER} pg ls | tail -n +2 | head -n -2 | grep -v "active+"` ]]
    do
      sleep 3
      ceph -s
    done
  else
    while [[ `ceph --cluster ${CLUSTER} pg ls | tail -n +2 | grep -v "active+"` ]]
    do
      sleep 3
      ceph -s
    done
  fi
}

function wait_for_degraded_objects () {
  echo "#### Start: Checking for degraded objects ####"

  # Loop until no degraded objects
    while [[ ! -z "`ceph --cluster ${CLUSTER} -s | grep degraded`" ]]
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
     wait_for_pods $CEPH_NAMESPACE
     echo "waiting for inactive pgs after osds restarted from rack $rack"
     wait_for_inactive_pgs
     wait_for_degraded_objects
     ceph -s
  done
}

require_upgrade=0


for ds in `kubectl get ds --namespace=$CEPH_NAMESPACE -l component=osd --no-headers=true|awk '{print $1}'`
do
  updatedNumberScheduled=`kubectl get ds -n $CEPH_NAMESPACE $ds -o json|jq -r .status.updatedNumberScheduled`
  desiredNumberScheduled=`kubectl get ds -n $CEPH_NAMESPACE $ds -o json|jq -r .status.desiredNumberScheduled`
  if [[ $updatedNumberScheduled != $desiredNumberScheduled ]]; then
    if kubectl get ds -n $CEPH_NAMESPACE  $ds -o json|jq -r .status|grep -i "numberAvailable" ;then
      require_upgrade=$((require_upgrade+1))
    fi
  fi
done

ds=`kubectl get ds -n $CEPH_NAMESPACE -l release_group=$RELEASE_GROUP_NAME --no-headers|awk '{print $1}'|head -n 1`
TARGET_HELM_RELEASE=`kubectl get ds -n $CEPH_NAMESPACE $ds  -o json|jq -r .status.observedGeneration`
echo "Latest revision of the helm chart $RELEASE_GROUP_NAME  is : $TARGET_HELM_RELEASE"

if [[ $TARGET_HELM_RELEASE -gt 1  ]]; then
  if [[  $require_upgrade -gt 0 ]]; then
    echo "waiting for inactive pgs and degraded obejcts before upgrade"
    wait_for_inactive_pgs
    wait_for_degraded_objects
    ceph -s
    ceph osd "set" noout
    echo "lets restart the osds rack by rack"
    restart_by_rack
    ceph osd "unset" noout
  fi

  #lets check all the ceph-osd daemonsets
  echo "checking DS"
  check_ds
else
  echo "No revisions found for upgrade"
fi
