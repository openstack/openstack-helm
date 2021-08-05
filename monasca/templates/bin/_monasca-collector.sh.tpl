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
# Start our service.
{{- $envAll := . }}

echo "Copying manual configurations for plugins..."
mkdir -p /etc/monasca/agent/conf.d/
cp /tmp/conf.d/*.yaml /etc/monasca/agent/conf.d/

echo "Configuring automatically for plugins without explicit configuration using monasca-setup..."

{{- range $k, $v := .Values.conf.agent_plugins }}
{{- if $v.auto_detect }}
{{- $local := dict "first" true }}
username=$(id -un "{{ $envAll.Values.pod.security_context.agent.container.monasca_collector.runAsUser }}")
monasca-setup --install_plugins_only -d {{ $k }} --user $username \
-a "{{- range $kk, $vv := $v.config -}}{{- if not $local.first -}}{{- " " -}}{{- end -}}{{ printf "%s=%s" $kk $vv }}{{- $_ := set $local "first" false -}}{{- end -}}" || echo "Auto-detection failed for {{ $k }}"
{{- end }}
{{- end }}

echo "Starting monasca-collector..."
exec monasca-collector foreground
