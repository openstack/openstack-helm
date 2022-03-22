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
# {- $dbToDropJob := dict "envAll" . "serviceName" "senlin" -}
# { $dbToDropJob | include "helm-toolkit.manifests.job_db_drop_mysql" }
#
# If the service does not use oslo then the db can be managed with:
# {- $dbToDrop := dict "inputType" "secret" "adminSecret" .Values.secrets.oslo_db.admin "userSecret" .Values.secrets.oslo_db.horizon -}
# {- $dbToDropJob := dict "envAll" . "serviceName" "horizon" "dbToDrop" $dbToDrop -}
# { $dbToDropJob | include "helm-toolkit.manifests.job_db_drop_mysql" }

{{- define "helm-toolkit.manifests.job_db_drop_mysql" -}}
{{- $envAll := index . "envAll" -}}
{{- $serviceName := index . "serviceName" -}}
{{- $jobAnnotations := index . "jobAnnotations" -}}
{{- $jobLabels := index . "jobLabels" -}}
{{- $nodeSelector := index . "nodeSelector" | default ( dict $envAll.Values.labels.job.node_selector_key $envAll.Values.labels.job.node_selector_value ) -}}
{{- $tolerationsEnabled := index . "tolerationsEnabled" | default false -}}
{{- $configMapBin := index . "configMapBin" | default (printf "%s-%s" $serviceName "bin" ) -}}
{{- $configMapEtc := index . "configMapEtc" | default (printf "%s-%s" $serviceName "etc" ) -}}
{{- $dbToDrop := index . "dbToDrop" | default ( dict "adminSecret" $envAll.Values.secrets.oslo_db.admin "configFile" (printf "/etc/%s/%s.conf" $serviceName $serviceName ) "logConfigFile" (printf "/etc/%s/logging.conf" $serviceName ) "configDbSection" "database" "configDbKey" "connection" ) -}}
{{- $dbsToDrop := default (list $dbToDrop) (index . "dbsToDrop") }}
{{- $secretBin := index . "secretBin" -}}
{{- $backoffLimit := index . "backoffLimit" | default "1000" -}}
{{- $activeDeadlineSeconds := index . "activeDeadlineSeconds" -}}
{{- $serviceNamePretty := $serviceName | replace "_" "-" -}}
{{- $dbAdminTlsSecret := index . "dbAdminTlsSecret" | default "" -}}

{{- $serviceAccountName := printf "%s-%s" $serviceNamePretty "db-drop" }}
{{ tuple $envAll "db_drop" $serviceAccountName | include "helm-toolkit.snippets.kubernetes_pod_rbac_serviceaccount" }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ printf "%s-%s" $serviceNamePretty "db-drop" | quote }}
  labels:
{{ tuple $envAll $serviceName "db-drop" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 4 }}
{{- if $jobLabels }}
{{ toYaml $jobLabels | indent 4 }}
{{- end }}
  annotations:
    "helm.sh/hook": pre-delete
    "helm.sh/hook-delete-policy": hook-succeeded
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
{{ tuple $envAll $serviceName "db-drop" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 8 }}
{{- if $jobLabels }}
{{ toYaml $jobLabels | indent 8 }}
{{- end }}
    spec:
      serviceAccountName: {{ $serviceAccountName }}
      restartPolicy: OnFailure
      {{ tuple $envAll "db_drop" | include "helm-toolkit.snippets.kubernetes_image_pull_secrets" | indent 6 }}
      nodeSelector:
{{ toYaml $nodeSelector | indent 8 }}
{{- if $tolerationsEnabled }}
{{ tuple $envAll $serviceName | include "helm-toolkit.snippets.kubernetes_tolerations" | indent 6 }}
{{- end}}
      initContainers:
{{ tuple $envAll "db_drop" list | include "helm-toolkit.snippets.kubernetes_entrypoint_init_container" | indent 8 }}
      containers:
{{- range $key1, $dbToDrop := $dbsToDrop }}
{{ $dbToDropType := default "oslo" $dbToDrop.inputType }}
        - name: {{ printf "%s-%s-%d" $serviceNamePretty "db-drop" $key1 | quote }}
          image: {{ $envAll.Values.images.tags.db_drop }}
          imagePullPolicy: {{ $envAll.Values.images.pull_policy }}
{{ tuple $envAll $envAll.Values.pod.resources.jobs.db_drop | include "helm-toolkit.snippets.kubernetes_resources" | indent 10 }}
          env:
            - name: ROOT_DB_CONNECTION
              valueFrom:
                secretKeyRef:
                  name: {{ $dbToDrop.adminSecret | quote }}
                  key: DB_CONNECTION
{{- if eq $dbToDropType "oslo" }}
            - name: OPENSTACK_CONFIG_FILE
              value: {{ $dbToDrop.configFile | quote }}
            - name: OPENSTACK_CONFIG_DB_SECTION
              value: {{ $dbToDrop.configDbSection | quote }}
            - name: OPENSTACK_CONFIG_DB_KEY
              value: {{ $dbToDrop.configDbKey | quote }}
{{- end }}
{{- if $envAll.Values.manifests.certificates }}
            - name: MARIADB_X509
              value: "REQUIRE X509"
{{- end }}
{{- if eq $dbToDropType "secret" }}
            - name: DB_CONNECTION
              valueFrom:
                secretKeyRef:
                  name: {{ $dbToDrop.userSecret | quote }}
                  key: DB_CONNECTION
{{- end }}
          command:
            - /tmp/db-drop.py
          volumeMounts:
            - name: pod-tmp
              mountPath: /tmp
            - name: db-drop-sh
              mountPath: /tmp/db-drop.py
              subPath: db-drop.py
              readOnly: true

{{- if eq $dbToDropType "oslo" }}
            - name: etc-service
              mountPath: {{ dir $dbToDrop.configFile | quote }}
            - name: db-drop-conf
              mountPath: {{ $dbToDrop.configFile | quote }}
              subPath: {{ base $dbToDrop.configFile | quote }}
              readOnly: true
            - name: db-drop-conf
              mountPath: {{ $dbToDrop.logConfigFile | quote }}
              subPath: {{ base $dbToDrop.logConfigFile | quote }}
              readOnly: true
{{- end }}
{{- if $envAll.Values.manifests.certificates }}
{{- dict "enabled" $envAll.Values.manifests.certificates "name" $dbAdminTlsSecret "path" "/etc/mysql/certs" | include "helm-toolkit.snippets.tls_volume_mount" | indent 12 }}
{{- end }}
{{- end }}
      volumes:
        - name: pod-tmp
          emptyDir: {}
        - name: db-drop-sh
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
{{- dict "enabled" $envAll.Values.manifests.certificates "name" $dbAdminTlsSecret | include "helm-toolkit.snippets.tls_volume" | indent 8 }}
{{- end }}
{{- $local := dict "configMapBinFirst" true -}}
{{- range $key1, $dbToDrop := $dbsToDrop }}
{{- $dbToDropType := default "oslo" $dbToDrop.inputType }}
{{- if and (eq $dbToDropType "oslo") $local.configMapBinFirst }}
{{- $_ := set $local "configMapBinFirst" false }}
        - name: etc-service
          emptyDir: {}
        - name: db-drop-conf
          secret:
            secretName: {{ $configMapEtc | quote }}
            defaultMode: 0444
{{- end -}}
{{- end -}}
{{- end -}}
