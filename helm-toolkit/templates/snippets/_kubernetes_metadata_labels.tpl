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
  Renders a set of standardised labels
values: |
  release_group: null
  pod:
    labels:
      default:
        label1.example.com: value
      bar:
        label2.example.com: bar
usage: |
  {{ tuple . "foo" "bar" | include "helm-toolkit.snippets.kubernetes_metadata_labels" }}
return: |
  release_group: RELEASE-NAME
  application: foo
  component: bar
  label1.example.com: value
  label2.example.com: bar
*/}}

{{- define "helm-toolkit.snippets.kubernetes_metadata_labels" -}}
{{- $envAll := index . 0 -}}
{{- $application := index . 1 -}}
{{- $component := index . 2 -}}
release_group: {{ $envAll.Values.release_group | default $envAll.Release.Name }}
application: {{ $application }}
component: {{ $component }}
{{- if ($envAll.Values.pod).labels }}
{{- if hasKey $envAll.Values.pod.labels $component }}
{{ index $envAll.Values.pod "labels" $component | toYaml }}
{{- end -}}
{{- if hasKey $envAll.Values.pod.labels "default" }}
{{ $envAll.Values.pod.labels.default | toYaml }}
{{- end -}}
{{- end -}}
{{- end -}}
