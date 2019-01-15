#!/bin/bash

# Copyright 2019 Samsung Electronics Co., Ltd.
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

set -xe

#NOTE: Lint and package chart
make octavia
export OS_CLOUD=openstack_helm

: ${OSH_LB_AMPHORA_IMAGE_NAME:="amphora-x64-haproxy"}
: ${OSH_LB_HM_HOST_PORT:="5555"}

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
tee /tmp/octavia.yaml <<EOF
pod:
  mounts:
    octavia_api:
      octavia_api:
        volumeMounts:
          - name: octavia-certs
            mountPath: /etc/octavia/certs/private/cakey.pem
            subPath: cakey.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/ca_01.pem
            subPath: ca_01.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/client.pem
            subPath: client.pem
        volumes:
          - name: octavia-certs
            secret:
              secretName: octavia-certs
              defaultMode: 0644
    octavia_worker:
      octavia_worker:
        volumeMounts:
          - name: octavia-certs
            mountPath: /etc/octavia/certs/private/cakey.pem
            subPath: cakey.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/ca_01.pem
            subPath: ca_01.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/client.pem
            subPath: client.pem
        volumes:
          - name: octavia-certs
            secret:
              secretName: octavia-certs
              defaultMode: 0644
    octavia_housekeeping:
      octavia_housekeeping:
        volumeMounts:
          - name: octavia-certs
            mountPath: /etc/octavia/certs/private/cakey.pem
            subPath: cakey.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/ca_01.pem
            subPath: ca_01.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/client.pem
            subPath: client.pem
        volumes:
          - name: octavia-certs
            secret:
              secretName: octavia-certs
              defaultMode: 0644
    octavia_health_manager:
      octavia_health_manager:
        volumeMounts:
          - name: octavia-certs
            mountPath: /etc/octavia/certs/private/cakey.pem
            subPath: cakey.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/ca_01.pem
            subPath: ca_01.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/client.pem
            subPath: client.pem
        volumes:
          - name: octavia-certs
            secret:
              secretName: octavia-certs
              defaultMode: 0644
conf:
  octavia:
    controller_worker:
      amp_image_owner_id: $(openstack image show $OSH_LB_AMPHORA_IMAGE_NAME -f value -c owner)
      amp_secgroup_list: $(openstack security group list -f value | grep lb-mgmt-sec-grp | awk '{print $1}')
      amp_flavor_id: $(openstack flavor show m1.amphora -f value -c id)
      amp_boot_network_list: $(openstack network list --name lb-mgmt-net -f value -c ID)
    health_manager:
      bind_port: $OSH_LB_HM_HOST_PORT
      bind_ip: 0.0.0.0
      controller_ip_port_list: $(cat /tmp/octavia_hm_controller_ip_port_list)
EOF
helm upgrade --install octavia ./octavia \
  --namespace=openstack \
  --values=/tmp/octavia.yaml \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_OCTAVIA}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
