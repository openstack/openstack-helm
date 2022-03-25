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

#NOTE: Lint and package chart
make grafana

tee /tmp/grafana.yaml << EOF
endpoints:
  monitoring_one:
    name: prometheus-one
    namespace: osh-infra
    auth:
      user:
        username: admin
        password: changeme
    hosts:
      default: prom-metrics-one
      public: prometheus-one
    host_fqdn_override:
      default: null
    path:
      default: null
    scheme:
      default: http
    port:
      api:
        default: 80
        public: 80
  monitoring_two:
    name: prometheus-two
    namespace: osh-infra
    auth:
      user:
        username: admin
        password: changeme
    hosts:
      default: prom-metrics-two
      public: prometheus-two
    host_fqdn_override:
      default: null
    path:
      default: null
    scheme:
      default: http
    port:
      api:
        default: 80
        public: 80
  monitoring_three:
    name: prometheus-three
    namespace: osh-infra
    auth:
      user:
        username: admin
        password: changeme
    hosts:
      default: prom-metrics-three
      public: prometheus-three
    host_fqdn_override:
      default: null
    path:
      default: null
    scheme:
      default: http
    port:
      api:
        default: 80
        public: 80
  monitoring_federated:
    name: prometheus-federate
    namespace: osh-infra
    auth:
      user:
        username: admin
        password: changeme
    hosts:
      default: prom-metrics-federate
      public: prometheus-federate
    host_fqdn_override:
      default: null
    path:
      default: null
    scheme:
      default: http
    port:
      api:
        default: 80
        public: 80
conf:
  provisioning:
    datasources:
      template: |
        apiVersion: 1
        datasources:
        - name: prometheus-one
          type: prometheus
          access: proxy
          orgId: 1
          editable: false
          basicAuth: true
          basicAuthUser: admin
          secureJsonData:
            basicAuthPassword: changeme
          url: {{ tuple "monitoring_one" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}
        - name: prometheus-two
          type: prometheus
          access: proxy
          orgId: 1
          editable: false
          basicAuth: true
          basicAuthUser: admin
          secureJsonData:
            basicAuthPassword: changeme
          url: {{ tuple "monitoring_two" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}
        - name: prometheus-three
          type: prometheus
          access: proxy
          orgId: 1
          editable: false
          basicAuth: true
          basicAuthUser: admin
          secureJsonData:
            basicAuthPassword: changeme
          url: {{ tuple "monitoring_three" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}
        - name: prometheus-federated
          type: prometheus
          access: proxy
          orgId: 1
          editable: false
          basicAuth: true
          basicAuthUser: admin
          secureJsonData:
            basicAuthPassword: changeme
          url: {{ tuple "monitoring_federated" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}

EOF

#NOTE: Deploy command
helm upgrade --install grafana ./grafana \
    --namespace=osh-infra \
    --values=/tmp/grafana.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

# Delete the test pod if it still exists
kubectl delete pods -l application=grafana,release_group=grafana,component=test --namespace=osh-infra --ignore-not-found

helm test grafana --namespace osh-infra

echo "Get list of all configured datasources in Grafana"
curl -u admin:password http://grafana.osh-infra.svc.cluster.local/api/datasources | jq -r .
