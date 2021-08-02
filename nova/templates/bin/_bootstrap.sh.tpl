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
export HOME=/tmp

{{ if .Values.bootstrap.structured.flavors.enabled }}
{{ range .Values.bootstrap.structured.flavors.options }}
# NOTE(aostapenko) Since Wallaby with switch of osc to sdk '--id auto' is no
# longer treated specially. Though the same behavior can be achieved w/o specifying
#--id flag.
# https://review.opendev.org/c/openstack/python-openstackclient/+/750151
{
  openstack flavor show {{ .name }} || \
   openstack flavor create {{ .name }} \
{{ if .id }} \
   --id {{ .id }} \
{{ end }} \
   --ram {{ .ram }} \
   --disk {{ .disk }} \
   --vcpus {{ .vcpus }}
} &
{{ end }}
wait
{{ end }}

{{ if .Values.bootstrap.wait_for_computes.enabled }}
{{ .Values.bootstrap.wait_for_computes.scripts.wait_script }}
{{ else }}
echo 'Wait for Computes script not enabled'
{{ end }}

{{ .Values.bootstrap.script | default "echo 'No other bootstrap customizations found.'" }}
