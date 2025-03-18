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

{{- define "helm-toolkit.snippets.rgw_s3_admin_env_vars" }}
{{- $s3AdminSecret := .s3AdminSecret }}
- name: S3_ADMIN_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ $s3AdminSecret }}
      key: S3_ADMIN_USERNAME
- name: S3_ADMIN_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ $s3AdminSecret }}
      key: S3_ADMIN_ACCESS_KEY
- name: S3_ADMIN_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ $s3AdminSecret }}
      key: S3_ADMIN_SECRET_KEY
{{- end }}
