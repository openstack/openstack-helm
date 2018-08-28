#!/bin/bash
{{/*
Copyright 2017 The Openstack-Helm Authors.

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


set -ex

function check_datasource () {
  echo "Verifying prometheus datasource configured"
  datasource_type=$(curl -K- <<< "--user ${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}" \
  "${GRAFANA_ENDPOINT}/api/datasources" \
  | python -c "import sys, json; print json.load(sys.stdin)[0]['type']")
  if [ "$datasource_type" == "prometheus" ];
  then
     echo "PASS: Prometheus datasource found!";
  else
     echo "FAIL: Prometheus datasource not found!";
     exit 1;
  fi
}

function check_dashboard_count () {
  echo "Verifying number of configured dashboards"
  dashboard_count=$(curl -K- <<< "--user ${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}" \
  "${GRAFANA_ENDPOINT}/api/admin/stats" \
  | python -c "import sys, json; print json.load(sys.stdin)['dashboards']")
  if [ "$dashboard_count" == "$DASHBOARD_COUNT" ];
  then
     echo "PASS: Reported number:$dashboard_count, expected number: $DASHBOARD_COUNT";
  else
     echo "FAIL: Reported number:$dashboard_count, expected number: $DASHBOARD_COUNT";
     exit 1;
  fi
}

check_datasource
check_dashboard_count
