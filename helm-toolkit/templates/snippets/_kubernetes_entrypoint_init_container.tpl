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
  Returns a container definition for use with the kubernetes-entrypoint image
  from stackanetes.
values: |
  images:
    tags:
      dep_check: quay.io/airshipit/kubernetes-entrypoint:v1.0.0
    pull_policy: IfNotPresent
    local_registry:
      active: true
      exclude:
        - dep_check
  dependencies:
    dynamic:
      common:
        local_image_registry:
          jobs:
            - calico-image-repo-sync
          services:
            - endpoint: node
              service: local_image_registry
    static:
      calico_node:
        services:
          - endpoint: internal
            service: etcd
        custom_resources:
          - apiVersion: argoproj.io/v1alpha1
            kind: Workflow
            name: wf-example
            fields:
              - key: "status.phase"
                value: "Succeeded"
  endpoints:
    local_image_registry:
      namespace: docker-registry
      hosts:
        default: localhost
        node: localhost
    etcd:
      hosts:
        default: etcd
  # NOTE (portdirect): if the stanza, or a portion of it, under `pod` is not
  # specififed then the following will be used as defaults:
  #  pod:
  #    security_context:
  #      kubernetes_entrypoint:
  #        container:
  #          kubernetes_entrypoint:
  #            runAsUser: 65534
  #            readOnlyRootFilesystem: true
  #            allowPrivilegeEscalation: false
  pod:
    security_context:
      kubernetes_entrypoint:
        container:
          kubernetes_entrypoint:
            runAsUser: 0
            readOnlyRootFilesystem: false
usage: |
  {{ tuple . "calico_node" list | include "helm-toolkit.snippets.kubernetes_entrypoint_init_container" }}
return: |
  - name: init
    image: "quay.io/airshipit/kubernetes-entrypoint:v1.0.0"
    imagePullPolicy: IfNotPresent
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: false
      runAsUser: 0

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
        value: "default:etcd,docker-registry:localhost"
      - name: DEPENDENCY_JOBS
        value: "calico-image-repo-sync"
      - name: DEPENDENCY_DAEMONSET
        value: ""
      - name: DEPENDENCY_CONTAINER
        value: ""
      - name: DEPENDENCY_POD_JSON
        value: ""
      - name: DEPENDENCY_CUSTOM_RESOURCE
        value: "[{\"apiVersion\":\"argoproj.io/v1alpha1\",\"kind\":\"Workflow\",\"namespace\":\"default\",\"name\":\"wf-example\",\"fields\":[{\"key\":\"status.phase\",\"value\":\"Succeeded\"}]}]"
    command:
      - kubernetes-entrypoint
    volumeMounts:
      []
*/}}

{{- define "helm-toolkit.snippets.kubernetes_entrypoint_init_container._default_security_context" -}}
Values:
  pod:
    security_context:
      kubernetes_entrypoint:
        container:
          kubernetes_entrypoint:
            runAsUser: 65534
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
{{- end -}}

{{- define "helm-toolkit.snippets.kubernetes_entrypoint_init_container" -}}
{{- $envAll := index . 0 -}}
{{- $component := index . 1 -}}
{{- $mounts := index . 2 -}}

{{- $_ := set $envAll.Values "__kubernetes_entrypoint_init_container" dict -}}
{{- $_ := set $envAll.Values.__kubernetes_entrypoint_init_container "deps" dict -}}
{{- if and ($envAll.Values.images.local_registry.active) (ne $component "image_repo_sync") -}}
{{- if eq $component "pod_dependency" -}}
{{- $_ := include "helm-toolkit.utils.merge" ( tuple $envAll.Values.__kubernetes_entrypoint_init_container.deps ( index $envAll.Values.pod_dependency ) $envAll.Values.dependencies.dynamic.common.local_image_registry ) -}}
{{- else -}}
{{- $_ := include "helm-toolkit.utils.merge" ( tuple $envAll.Values.__kubernetes_entrypoint_init_container.deps ( index $envAll.Values.dependencies.static $component ) $envAll.Values.dependencies.dynamic.common.local_image_registry ) -}}
{{- end -}}
{{- else -}}
{{- if eq $component "pod_dependency" -}}
{{- $_ := set $envAll.Values.__kubernetes_entrypoint_init_container "deps" ( index $envAll.Values.pod_dependency ) -}}
{{- else -}}
{{- $_ := set $envAll.Values.__kubernetes_entrypoint_init_container "deps" ( index $envAll.Values.dependencies.static $component ) -}}
{{- end -}}
{{- end -}}

{{- if and ($envAll.Values.manifests.job_rabbit_init) (hasKey $envAll.Values.dependencies "dynamic") -}}
{{- if $envAll.Values.dependencies.dynamic.job_rabbit_init -}}
{{- if eq $component "pod_dependency" -}}
{{- $_ := include "helm-toolkit.utils.merge" ( tuple $envAll.Values.__kubernetes_entrypoint_init_container.deps ( index $envAll.Values.pod_dependency ) (index $envAll.Values.dependencies.dynamic.job_rabbit_init $component) ) -}}
{{- else -}}
{{- $_ := include "helm-toolkit.utils.merge" ( tuple $envAll.Values.__kubernetes_entrypoint_init_container.deps ( index $envAll.Values.dependencies.static $component ) (index $envAll.Values.dependencies.dynamic.job_rabbit_init $component)) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- $deps := $envAll.Values.__kubernetes_entrypoint_init_container.deps }}
{{- range $deps.custom_resources }}
{{- $_ := set . "namespace" $envAll.Release.Namespace -}}
{{- end -}}
{{- $default_security_context := include "helm-toolkit.snippets.kubernetes_entrypoint_init_container._default_security_context" . | fromYaml }}
{{- $patchedEnvAll := mergeOverwrite $default_security_context $envAll }}
- name: init
{{ tuple $envAll "dep_check" | include "helm-toolkit.snippets.image" | indent 2 }}
{{- dict "envAll" $patchedEnvAll "application" "kubernetes_entrypoint" "container" "kubernetes_entrypoint" | include "helm-toolkit.snippets.kubernetes_container_security_context" | indent 2 }}
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
    - name: DEPENDENCY_CUSTOM_RESOURCE
      value: {{ if $deps.custom_resources }}{{ toJson $deps.custom_resources | quote }}{{ else }}""{{ end }}
  command:
    - kubernetes-entrypoint
  volumeMounts:
{{ toYaml $mounts | indent 4 }}
{{- end -}}
