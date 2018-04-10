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

{{- define "helm-toolkit.snippets.kubernetes_entrypoint_init_container" -}}
{{- $envAll := index . 0 -}}
{{- $component := index . 1 -}}
{{- $mounts := index . 2 -}}

{{- $_ := set $envAll.Values "__kubernetes_entrypoint_init_container" dict -}}
{{- $_ := set $envAll.Values.__kubernetes_entrypoint_init_container "deps" dict -}}
{{- if and ($envAll.Values.images.local_registry.active) (ne $component "image_repo_sync") -}}
{{- $_ := include "helm-toolkit.utils.merge" ( tuple $envAll.Values.__kubernetes_entrypoint_init_container.deps ( index $envAll.Values.dependencies.static $component ) $envAll.Values.dependencies.dynamic.common.local_image_registry ) -}}
{{- else -}}
{{- $_ := set $envAll.Values.__kubernetes_entrypoint_init_container "deps" ( index $envAll.Values.dependencies.static $component ) -}}
{{- end -}}
{{- $deps := $envAll.Values.__kubernetes_entrypoint_init_container.deps }}

- name: init
{{ tuple $envAll "dep_check" | include "helm-toolkit.snippets.image" | indent 2 }}
  env:
    - name: POD_NAME
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: metadata.name
    - name: NAMESPACE
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: metadata.namespace
    - name: INTERFACE_NAME
      value: eth0
    - name: PATH
      value: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/
    - name: DEPENDENCY_SERVICE
      value: "{{ tuple $deps.services $envAll | include "helm-toolkit.utils.comma_joined_service_list" }}"
{{- if $deps.jobs -}}
  {{- if kindIs "string" (index $deps.jobs 0) }}
    - name: DEPENDENCY_JOBS
      value: "{{ include "helm-toolkit.utils.joinListWithComma" $deps.jobs }}"
  {{- else }}
    - name: DEPENDENCY_JOBS_JSON
      value: {{- toJson $deps.jobs | quote -}}
  {{- end -}}
{{- end }}
    - name: DEPENDENCY_DAEMONSET
      value: "{{ include "helm-toolkit.utils.joinListWithComma" $deps.daemonset }}"
    - name: DEPENDENCY_CONTAINER
      value: "{{ include "helm-toolkit.utils.joinListWithComma" $deps.container }}"
    - name: DEPENDENCY_POD_JSON
      value: {{ if $deps.pod }}{{ toJson $deps.pod | quote }}{{ else }}""{{ end }}
    - name: COMMAND
      value: "echo done"
  command:
    - kubernetes-entrypoint
  volumeMounts:
{{ toYaml $mounts | indent 4 }}
{{- end -}}
