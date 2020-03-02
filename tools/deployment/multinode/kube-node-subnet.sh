#!/bin/bash

#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
set -e

UTILS_IMAGE=docker.io/openstackhelm/gate-utils:v0.1.0
NODE_IPS=$(mktemp)
kubectl get nodes -o json | jq -r '.items[].status.addresses[] | select(.type=="InternalIP").address' | sort -V > $NODE_IPS
function run_and_log_ipcalc {
  POD_NAME="tmp-$(cat /dev/urandom | env LC_CTYPE=C tr -dc a-z | head -c 5; echo)"
  kubectl run ${POD_NAME} \
    --generator=run-pod/v1 \
    --wait \
    --image ${UTILS_IMAGE} \
    --restart=Never \
    ipcalc -- "$1"
  end=$(($(date +%s) + 900))
  until kubectl get pod/${POD_NAME} -o go-template='{{.status.phase}}' | grep -q Succeeded; do
    now=$(date +%s)
    [ $now -gt $end ] && echo containers failed to start. && \
        kubectl get pod/${POD_NAME} -o wide && exit 1
  done
  kubectl logs pod/${POD_NAME}
  kubectl delete pod/${POD_NAME}
}
FIRST_IP_SUBNET=$(run_and_log_ipcalc "$(head -n 1 ${NODE_IPS})/24" | awk '/^Network/ { print $2 }')
LAST_IP_SUBNET=$(run_and_log_ipcalc "$(tail -n 1 ${NODE_IPS})/24" | awk '/^Network/ { print $2 }')
rm -f $NODE_IPS
function ip_diff {
  echo $(($(echo $LAST_IP_SUBNET | awk -F '.' "{ print \$$1}") - $(echo $FIRST_IP_SUBNET | awk -F '.' "{ print \$$1}")))
}
for X in {1..4}; do
  if ! [ "$(ip_diff ${X})" -eq "0" ]; then
    SUBMASK=$((((${X} - 1 )) * 8))
    break
  elif [ ${X} -eq "4" ]; then
    SUBMASK=24
  fi
done
echo ${FIRST_IP_SUBNET%/*}/${SUBMASK}
