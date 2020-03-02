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

# This function creates a manifest for linking an s3 bucket to an s3 user.
# It can be used in charts dict created similar to the following:
# {- $s3BucketJob := dict "envAll" . "serviceName" "elasticsearch" }
# { $s3BucketJob | include "helm-toolkit.manifests.job_s3_bucket" }

{{- define "helm-toolkit.manifests.job_s3_bucket" -}}
{{- $envAll := index . "envAll" -}}
{{- $serviceName := index . "serviceName" -}}
{{- $nodeSelector := index . "nodeSelector" | default ( dict $envAll.Values.labels.job.node_selector_key $envAll.Values.labels.job.node_selector_value ) -}}
{{- $configMapBin := index . "configMapBin" | default (printf "%s-%s" $serviceName "bin" ) -}}
{{- $configMapCeph := index . "configMapCeph" | default (printf "ceph-etc" ) -}}
{{- $secretBin := index . "secretBin" -}}
{{- $backoffLimit := index . "backoffLimit" | default "1000" -}}
{{- $activeDeadlineSeconds := index . "activeDeadlineSeconds" -}}
{{- $serviceNamePretty := $serviceName | replace "_" "-" -}}
{{- $s3UserSecret := index $envAll.Values.secrets.rgw $serviceName -}}
{{- $s3Bucket := index . "s3Bucket" | default $serviceName }}

{{- $serviceAccountName := printf "%s-%s" $serviceNamePretty "s3-bucket" }}
{{ tuple $envAll "s3_bucket" $serviceAccountName | include "helm-toolkit.snippets.kubernetes_pod_rbac_serviceaccount" }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ printf "%s-%s" $serviceNamePretty "s3-bucket" | quote }}
  annotations:
    {{ tuple $envAll | include "helm-toolkit.snippets.release_uuid" }}
spec:
  backoffLimit: {{ $backoffLimit }}
{{- if $activeDeadlineSeconds }}
  activeDeadlineSeconds: {{ $activeDeadlineSeconds }}
{{- end }}
  template:
    metadata:
      labels:
{{ tuple $envAll $serviceName "s3-bucket" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 8 }}
    spec:
      serviceAccountName: {{ $serviceAccountName | quote }}
      restartPolicy: OnFailure
      nodeSelector:
{{ toYaml $nodeSelector | indent 8 }}
      initContainers:
{{ tuple $envAll "s3_bucket" list | include "helm-toolkit.snippets.kubernetes_entrypoint_init_container" | indent 8 }}
      containers:
        - name: s3-bucket
          image: {{ $envAll.Values.images.tags.s3_bucket }}
          imagePullPolicy: {{ $envAll.Values.images.pull_policy }}
{{ tuple $envAll $envAll.Values.pod.resources.jobs.s3_bucket | include "helm-toolkit.snippets.kubernetes_resources" | indent 10 }}
          command:
            - /bin/bash
            - -c
            - /tmp/create-s3-bucket.sh
          env:
{{- with $env := dict "s3AdminSecret" $envAll.Values.secrets.rgw.admin }}
{{- include "helm-toolkit.snippets.rgw_s3_admin_env_vars" $env | indent 12 }}
{{- end }}
{{- with $env := dict "s3UserSecret" $s3UserSecret }}
{{- include "helm-toolkit.snippets.rgw_s3_user_env_vars" $env | indent 12 }}
{{- end }}
            - name: S3_BUCKET
              value: {{ $s3Bucket }}
            - name: RGW_HOST
              value: {{ tuple "ceph_object_store" "internal" "api" $envAll | include "helm-toolkit.endpoints.host_and_port_endpoint_uri_lookup" }}
            - name: RGW_PROTO
              value: {{ tuple "ceph_object_store" "internal" "api" $envAll | include "helm-toolkit.endpoints.keystone_endpoint_scheme_lookup" }}
          volumeMounts:
            - name: pod-tmp
              mountPath: /tmp
            - name: s3-bucket-sh
              mountPath: /tmp/create-s3-bucket.sh
              subPath: create-s3-bucket.sh
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
        - name: s3-bucket-sh
{{- if $secretBin }}
          secret:
            secretName: {{ $secretBin | quote }}
            defaultMode: 0555
{{- else }}
          configMap:
            name: {{ $configMapBin | quote }}
            defaultMode: 0555
{{- end }}
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
