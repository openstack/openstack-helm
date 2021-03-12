#!/bin/bash
{{/*
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

function endpoints_up () {
  endpoints_result=$(curl ${CACERT_OPTION} -K- <<< "--user ${PROMETHEUS_ADMIN_USERNAME}:${PROMETHEUS_ADMIN_PASSWORD}" \
    "${PROMETHEUS_ENDPOINT}/api/v1/query?query=up" \
    | python -c "import sys, json; print(json.load(sys.stdin)['status'])")
  if [ "$endpoints_result" = "success" ];
  then
    echo "PASS: Endpoints successfully queried!"
  else
    echo "FAIL: Endpoints not queried!";
    exit 1;
  fi
}

function get_targets () {
  targets_result=$(curl ${CACERT_OPTION} -K- <<< "--user ${PROMETHEUS_ADMIN_USERNAME}:${PROMETHEUS_ADMIN_PASSWORD}" \
    "${PROMETHEUS_ENDPOINT}/api/v1/targets" \
    | python -c "import sys, json; print(json.load(sys.stdin)['status'])")
  if [ "$targets_result" = "success" ];
  then
    echo "PASS: Targets successfully queried!"
  else
    echo "FAIL: Endpoints not queried!";
    exit 1;
  fi
}

function get_alertmanagers () {
  alertmanager=$(curl ${CACERT_OPTION} -K- <<< "--user ${PROMETHEUS_ADMIN_USERNAME}:${PROMETHEUS_ADMIN_PASSWORD}" \
    "${PROMETHEUS_ENDPOINT}/api/v1/alertmanagers" \
    |  python -c "import sys, json; print(json.load(sys.stdin)['status'])")
  if [ "$alertmanager" = "success" ];
  then
    echo "PASS: Alertmanager successfully queried!"
  else
    echo "FAIL: Alertmanager not queried!";
    exit 1;
  fi
}

endpoints_up
get_targets
get_alertmanagers
