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
make nagios

#NOTE: Deploy command
tee /tmp/nagios.yaml << EOF
conf:
  nagios:
    query_es_clauses:
      test_es_query:
        hello: world
EOF
helm upgrade --install nagios ./nagios \
    --namespace=osh-infra \
    --values=/tmp/nagios.yaml \
    --values=nagios/values_overrides/openstack-objects.yaml \
    --values=nagios/values_overrides/postgresql-objects.yaml \
    --values=nagios/values_overrides/elasticsearch-objects.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

#NOTE: Verify elasticsearch query clauses are functional by execing into pod
NAGIOS_POD=$(kubectl -n osh-infra get pods -l='application=nagios,component=monitoring' --output=jsonpath='{.items[0].metadata.name}')
kubectl exec $NAGIOS_POD  -n osh-infra -c nagios -- cat /opt/nagios/etc/objects/query_es_clauses.json | python -m json.tool
