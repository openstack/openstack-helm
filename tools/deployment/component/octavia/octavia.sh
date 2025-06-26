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

#NOTE: Define variables
: ${OSH_HELM_REPO:="../openstack-helm"}
: ${OSH_VALUES_OVERRIDES_PATH:="../openstack-helm/values_overrides"}
: ${OSH_EXTRA_HELM_ARGS_OCTAVIA:="$(helm osh get-values-overrides ${DOWNLOAD_OVERRIDES:-} -p ${OSH_VALUES_OVERRIDES_PATH} -c octavia ${FEATURES})"}

export OS_CLOUD=openstack_helm

OSH_AMPHORA_IMAGE_NAME="amphora-x64-haproxy-ubuntu-jammy"
OSH_AMPHORA_IMAGE_OWNER_ID=$(openstack image show "${OSH_AMPHORA_IMAGE_NAME}" -f value -c owner)
OSH_AMPHORA_SECGROUP_LIST=$(openstack security group list -f value | grep lb-mgmt-sec-grp | awk '{print $1}')
OSH_AMPHORA_FLAVOR_ID=$(openstack flavor show m1.amphora -f value -c id)
OSH_AMPHORA_BOOT_NETWORK_LIST=$(openstack network list --name lb-mgmt-net -f value -c ID)
# Test nodes are quite small (usually 8Gb RAM) and for testing Octavia
# we need two worker VM instances and one amphora VM instance.
# We are going to run them all on different K8s nodes.
# The /tmp/inventory_k8s_nodes.txt file is created by the deploy-env role and contains the list
# of all K8s nodes. Amphora instance is run on the first K8s node from the list.
OSH_AMPHORA_TARGET_HOSTNAME=$(sed -n '1p' /tmp/inventory_k8s_nodes.txt)
CONTROLLER_IP_PORT_LIST=$(cat /tmp/octavia_hm_controller_ip_port_list)

#NOTE: Deploy command
tee /tmp/octavia.yaml <<EOF
pod:
  mounts:
    octavia_api:
      octavia_api:
        volumeMounts:
          - name: octavia-certs
            mountPath: /etc/octavia/certs/server_ca.cert.pem
            subPath: server_ca.cert.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/server_ca-chain.cert.pem
            subPath: server_ca-chain.cert.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/private/server_ca.key.pem
            subPath: server_ca.key.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/client_ca.cert.pem
            subPath: client_ca.cert.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/private/client.cert-and-key.pem
            subPath: client.cert-and-key.pem
        volumes:
          - name: octavia-certs
            secret:
              secretName: octavia-certs
              defaultMode: 0644
    octavia_worker:
      octavia_worker:
        volumeMounts:
          - name: octavia-certs
            mountPath: /etc/octavia/certs/server_ca.cert.pem
            subPath: server_ca.cert.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/server_ca-chain.cert.pem
            subPath: server_ca-chain.cert.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/private/server_ca.key.pem
            subPath: server_ca.key.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/client_ca.cert.pem
            subPath: client_ca.cert.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/private/client.cert-and-key.pem
            subPath: client.cert-and-key.pem
        volumes:
          - name: octavia-certs
            secret:
              secretName: octavia-certs
              defaultMode: 0644
    octavia_housekeeping:
      octavia_housekeeping:
        volumeMounts:
          - name: octavia-certs
            mountPath: /etc/octavia/certs/server_ca.cert.pem
            subPath: server_ca.cert.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/server_ca-chain.cert.pem
            subPath: server_ca-chain.cert.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/private/server_ca.key.pem
            subPath: server_ca.key.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/client_ca.cert.pem
            subPath: client_ca.cert.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/private/client.cert-and-key.pem
            subPath: client.cert-and-key.pem
        volumes:
          - name: octavia-certs
            secret:
              secretName: octavia-certs
              defaultMode: 0644
    octavia_health_manager:
      octavia_health_manager:
        volumeMounts:
          - name: octavia-certs
            mountPath: /etc/octavia/certs/server_ca.cert.pem
            subPath: server_ca.cert.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/server_ca-chain.cert.pem
            subPath: server_ca-chain.cert.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/private/server_ca.key.pem
            subPath: server_ca.key.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/client_ca.cert.pem
            subPath: client_ca.cert.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/private/client.cert-and-key.pem
            subPath: client.cert-and-key.pem
        volumes:
          - name: octavia-certs
            secret:
              secretName: octavia-certs
              defaultMode: 0644
    octavia_driver_agent:
      octavia_driver_agent:
        volumeMounts:
          - name: octavia-certs
            mountPath: /etc/octavia/certs/server_ca.cert.pem
            subPath: server_ca.cert.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/server_ca-chain.cert.pem
            subPath: server_ca-chain.cert.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/private/server_ca.key.pem
            subPath: server_ca.key.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/client_ca.cert.pem
            subPath: client_ca.cert.pem
          - name: octavia-certs
            mountPath: /etc/octavia/certs/private/client.cert-and-key.pem
            subPath: client.cert-and-key.pem
        volumes:
          - name: octavia-certs
            secret:
              secretName: octavia-certs
              defaultMode: 0644
conf:
  octavia:
    controller_worker:
      amp_image_owner_id: ${OSH_AMPHORA_IMAGE_OWNER_ID}
      amp_secgroup_list: ${OSH_AMPHORA_SECGROUP_LIST}
      amp_flavor_id: ${OSH_AMPHORA_FLAVOR_ID}
      amp_boot_network_list: ${OSH_AMPHORA_BOOT_NETWORK_LIST}
      amp_image_tag: amphora
      amp_ssh_key_name: octavia-key
    health_manager:
      bind_port: 5555
      bind_ip: 0.0.0.0
      controller_ip_port_list: ${CONTROLLER_IP_PORT_LIST}
    task_flow:
      jobboard_enabled: false
    nova:
      availability_zone: nova:${OSH_AMPHORA_TARGET_HOSTNAME}
EOF
helm upgrade --install octavia ${OSH_HELM_REPO}/octavia \
  --namespace=openstack \
  --values=/tmp/octavia.yaml \
  ${OSH_EXTRA_HELM_ARGS:=} \
  ${OSH_EXTRA_HELM_ARGS_OCTAVIA}

#NOTE: Wait for deploy
helm osh wait-for-pods openstack

#NOTE: Validate Deployment info
openstack service list
