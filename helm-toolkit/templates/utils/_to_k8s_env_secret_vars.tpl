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
  Returns yaml formatted to be used in k8s templates as container
  env vars injected via secrets. This requires a secret-<chartname> template to
  be defined in the chart that can be used to house the desired secret
  variables. For reference, see the fluentd chart.
values: |
  test:
    secrets:
      foo: bar

usage: |
  {{ include "helm-toolkit.utils.to_k8s_env_vars" .Values.test }}
return: |
  - name: foo
    valueFrom:
      secretKeyRef:
        name: "my-release-name-env-secret"
        key: foo
*/}}

{{- define "helm-toolkit.utils.to_k8s_env_secret_vars" -}}
{{- $context := index . 0 -}}
{{- $secrets := index . 1 -}}
{{ range $key, $config := $secrets -}}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ printf "%s-%s" $context.Release.Name "env-secret" | quote }}
      key: {{ $key }}
{{ end -}}
{{- end -}}
