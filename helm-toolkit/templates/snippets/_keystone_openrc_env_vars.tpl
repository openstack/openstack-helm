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
  Returns a set of container enviorment variables, equivlant to an openrc for
  use with keystone based command line clients.
values: |
  secrets:
    identity:
      admin: example-keystone-admin
usage: |
  {{ include "helm-toolkit.snippets.keystone_openrc_env_vars" ( dict "ksUserSecret" .Values.secrets.identity.admin ) }}
return: |
  - name: OS_IDENTITY_API_VERSION
    value: "3"
  - name: OS_AUTH_URL
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_AUTH_URL
  - name: OS_REGION_NAME
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_REGION_NAME
  - name: OS_INTERFACE
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_INTERFACE
  - name: OS_ENDPOINT_TYPE
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_INTERFACE
  - name: OS_PROJECT_DOMAIN_NAME
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_PROJECT_DOMAIN_NAME
  - name: OS_PROJECT_NAME
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_PROJECT_NAME
  - name: OS_USER_DOMAIN_NAME
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_USER_DOMAIN_NAME
  - name: OS_USERNAME
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_USERNAME
  - name: OS_PASSWORD
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_PASSWORD
  - name: OS_CACERT
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_CACERT
*/}}

{{- define "helm-toolkit.snippets.keystone_openrc_env_vars" }}
{{- $useCA := .useCA -}}
{{- $ksUserSecret := .ksUserSecret }}
- name: OS_IDENTITY_API_VERSION
  value: "3"
- name: OS_AUTH_URL
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_AUTH_URL
- name: OS_REGION_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_REGION_NAME
- name: OS_INTERFACE
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_INTERFACE
- name: OS_ENDPOINT_TYPE
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_INTERFACE
- name: OS_PROJECT_DOMAIN_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PROJECT_DOMAIN_NAME
- name: OS_PROJECT_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PROJECT_NAME
- name: OS_USER_DOMAIN_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_USER_DOMAIN_NAME
- name: OS_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_USERNAME
- name: OS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PASSWORD
- name: OS_DEFAULT_DOMAIN
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_DEFAULT_DOMAIN
{{- if $useCA }}
- name: OS_CACERT
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_CACERT
{{- end }}
{{- end }}
