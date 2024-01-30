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

: ${HELM_INGRESS_NGINX_VERSION:="4.8.3"}

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

#NOTE: Deploy cluster ingress
helm upgrade --install ingress-nginx-cluster ingress-nginx/ingress-nginx \
  --version ${HELM_INGRESS_NGINX_VERSION} \
  --namespace=kube-system \
  --set controller.admissionWebhooks.enabled="false" \
  --set controller.kind=DaemonSet \
  --set controller.service.type=ClusterIP \
  --set controller.scope.enabled="false" \
  --set controller.hostNetwork="true" \
  --set controller.ingressClassResource.name=nginx-cluster \
  --set controller.ingressClassResource.controllerValue="k8s.io/ingress-nginx-cluster" \
  --set controller.ingressClassResource.default="true" \
  --set controller.ingressClass=nginx-cluster \
  --set controller.labels.app=ingress-api

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh kube-system

#NOTE: Deploy namespace ingress
helm upgrade --install ingress-nginx-openstack ingress-nginx/ingress-nginx \
  --version ${HELM_INGRESS_NGINX_VERSION} \
  --namespace=openstack \
  --set controller.admissionWebhooks.enabled="false" \
  --set controller.scope.enabled="true" \
  --set controller.service.enabled="false" \
  --set controller.ingressClassResource.name=nginx \
  --set controller.ingressClassResource.controllerValue="k8s.io/ingress-nginx-openstack" \
  --set controller.ingressClass=nginx \
  --set controller.labels.app=ingress-api

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

helm upgrade --install ingress-nginx-ceph ingress-nginx/ingress-nginx \
  --version ${HELM_INGRESS_NGINX_VERSION} \
  --namespace=ceph \
  --set controller.admissionWebhooks.enabled="false" \
  --set controller.scope.enabled="true" \
  --set controller.service.enabled="false" \
  --set controller.ingressClassResource.name=nginx-ceph \
  --set controller.ingressClassResource.controllerValue="k8s.io/ingress-nginx-ceph" \
  --set controller.ingressClass=nginx-ceph \
  --set controller.labels.app=ingress-api

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh ceph
