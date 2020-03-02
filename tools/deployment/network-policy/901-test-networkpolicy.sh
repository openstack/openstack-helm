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

# test_netpol(namespace, application label, component label, target_host, expected_result{fail,success})
function test_netpol {
  NS=$1
  APPLICATION=$2
  COMPONENT=$3
  HOST=$4
  STATUS=$5
  echo Testing connection from component:$COMPONENT, application:$APPLICATION to host $HOST with namespace $NS
  POD=$(kubectl -n $NS get pod -l application=$APPLICATION,component=$COMPONENT | grep Running | cut -f 1 -d " " | head -n 1)
  PID=$(sudo docker inspect --format '{{ .State.Pid }}' $(kubectl get pods --namespace $NS $POD -o jsonpath='{.status.containerStatuses[0].containerID}' | cut -c 10-21))
  if [ "x${STATUS}" == "xfail" ]; then
    if ! sudo nsenter -t $PID -n wget -r -nd --delete-after --timeout=5 --tries=1 $HOST ; then
      if [[ "$?" == 6 ]]; then
        exit 1
      else
        echo "Connection timed out; as expected by policy."
      fi
    else
      exit 1
    fi
  else
    if sudo nsenter -t $PID -n wget -r -nd --delete-after --timeout=10 --tries=1 $HOST; then
      echo "Connection successful; as expected by policy"
    # NOTE(srwilkers): If wget returns error code 6 (invalid credentials), we should consider it
    # a success
    elif [[ "$?" == 6 ]]; then
      echo "Connection successful; as expected by policy"
    else
      exit 1
    fi
  fi
}

# Doing negative tests
# NOTE(gagehugo): Uncomment these once the proper netpol rules are made
#test_netpol osh-infra mariadb server elasticsearch.osh-infra.svc.cluster.local fail
#test_netpol osh-infra mariadb server nagios.osh-infra.svc.cluster.local fail
#test_netpol osh-infra mariadb server prometheus.osh-infra.svc.cluster.local fail
#test_netpol osh-infra mariadb server nagios.osh-infra.svc.cluster.local fail
#test_netpol osh-infra mariadb server openstack-metrics.openstack.svc.cluster.local:9103 fail
#test_netpol osh-infra mariadb server kibana.osh-infra.svc.cluster.local fail
#test_netpol osh-infra mariadb server fluentd-logging.osh-infra.svc.cluster.local:24224 fail
#test_netpol osh-infra fluentbit daemon prometheus.osh-infra.svc.cluster.local fail

# Doing positive tests
test_netpol osh-infra grafana dashboard mariadb.osh-infra.svc.cluster.local:3306 success
test_netpol osh-infra elasticsearch client kibana-dash.osh-infra.svc.cluster.local success
test_netpol osh-infra fluentd internal elasticsearch-logging.osh-infra.svc.cluster.local success
test_netpol osh-infra prometheus api fluentd-exporter.osh-infra.svc.cluster.local:9309/metrics success
test_netpol osh-infra prometheus api elasticsearch-exporter.osh-infra.svc.cluster.local:9108/metrics success
