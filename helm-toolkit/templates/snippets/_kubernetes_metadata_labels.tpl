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
{{- $podValues := $envAll.Values.pod | default dict -}}
{{- $labels := $podValues.labels | default dict -}}
release_group: {{ $envAll.Values.release_group | default $envAll.Release.Name }}
application: {{ $application }}
component: {{ $component }}
{{- if or $labels.include_app_kubernetes_io (not (hasKey $labels "include_app_kubernetes_io")) }}
app.kubernetes.io/name: {{ $application }}
app.kubernetes.io/component: {{ $component }}
app.kubernetes.io/instance: {{ $envAll.Values.release_group | default $envAll.Release.Name }}
{{- end -}}
{{- if $labels }}
{{- if hasKey $labels $component }}
{{ index $podValues "labels" $component | toYaml }}
{{- end -}}
{{- if hasKey $labels "default" }}
{{ $labels.default | toYaml }}
{{- end -}}
{{- end -}}
{{- end -}}
