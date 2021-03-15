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

{{- define "helm-toolkit.snippets.rgw_s3_user_env_vars" }}
{{- range $client, $user := .Values.storage.s3.clients }}
{{- $s3secret := printf "%s-s3-user-secret" ( $client | replace "_" "-" | lower ) }}
- name: {{ printf "%s_S3_USERNAME" ($client | replace "-" "_" | upper) }}
  valueFrom:
    secretKeyRef:
      name: {{ $s3secret }}
      key: USERNAME
- name: {{ printf "%s_S3_ACCESS_KEY" ($client | replace "-" "_" | upper) }}
  valueFrom:
    secretKeyRef:
      name: {{ $s3secret }}
      key: ACCESS_KEY
- name: {{ printf "%s_S3_SECRET_KEY" ($client | replace "-" "_" | upper) }}
  valueFrom:
    secretKeyRef:
      name: {{ $s3secret }}
      key: SECRET_KEY
{{- end }}
{{- end }}
