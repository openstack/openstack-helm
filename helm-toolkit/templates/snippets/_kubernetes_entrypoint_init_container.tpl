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
{{- $deps := index . 1 -}}
{{- $mounts := index . 2 -}}
- name: init
  image: {{ $envAll.Values.images.dep_check }}
  imagePullPolicy: {{ $envAll.Values.images.pull_policy }}
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
    - name: DEPENDENCY_SERVICE
      value: "{{ tuple $deps.services $envAll | include "helm-toolkit.utils.comma_joined_hostname_list" }}"
    - name: DEPENDENCY_JOBS
      value: "{{  include "helm-toolkit.utils.joinListWithComma" $deps.jobs }}"
    - name: DEPENDENCY_DAEMONSET
      value: "{{  include "helm-toolkit.utils.joinListWithComma" $deps.daemonset }}"
    - name: DEPENDENCY_CONTAINER
      value: "{{  include "helm-toolkit.utils.joinListWithComma" $deps.container }}"
    - name: COMMAND
      value: "echo done"
  command:
    - kubernetes-entrypoint
  volumeMounts: {{ $mounts | default "[]"}}
{{- end -}}
