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

{{- define "helm-toolkit.scripts.rally_test" }}
#!/bin/bash
set -ex

: ${RALLY_ENV_NAME:="openstack-helm"}
rally-manage db create
rally deployment create --fromenv --name ${RALLY_ENV_NAME}
rally deployment use ${RALLY_ENV_NAME}
rally deployment check
rally task validate /etc/rally/rally_tests.yaml
rally task start /etc/rally/rally_tests.yaml
rally deployment destroy --deployment ${RALLY_ENV_NAME}
rally task sla-check
{{- end }}
