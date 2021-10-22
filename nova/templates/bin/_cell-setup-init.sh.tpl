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

{{- if .Values.jobs.cell_setup.extended_wait.enabled }}
iteration={{ .Values.jobs.cell_setup.extended_wait.iteration }}
duration={{ .Values.jobs.cell_setup.extended_wait.duration }}

extra_wait=true

while [[ "$extra_wait" == true ]]
do
  if [[ -z "$(openstack compute service list --service nova-compute -f value -c State | grep '^down$')" ]]
  then
    # No more down
    extra_wait=false
  else
    sleep "$duration"

    if [[ "$iteration" -gt 1 ]]
    then
      ((iteration=iteration-1))
    else
      extra_wait=false

      # List out the info to see whether any nodes is still down
      openstack compute service list --service nova-compute
    fi
  fi
done
{{- end }}

until openstack compute service list --service nova-compute -f value -c State | grep -q "^up$" ;do
  echo "Waiting for Nova Compute processes to register"
  sleep 10
done
