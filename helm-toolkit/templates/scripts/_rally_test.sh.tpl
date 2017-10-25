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

{{- define "helm-toolkit.scripts.rally_test" -}}
#!/bin/bash
set -ex
{{- $rallyTests := index . 0 }}

: ${RALLY_ENV_NAME:="openstack-helm"}
rally-manage db create
rally deployment create --fromenv --name ${RALLY_ENV_NAME}
rally deployment use ${RALLY_ENV_NAME}
rally deployment check
{{- if $rallyTests.run_tempest }}
rally verify create-verifier --name ${RALLY_ENV_NAME}-tempest --type tempest
SERVICE_TYPE=$(rally deployment check | grep ${RALLY_ENV_NAME} | awk -F \| '{print $3}' | tr -d ' ' | tr -d '\n')
rally verify start --pattern tempest.api.$SERVICE_TYPE*
rally verify delete-verifier --id ${RALLY_ENV_NAME}-tempest --force
{{- end }}
rally task validate /etc/rally/rally_tests.yaml
rally task start /etc/rally/rally_tests.yaml
rally deployment destroy --deployment ${RALLY_ENV_NAME}
rally task sla-check
{{- end }}
