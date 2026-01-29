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
  Returns a set of container failover environment variables, equivlant to an openrc for
  use with keystone based command line clients.
values: |
  secrets:
    identity:
      admin: example-keystone-admin
usage: |
  {{ include "helm-toolkit.snippets.keystone_openrc_failover_env_vars" ( dict "ksUserSecret" .Values.secrets.identity.admin ) }}
return: |
  - name: OS_AUTH_URL_FAILOVER
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_AUTH_URL_FAILOVER
  - name: OS_REGION_NAME_FAILOVER
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_REGION_NAME_FAILOVER
  - name: OS_INTERFACE_FAILOVER
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_INTERFACE_FAILOVER
  - name: OS_PROJECT_DOMAIN_NAME_FAILOVER
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_PROJECT_DOMAIN_NAME_FAILOVER
  - name: OS_PROJECT_NAME_FAILOVER
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_PROJECT_NAME_FAILOVER
  - name: OS_USER_DOMAIN_NAME_FAILOVER
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_USER_DOMAIN_NAME_FAILOVER
  - name: OS_USERNAME_FAILOVER
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_USERNAME_FAILOVER
  - name: OS_PASSWORD_FAILOVER
    valueFrom:
      secretKeyRef:
        name: example-keystone-admin
        key: OS_PASSWORD_FAILOVER
*/}}

{{- define "helm-toolkit.snippets.keystone_openrc_failover_env_vars" }}
{{- $useCA := .useCA -}}
{{- $ksUserSecret := .ksUserSecret }}
- name: OS_AUTH_URL_FAILOVER
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_AUTH_URL_FAILOVER
- name: OS_REGION_NAME_FAILOVER
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_REGION_NAME_FAILOVER
- name: OS_INTERFACE_FAILOVER
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_INTERFACE_FAILOVER
- name: OS_PROJECT_DOMAIN_NAME_FAILOVER
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PROJECT_DOMAIN_NAME_FAILOVER
- name: OS_PROJECT_NAME_FAILOVER
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PROJECT_NAME_FAILOVER
- name: OS_USER_DOMAIN_NAME_FAILOVER
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_USER_DOMAIN_NAME_FAILOVER
- name: OS_USERNAME_FAILOVER
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_USERNAME_FAILOVER
- name: OS_PASSWORD_FAILOVER
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PASSWORD_FAILOVER
- name: OS_DEFAULT_DOMAIN_FAILOVER
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_DEFAULT_DOMAIN_FAILOVER
{{- end }}
