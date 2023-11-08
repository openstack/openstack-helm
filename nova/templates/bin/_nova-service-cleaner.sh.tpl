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

set -xe

# If any non-compute service is down, then sleep for 2 times the report_interval
# to confirm service is still down.
DISABLED_SVC="$(openstack compute service list -f value | grep -v 'nova-compute' | grep 'down' || true)"
if [ ! -z "${DISABLED_SVC}" ]; then
  sleep {{ .Values.jobs.service_cleaner.sleep_time }}
fi

NOVA_SERVICES_TO_CLEAN="$(openstack compute service list -f value -c Binary | sort | uniq | grep -v '^nova-compute$')"
for NOVA_SERVICE in ${NOVA_SERVICES_TO_CLEAN}; do
  DEAD_SERVICE_IDS=$(openstack compute service list --service ${NOVA_SERVICE} -f json | jq -r '.[] | select(.State == "down") | .ID')
  for SERVICE_ID in ${DEAD_SERVICE_IDS}; do
    openstack compute service delete "${SERVICE_ID}"
  done
done

{{- if .Values.jobs.service_cleaner.extra_command }}
{{ .Values.jobs.service_cleaner.extra_command }}
{{- end }}
