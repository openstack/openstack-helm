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

{{- define "helm-toolkit.manifests.job_rabbit_init" -}}
{{- $envAll := index . "envAll" -}}
{{- $serviceName := index . "serviceName" -}}
{{- $jobAnnotations := index . "jobAnnotations" -}}
{{- $jobLabels := index . "jobLabels" -}}
{{- $nodeSelector := index . "nodeSelector" | default ( dict $envAll.Values.labels.job.node_selector_key $envAll.Values.labels.job.node_selector_value ) -}}
{{- $tolerationsEnabled := index . "tolerationsEnabled" | default false -}}
{{- $configMapBin := index . "configMapBin" | default (printf "%s-%s" $serviceName "bin" ) -}}
{{- $serviceUser := index . "serviceUser" | default $serviceName -}}
{{- $secretBin := index . "secretBin" -}}
{{- $backoffLimit := index . "backoffLimit" | default "1000" -}}
{{- $activeDeadlineSeconds := index . "activeDeadlineSeconds" -}}
{{- $serviceUserPretty := $serviceUser | replace "_" "-" -}}
{{- $serviceNamePretty := $serviceName | replace "_" "-" -}}
{{- $tlsPath := index . "tlsPath" | default "/etc/rabbitmq/certs" -}}
{{- $tlsSecret := index . "tlsSecret" | default "" -}}

{{- $serviceAccountName := printf "%s-%s" $serviceUserPretty "rabbit-init" }}
{{ tuple $envAll "rabbit_init" $serviceAccountName | include "helm-toolkit.snippets.kubernetes_pod_rbac_serviceaccount" }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ printf "%s-%s" $serviceUserPretty "rabbit-init" | quote }}
  labels:
{{ tuple $envAll $serviceName "rabbit-init" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 4 }}
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
{{ tuple $envAll $serviceName "rabbit-init" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 8 }}
{{- if $jobLabels }}
{{ toYaml $jobLabels | indent 8 }}
{{- end }}
      annotations:
{{ tuple $envAll | include "helm-toolkit.snippets.release_uuid" | indent 8 }}
    spec:
      serviceAccountName: {{ $serviceAccountName | quote }}
      restartPolicy: OnFailure
      {{ tuple $envAll "rabbit_init" | include "helm-toolkit.snippets.kubernetes_image_pull_secrets" | indent 6 }}
      nodeSelector:
{{ toYaml $nodeSelector | indent 8 }}
{{- if $tolerationsEnabled }}
{{ tuple $envAll $serviceName | include "helm-toolkit.snippets.kubernetes_tolerations" | indent 6 }}
{{- end}}
      initContainers:
{{ tuple $envAll "rabbit_init" list | include "helm-toolkit.snippets.kubernetes_entrypoint_init_container" | indent 8 }}
      containers:
        - name: rabbit-init
          image: {{ $envAll.Values.images.tags.rabbit_init | quote }}
          imagePullPolicy: {{ $envAll.Values.images.pull_policy | quote }}
{{ tuple $envAll $envAll.Values.pod.resources.jobs.rabbit_init | include "helm-toolkit.snippets.kubernetes_resources" | indent 10 }}
          command:
            - /bin/bash
            - -c
            - /tmp/rabbit-init.sh
          volumeMounts:
            - name: pod-tmp
              mountPath: /tmp
            - name: rabbit-init-sh
              mountPath: /tmp/rabbit-init.sh
              subPath: rabbit-init.sh
              readOnly: true
{{- if $envAll.Values.manifests.certificates }}
{{- dict "enabled" $envAll.Values.manifests.certificates "name" $tlsSecret "path" $tlsPath | include "helm-toolkit.snippets.tls_volume_mount" | indent 12 }}
{{- end }}
          env:
          - name: RABBITMQ_ADMIN_CONNECTION
            valueFrom:
              secretKeyRef:
                name: {{ $envAll.Values.secrets.oslo_messaging.admin }}
                key: RABBITMQ_CONNECTION
          - name: RABBITMQ_USER_CONNECTION
            valueFrom:
              secretKeyRef:
                name: {{ index $envAll.Values.secrets.oslo_messaging $serviceName }}
                key: RABBITMQ_CONNECTION
{{- if $envAll.Values.conf.rabbitmq }}
          - name: RABBITMQ_AUXILIARY_CONFIGURATION
            value: {{ toJson $envAll.Values.conf.rabbitmq | quote }}
{{- end }}
{{- if and $envAll.Values.manifests.certificates (ne $tlsSecret "") }}
          - name: RABBITMQ_X509
            value: "REQUIRE X509"
          - name: USER_CERT_PATH
            value: {{ $tlsPath | quote }}
{{- end }}
      volumes:
        - name: pod-tmp
          emptyDir: {}
        - name: rabbit-init-sh
{{- if $secretBin }}
          secret:
            secretName: {{ $secretBin | quote }}
            defaultMode: 0555
{{- else }}
          configMap:
            name: {{ $configMapBin | quote }}
            defaultMode: 0555
{{- end }}
{{- if $envAll.Values.manifests.certificates }}
{{- dict "enabled" $envAll.Values.manifests.certificates "name" $tlsSecret | include "helm-toolkit.snippets.tls_volume" | indent 8 }}
{{- end }}
{{- end -}}
