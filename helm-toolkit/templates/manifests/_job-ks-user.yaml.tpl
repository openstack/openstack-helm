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

# This function creates a manifest for keystone user management.
# It can be used in charts dict created similar to the following:
# {- $ksUserJob := dict "envAll" . "serviceName" "senlin" }
# { $ksUserJob | include "helm-toolkit.manifests.job_ks_user" }

{{/*
  # To enable PodSecuritycontext (PodSecurityContext/v1) define the below in values.yaml:
  # example:
  #  values: |
  #    pod:
  #      security_context:
  #        ks_user:
  #          pod:
  #            runAsUser: 65534
  # To enable Container SecurityContext(SecurityContext/v1) for ks-user container define the values:
  # example:
  #   values: |
  #     pod:
  #       security_context:
  #         ks_user:
  #           container:
  #             ks-user:
  #               runAsUser: 65534
  #               readOnlyRootFilesystem: true
  #               allowPrivilegeEscalation: false
*/}}

{{- define "helm-toolkit.manifests.job_ks_user" -}}
{{- $envAll := index . "envAll" -}}
{{- $serviceName := index . "serviceName" -}}
{{- $jobAnnotations := index . "jobAnnotations" -}}
{{- $jobLabels := index . "jobLabels" -}}
{{- $nodeSelector := index . "nodeSelector" | default ( dict $envAll.Values.labels.job.node_selector_key $envAll.Values.labels.job.node_selector_value ) -}}
{{- $tolerationsEnabled := index . "tolerationsEnabled" | default false -}}
{{- $configMapBin := index . "configMapBin" | default (printf "%s-%s" $serviceName "bin" ) -}}
{{- $serviceUser := index . "serviceUser" | default $serviceName -}}
{{- $secretBin := index . "secretBin" -}}
{{- $tlsSecret := index . "tlsSecret" | default "" -}}
{{- $backoffLimit := index . "backoffLimit" | default "1000" -}}
{{- $activeDeadlineSeconds := index . "activeDeadlineSeconds" -}}
{{- $serviceUserPretty := $serviceUser | replace "_" "-" -}}
{{- $restartPolicy_ := "OnFailure" -}}
{{- if hasKey $envAll.Values "jobs" -}}
{{- if hasKey $envAll.Values.jobs "ks_user" -}}
{{- $restartPolicy_ = $envAll.Values.jobs.ks_user.restartPolicy | default $restartPolicy_ }}
{{- end }}
{{- end }}
{{- $restartPolicy := index . "restartPolicy" | default $restartPolicy_ -}}

{{- $serviceAccountName := printf "%s-%s" $serviceUserPretty "ks-user" }}
{{ tuple $envAll "ks_user" $serviceAccountName | include "helm-toolkit.snippets.kubernetes_pod_rbac_serviceaccount" }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ printf "%s-%s" $serviceUserPretty "ks-user" | quote }}
  labels:
{{ tuple $envAll $serviceName "ks-user" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 4 }}
{{- if $jobLabels }}
{{ toYaml $jobLabels | indent 4 }}
{{- end }}
  annotations:
{{- if $jobAnnotations }}
{{ toYaml $jobAnnotations | indent 4 }}
{{- end }}
spec:
  backoffLimit: {{ $backoffLimit }}
{{- if $activeDeadlineSeconds }}
  activeDeadlineSeconds: {{ $activeDeadlineSeconds }}
{{- end }}
  template:
    metadata:
      labels:
{{ tuple $envAll $serviceName "ks-user" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 8 }}
{{- if $jobLabels }}
{{ toYaml $jobLabels | indent 8 }}
{{- end }}
      annotations:
{{ tuple $envAll | include "helm-toolkit.snippets.release_uuid" | indent 8 }}
    spec:
      serviceAccountName: {{ $serviceAccountName | quote }}
{{ dict "envAll" $envAll "application" "ks_user" | include "helm-toolkit.snippets.kubernetes_pod_security_context" | indent 6 }}
      restartPolicy: {{ $restartPolicy }}
      {{ tuple $envAll "ks_user" | include "helm-toolkit.snippets.kubernetes_image_pull_secrets" | indent 6 }}
      nodeSelector:
{{ toYaml $nodeSelector | indent 8 }}
{{- if $tolerationsEnabled }}
{{ tuple $envAll $serviceName | include "helm-toolkit.snippets.kubernetes_tolerations" | indent 6 }}
{{- end}}
      initContainers:
{{ tuple $envAll "ks_user" list | include "helm-toolkit.snippets.kubernetes_entrypoint_init_container" | indent 8 }}
      containers:
        - name: ks-user
          image: {{ $envAll.Values.images.tags.ks_user }}
          imagePullPolicy: {{ $envAll.Values.images.pull_policy }}
{{ tuple $envAll $envAll.Values.pod.resources.jobs.ks_user | include "helm-toolkit.snippets.kubernetes_resources" | indent 10 }}
{{ dict "envAll" $envAll "application" "ks_user" "container" "ks_user" | include "helm-toolkit.snippets.kubernetes_container_security_context" | indent 10 }}
          command:
            - /bin/bash
            - -c
            - /tmp/ks-user.sh
          volumeMounts:
            - name: pod-tmp
              mountPath: /tmp
            - name: ks-user-sh
              mountPath: /tmp/ks-user.sh
              subPath: ks-user.sh
              readOnly: true
{{ dict "enabled" true "name" $tlsSecret "ca" true | include "helm-toolkit.snippets.tls_volume_mount" | indent 12 }}
          env:
{{- with $env := dict "ksUserSecret" $envAll.Values.secrets.identity.admin "useCA" (ne $tlsSecret "") }}
{{- include "helm-toolkit.snippets.keystone_openrc_env_vars" $env | indent 12 }}
{{- end }}
            - name: SERVICE_OS_SERVICE_NAME
              value: {{ $serviceName | quote }}
{{- with $env := dict "ksUserSecret" (index $envAll.Values.secrets.identity $serviceUser ) }}
{{- include "helm-toolkit.snippets.keystone_user_create_env_vars" $env | indent 12 }}
{{- end }}
            - name: SERVICE_OS_ROLES
            {{- $serviceOsRoles := index $envAll.Values.endpoints.identity.auth $serviceUser "role" }}
            {{- if kindIs "slice" $serviceOsRoles }}
              value: {{ include "helm-toolkit.utils.joinListWithComma" $serviceOsRoles | quote }}
            {{- else }}
              value: {{ $serviceOsRoles | quote }}
            {{- end }}
      volumes:
        - name: pod-tmp
          emptyDir: {}
        - name: ks-user-sh
{{- if $secretBin }}
          secret:
            secretName: {{ $secretBin | quote }}
            defaultMode: 0555
{{- else }}
          configMap:
            name: {{ $configMapBin | quote }}
            defaultMode: 0555
{{- end }}
{{- dict "enabled" true "name" $tlsSecret | include "helm-toolkit.snippets.tls_volume" | indent 8 }}
{{- end -}}
