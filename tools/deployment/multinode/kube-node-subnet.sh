#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
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
NODE_IPS=$(mktemp --suffix=.txt)
kubectl get nodes -o json | jq -r '.items[].status.addresses[] | select(.type=="InternalIP").address' | sort -V > $NODE_IPS
FIRST_IP_SUBNET=$(sudo docker run --rm ${UTILS_IMAGE} ipcalc "$(head -n 1 ${NODE_IPS})/24" | awk '/^Network/ { print $2 }')
LAST_IP_SUBNET=$(sudo docker run --rm ${UTILS_IMAGE} ipcalc "$(tail -n 1 ${NODE_IPS})/24" | awk '/^Network/ { print $2 }')
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
