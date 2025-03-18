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
  Renders image pull secrets for a pod
values: |
  pod:
    image_pull_secrets:
      default:
        - name: some-pull-secret
      bar:
        - name: another-pull-secret
usage: |
  {{ tuple . "bar" | include "helm-toolkit.snippets.kubernetes_image_pull_secrets" }}
return: |
  imagePullSecrets:
    - name: some-pull-secret
    - name: another-pull-secret
*/}}

{{- define "helm-toolkit.snippets.kubernetes_image_pull_secrets" -}}
{{- $envAll := index . 0 -}}
{{- $application := index . 1 -}}
{{- if ($envAll.Values.pod).image_pull_secrets }}
imagePullSecrets:
{{- if hasKey $envAll.Values.pod.image_pull_secrets $application }}
{{ index $envAll.Values.pod "image_pull_secrets" $application | toYaml | indent 2 }}
{{- end -}}
{{- if hasKey $envAll.Values.pod.image_pull_secrets "default" }}
{{ $envAll.Values.pod.image_pull_secrets.default | toYaml | indent 2 }}
{{- end -}}
{{- end -}}
{{- end -}}
