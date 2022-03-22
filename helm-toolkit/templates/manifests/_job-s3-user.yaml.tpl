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

# This function creates a manifest for s3 user management.
# It can be used in charts dict created similar to the following:
# {- $s3UserJob := dict "envAll" . "serviceName" "elasticsearch" }
# { $s3UserJob | include "helm-toolkit.manifests.job_s3_user" }

{{- define "helm-toolkit.manifests.job_s3_user" -}}
{{- $envAll := index . "envAll" -}}
{{- $serviceName := index . "serviceName" -}}
{{- $jobAnnotations := index . "jobAnnotations" -}}
{{- $jobLabels := index . "jobLabels" -}}
{{- $nodeSelector := index . "nodeSelector" | default ( dict $envAll.Values.labels.job.node_selector_key $envAll.Values.labels.job.node_selector_value ) -}}
{{- $tolerationsEnabled := index . "tolerationsEnabled" | default false -}}
{{- $configMapBin := index . "configMapBin" | default (printf "%s-%s" $serviceName "bin" ) -}}
{{- $configMapCeph := index . "configMapCeph" | default (printf "ceph-etc" ) -}}
{{- $secretBin := index . "secretBin" -}}
{{- $backoffLimit := index . "backoffLimit" | default "1000" -}}
{{- $activeDeadlineSeconds := index . "activeDeadlineSeconds" -}}
{{- $serviceNamePretty := $serviceName | replace "_" "-" -}}
{{- $s3UserSecret := index $envAll.Values.secrets.rgw $serviceName -}}

{{- $serviceAccountName := printf "%s-%s" $serviceNamePretty "s3-user" }}
{{ tuple $envAll "s3_user" $serviceAccountName | include "helm-toolkit.snippets.kubernetes_pod_rbac_serviceaccount" }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ printf "%s-%s" $serviceNamePretty "s3-user" | quote }}
  labels:
{{ tuple $envAll $serviceName "s3-user" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 4 }}
{{- if $jobLabels }}
{{ toYaml $jobLabels | indent 4 }}
{{- end }}
  annotations:
    "helm.sh/hook-delete-policy": before-hook-creation
    {{ tuple $envAll | include "helm-toolkit.snippets.release_uuid" }}
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
{{ tuple $envAll $serviceName "s3-user" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 8 }}
{{- if $jobLabels }}
{{ toYaml $jobLabels | indent 8 }}
{{- end }}
    spec:
      serviceAccountName: {{ $serviceAccountName | quote }}
      restartPolicy: OnFailure
      {{ tuple $envAll "s3_user" | include "helm-toolkit.snippets.kubernetes_image_pull_secrets" | indent 6 }}
      nodeSelector:
{{ toYaml $nodeSelector | indent 8 }}
{{- if $tolerationsEnabled }}
{{ tuple $envAll $serviceName | include "helm-toolkit.snippets.kubernetes_tolerations" | indent 6 }}
{{- end}}
      initContainers:
{{ tuple $envAll "s3_user" list | include "helm-toolkit.snippets.kubernetes_entrypoint_init_container" | indent 8 }}
        - name: ceph-keyring-placement
          image: {{ $envAll.Values.images.tags.ceph_key_placement }}
          imagePullPolicy: {{ $envAll.Values.images.pull_policy }}
          command:
            - /tmp/ceph-admin-keyring.sh
          volumeMounts:
            - name: pod-tmp
              mountPath: /tmp
            - name: etcceph
              mountPath: /etc/ceph
            - name: ceph-keyring-sh
              mountPath: /tmp/ceph-admin-keyring.sh
              subPath: ceph-admin-keyring.sh
              readOnly: true
            {{- if empty $envAll.Values.conf.ceph.admin_keyring }}
            - name: ceph-keyring
              mountPath: /tmp/client-keyring
              subPath: key
              readOnly: true
            {{ end }}
      containers:
        - name: s3-user
          image: {{ $envAll.Values.images.tags.s3_user }}
          imagePullPolicy: {{ $envAll.Values.images.pull_policy }}
{{ tuple $envAll $envAll.Values.pod.resources.jobs.s3_user | include "helm-toolkit.snippets.kubernetes_resources" | indent 10 }}
          command:
            - /bin/bash
            - -c
            - /tmp/create-s3-user.sh
          env:
{{- with $env := dict "s3AdminSecret" $envAll.Values.secrets.rgw.admin }}
{{- include "helm-toolkit.snippets.rgw_s3_admin_env_vars" $env | indent 12 }}
{{- end }}
{{- include "helm-toolkit.snippets.rgw_s3_user_env_vars" $envAll | indent 12 }}
            - name: RGW_HOST
              value: {{ tuple "ceph_object_store" "internal" "api" $envAll | include "helm-toolkit.endpoints.host_and_port_endpoint_uri_lookup" }}
          volumeMounts:
            - name: pod-tmp
              mountPath: /tmp
            - name: create-s3-user-sh
              mountPath: /tmp/create-s3-user.sh
              subPath: create-s3-user.sh
              readOnly: true
            - name: etcceph
              mountPath: /etc/ceph
            - name: ceph-etc
              mountPath: /etc/ceph/ceph.conf
              subPath: ceph.conf
              readOnly: true
            {{- if empty $envAll.Values.conf.ceph.admin_keyring }}
            - name: ceph-keyring
              mountPath: /tmp/client-keyring
              subPath: key
              readOnly: true
            {{ end }}
      volumes:
        - name: pod-tmp
          emptyDir: {}
        - name: create-s3-user-sh
{{- if $secretBin }}
          secret:
            secretName: {{ $secretBin | quote }}
            defaultMode: 0555
{{- else }}
          configMap:
            name: {{ $configMapBin | quote }}
            defaultMode: 0555
{{- end }}
        - name: ceph-keyring-sh
          configMap:
            name: {{ $configMapBin | quote }}
            defaultMode: 0555
        - name: etcceph
          emptyDir: {}
        - name: ceph-etc
          configMap:
            name: {{ $configMapCeph | quote }}
            defaultMode: 0444
        {{- if empty $envAll.Values.conf.ceph.admin_keyring }}
        - name: ceph-keyring
          secret:
            secretName: pvc-ceph-client-key
        {{ end }}
{{- end -}}
