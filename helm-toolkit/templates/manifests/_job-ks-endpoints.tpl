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

# This function creates a manifest for keystone service management.
# It can be used in charts dict created similar to the following:
# {- $ksEndpointJob := dict "envAll" . "serviceName" "senlin" "serviceTypes" ( tuple "clustering" ) -}
# { $ksEndpointJob | include "helm-toolkit.manifests.job_ks_endpoints" }

{{- define "helm-toolkit.manifests.job_ks_endpoints" -}}
{{- $envAll := index . "envAll" -}}
{{- $serviceName := index . "serviceName" -}}
{{- $serviceTypes := index . "serviceTypes" -}}
{{- $jobAnnotations := index . "jobAnnotations" -}}
{{- $jobLabels := index . "jobLabels" -}}
{{- $nodeSelector := index . "nodeSelector" | default ( dict $envAll.Values.labels.job.node_selector_key $envAll.Values.labels.job.node_selector_value ) -}}
{{- $tolerationsEnabled := index . "tolerationsEnabled" | default false -}}
{{- $configMapBin := index . "configMapBin" | default (printf "%s-%s" $serviceName "bin" ) -}}
{{- $secretBin := index . "secretBin" -}}
{{- $tlsSecret := index . "tlsSecret" | default "" -}}
{{- $backoffLimit := index . "backoffLimit" | default "1000" -}}
{{- $activeDeadlineSeconds := index . "activeDeadlineSeconds" -}}
{{- $serviceNamePretty := $serviceName | replace "_" "-" -}}
{{- $restartPolicy_ := "OnFailure" -}}
{{- if hasKey $envAll.Values "jobs" -}}
{{- if hasKey $envAll.Values.jobs "ks_endpoints" -}}
{{- $restartPolicy_ = $envAll.Values.jobs.ks_endpoints.restartPolicy | default $restartPolicy_ }}
{{- end }}
{{- end }}
{{- $restartPolicy := index . "restartPolicy" | default $restartPolicy_ -}}

{{- $serviceAccountName := printf "%s-%s" $serviceNamePretty "ks-endpoints" }}
{{ tuple $envAll "ks_endpoints" $serviceAccountName | include "helm-toolkit.snippets.kubernetes_pod_rbac_serviceaccount" }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ printf "%s-%s" $serviceNamePretty "ks-endpoints" | quote }}
  labels:
{{ tuple $envAll $serviceName "ks-endpoints" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 4 }}
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
{{ tuple $envAll $serviceName "ks-endpoints" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 8 }}
{{- if $jobLabels }}
{{ toYaml $jobLabels | indent 8 }}
{{- end }}
      annotations:
{{ tuple $envAll | include "helm-toolkit.snippets.release_uuid" | indent 8 }}
    spec:
      serviceAccountName: {{ $serviceAccountName }}
      restartPolicy: {{ $restartPolicy }}
      {{ tuple $envAll "ks_endpoints" | include "helm-toolkit.snippets.kubernetes_image_pull_secrets" | indent 6 }}
      nodeSelector:
{{ toYaml $nodeSelector | indent 8 }}
{{- if $tolerationsEnabled }}
{{ tuple $envAll $serviceName | include "helm-toolkit.snippets.kubernetes_tolerations" | indent 6 }}
{{- end}}
      initContainers:
{{ tuple $envAll "ks_endpoints" list | include "helm-toolkit.snippets.kubernetes_entrypoint_init_container" | indent 8 }}
      containers:
{{- range $key1, $osServiceType := $serviceTypes }}
{{- range $key2, $osServiceEndPoint := tuple "admin" "internal" "public" }}
        - name: {{ printf "%s-%s-%s" $osServiceType "ks-endpoints" $osServiceEndPoint | quote }}
          image: {{ $envAll.Values.images.tags.ks_endpoints }}
          imagePullPolicy: {{ $envAll.Values.images.pull_policy }}
{{ tuple $envAll $envAll.Values.pod.resources.jobs.ks_endpoints | include "helm-toolkit.snippets.kubernetes_resources" | indent 10 }}
          command:
            - /bin/bash
            - -c
            - /tmp/ks-endpoints.sh
          volumeMounts:
            - name: pod-tmp
              mountPath: /tmp
            - name: ks-endpoints-sh
              mountPath: /tmp/ks-endpoints.sh
              subPath: ks-endpoints.sh
              readOnly: true
{{ dict "enabled" true "name" $tlsSecret "ca" true | include "helm-toolkit.snippets.tls_volume_mount" | indent 12 }}
          env:
{{- with $env := dict "ksUserSecret" $envAll.Values.secrets.identity.admin "useCA" (ne $tlsSecret "") }}
{{- include "helm-toolkit.snippets.keystone_openrc_env_vars" $env | indent 12 }}
{{- end }}
            - name: OS_SVC_ENDPOINT
              value: {{ $osServiceEndPoint | quote }}
            - name: OS_SERVICE_NAME
              value: {{ tuple $osServiceType $envAll | include "helm-toolkit.endpoints.keystone_endpoint_name_lookup" }}
            - name: OS_SERVICE_TYPE
              value: {{ $osServiceType | quote }}
            - name: OS_SERVICE_ENDPOINT
              value: {{ tuple $osServiceType $osServiceEndPoint "api" $envAll | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" | quote }}
{{- end }}
{{- end }}
      volumes:
        - name: pod-tmp
          emptyDir: {}
        - name: ks-endpoints-sh
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
{{- end }}
