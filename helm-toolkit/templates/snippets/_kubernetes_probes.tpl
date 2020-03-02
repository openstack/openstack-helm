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

{{/*
abstract: |
  Renders kubernetes liveness and readiness probes for containers
values: |
  pod:
    probes:
      api:
        default:
          readiness:
            enabled: true
            params:
              initialDelaySeconds: 30
              timeoutSeconds: 30
usage: |
  {{- define "probeTemplate" }}
  httpGet:
    path: /status
    port: 9090
  {{- end }}
  {{ dict "envAll" . "component" "api" "container" "default" "type" "readiness" "probeTemplate" (include "probeTemplate" . | fromYaml) | include "helm-toolkit.snippets.kubernetes_probe" }}
return: |
  readinessProbe:
    httpGet:
      path: /status
      port: 9090
    initialDelaySeconds: 30
    timeoutSeconds: 30
*/}}

{{- define "helm-toolkit.snippets.kubernetes_probe" -}}
{{- $envAll := index . "envAll" -}}
{{- $component := index . "component" -}}
{{- $container := index . "container" -}}
{{- $type := index . "type" -}}
{{- $probeTemplate := index . "probeTemplate" -}}
{{- $probeOpts := index $envAll.Values.pod.probes $component $container $type -}}
{{- if $probeOpts.enabled -}}
{{- $probeOverides := index $probeOpts "params" | default dict -}}
{{ dict ( printf "%sProbe" $type ) (mergeOverwrite $probeTemplate $probeOverides ) | toYaml }}
{{- end -}}
{{- end -}}
