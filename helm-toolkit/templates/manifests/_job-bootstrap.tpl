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

# This function creates a manifest for db creation and user management.
# It can be used in charts dict created similar to the following:
# {- $bootstrapJob := dict "envAll" . "serviceName" "senlin" -}
# { $bootstrapJob | include "helm-toolkit.manifests.job_bootstrap" }

{{- define "helm-toolkit.manifests.job_bootstrap" -}}
{{- $envAll := index . "envAll" -}}
{{- $serviceName := index . "serviceName" -}}
{{- $jobAnnotations := index . "jobAnnotations" -}}
{{- $jobLabels := index . "jobLabels" -}}
{{- $nodeSelector := index . "nodeSelector" | default ( dict $envAll.Values.labels.job.node_selector_key $envAll.Values.labels.job.node_selector_value ) -}}
{{- $tolerationsEnabled := index . "tolerationsEnabled" | default false -}}
{{- $podVolMounts := index . "podVolMounts" | default false -}}
{{- $podVols := index . "podVols" | default false -}}
{{- $configMapBin := index . "configMapBin" | default (printf "%s-%s" $serviceName "bin" ) -}}
{{- $configMapEtc := index . "configMapEtc" | default (printf "%s-%s" $serviceName "etc" ) -}}
{{- $configFile := index . "configFile" | default (printf "/etc/%s/%s.conf" $serviceName $serviceName ) -}}
{{- $logConfigFile := index . "logConfigFile" | default (printf "/etc/%s/logging.conf" $serviceName ) -}}
{{- $tlsSecret := index . "tlsSecret" | default "" -}}
{{- $keystoneUser := index . "keystoneUser" | default $serviceName -}}
{{- $openrc := index . "openrc" | default "true" -}}
{{- $secretBin := index . "secretBin" -}}
{{- $backoffLimit := index . "backoffLimit" | default "1000" -}}
{{- $activeDeadlineSeconds := index . "activeDeadlineSeconds" -}}
{{- $serviceNamePretty := $serviceName | replace "_" "-" -}}

{{- $serviceAccountName := printf "%s-%s" $serviceNamePretty "bootstrap" }}
{{ tuple $envAll "bootstrap" $serviceAccountName | include "helm-toolkit.snippets.kubernetes_pod_rbac_serviceaccount" }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ printf "%s-%s" $serviceNamePretty "bootstrap" | quote }}
  labels:
{{ tuple $envAll $serviceName "bootstrap" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 4 }}
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
{{ tuple $envAll $serviceName "bootstrap" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 8 }}
{{- if $jobLabels }}
{{ toYaml $jobLabels | indent 8 }}
{{- end }}
      annotations:
{{ tuple $envAll | include "helm-toolkit.snippets.release_uuid" | indent 8 }}
    spec:
      serviceAccountName: {{ $serviceAccountName }}
      restartPolicy: OnFailure
      {{ tuple $envAll "bootstrap" | include "helm-toolkit.snippets.kubernetes_image_pull_secrets" | indent 6 }}
      nodeSelector:
{{ toYaml $nodeSelector | indent 8 }}
{{- if $tolerationsEnabled }}
{{ tuple $envAll $serviceName | include "helm-toolkit.snippets.kubernetes_tolerations" | indent 6 }}
{{- end}}
      initContainers:
{{ tuple $envAll "bootstrap" list | include "helm-toolkit.snippets.kubernetes_entrypoint_init_container"  | indent 8 }}
      containers:
        - name: bootstrap
          image: {{ $envAll.Values.images.tags.bootstrap }}
          imagePullPolicy: {{ $envAll.Values.images.pull_policy }}
{{ tuple $envAll $envAll.Values.pod.resources.jobs.bootstrap | include "helm-toolkit.snippets.kubernetes_resources" | indent 10 }}
{{- if eq $openrc "true" }}
          env:
{{- with $env := dict "ksUserSecret" ( index $envAll.Values.secrets.identity $keystoneUser ) "useCA" (ne $tlsSecret "") }}
{{- include "helm-toolkit.snippets.keystone_openrc_env_vars" $env | indent 12 }}
{{- end }}
{{- end }}
          command:
            - /bin/bash
            - -c
            - /tmp/bootstrap.sh
          volumeMounts:
            - name: pod-tmp
              mountPath: /tmp
            - name: bootstrap-sh
              mountPath: /tmp/bootstrap.sh
              subPath: bootstrap.sh
              readOnly: true
            - name: etc-service
              mountPath: {{ dir $configFile | quote }}
            - name: bootstrap-conf
              mountPath: {{ $configFile | quote }}
              subPath: {{ base $configFile | quote }}
              readOnly: true
            - name: bootstrap-conf
              mountPath: {{ $logConfigFile | quote }}
              subPath: {{ base $logConfigFile | quote }}
              readOnly: true
{{ dict "enabled" (ne $tlsSecret "") "name" $tlsSecret | include "helm-toolkit.snippets.tls_volume_mount" | indent 12 }}
{{- if $podVolMounts }}
{{ $podVolMounts | toYaml | indent 12 }}
{{- end }}
      volumes:
        - name: pod-tmp
          emptyDir: {}
        - name: bootstrap-sh
{{- if $secretBin }}
          secret:
            secretName: {{ $secretBin | quote }}
            defaultMode: 0555
{{- else }}
          configMap:
            name: {{ $configMapBin | quote }}
            defaultMode: 0555
{{- end }}
        - name: etc-service
          emptyDir: {}
        - name: bootstrap-conf
          secret:
            secretName: {{ $configMapEtc | quote }}
            defaultMode: 0444
{{- dict "enabled" (ne $tlsSecret "") "name" $tlsSecret | include "helm-toolkit.snippets.tls_volume" | indent 8 }}
{{- if $podVols }}
{{ $podVols | toYaml | indent 8 }}
{{- end }}
{{- end }}
