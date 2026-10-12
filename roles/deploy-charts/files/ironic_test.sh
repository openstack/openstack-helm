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
set -xe

export OS_CLOUD=openstack_helm_system

openstack baremetal driver list
openstack baremetal conductor list

openstack baremetal node create --driver fake-hardware --name fake-node
openstack baremetal node manage --wait 120 fake-node
openstack baremetal node provide --wait 120 fake-node
openstack baremetal node deploy --wait 300 fake-node
openstack baremetal node undeploy --wait 300 fake-node
openstack baremetal node delete fake-node

# The conductor serves TFTP and HTTP boot files on the PXE interface.
PXE_IP=$(ip -4 -o addr show ironic-pxe | awk '{print $4}' | cut -d/ -f1)
POD=$(kubectl get pods -n osh -l application=ironic,component=conductor -o name | head -1)
kubectl exec -n osh "$POD" -c ironic-conductor -- sh -c \
  'echo ok > /var/lib/openstack-helm/tftpboot/check; echo ok > /var/lib/openstack-helm/httpboot/check'
curl -fsS "tftp://${PXE_IP}/check" | grep -x ok
curl -fsS "http://${PXE_IP}:8080/check" | grep -x ok
