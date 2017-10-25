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

{{- define "helm-toolkit.snippets.image" -}}
{{- $envAll := index . 0 -}}
{{- $image := index . 1 -}}
{{- $imageTag := index $envAll.Values.images.tags $image -}}
{{- if $envAll.Values.images.registry.prefix -}}
image: {{ printf "%s/%s" $envAll.Values.images.registry.prefix $imageTag | quote }}
{{- else -}}
image: {{ $imageTag | quote }}
{{- end }}
imagePullPolicy: {{ $envAll.Values.images.pull_policy }}
{{- end -}}
