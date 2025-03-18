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
  Returns a set of container enviorment variables, for use with the keystone
  user management jobs.
values: |
  secrets:
    identity:
      service_user: example-keystone-user
usage: |
  {{ include "helm-toolkit.snippets.keystone_user_create_env_vars" ( dict "ksUserSecret" .Values.secrets.identity.service_user "useCA" true ) }}
return: |
  - name: SERVICE_OS_REGION_NAME
    valueFrom:
      secretKeyRef:
        name: example-keystone-user
        key: OS_REGION_NAME
  - name: SERVICE_OS_PROJECT_DOMAIN_NAME
    valueFrom:
      secretKeyRef:
        name: example-keystone-user
        key: OS_PROJECT_DOMAIN_NAME
  - name: SERVICE_OS_PROJECT_NAME
    valueFrom:
      secretKeyRef:
        name: example-keystone-user
        key: OS_PROJECT_NAME
  - name: SERVICE_OS_USER_DOMAIN_NAME
    valueFrom:
      secretKeyRef:
        name: example-keystone-user
        key: OS_USER_DOMAIN_NAME
  - name: SERVICE_OS_USERNAME
    valueFrom:
      secretKeyRef:
        name: example-keystone-user
        key: OS_USERNAME
  - name: SERVICE_OS_PASSWORD
    valueFrom:
      secretKeyRef:
        name: example-keystone-user
        key: OS_PASSWORD
*/}}

{{- define "helm-toolkit.snippets.keystone_user_create_env_vars" }}
{{- $ksUserSecret := .ksUserSecret }}
- name: SERVICE_OS_REGION_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_REGION_NAME
- name: SERVICE_OS_PROJECT_DOMAIN_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PROJECT_DOMAIN_NAME
- name: SERVICE_OS_PROJECT_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PROJECT_NAME
- name: SERVICE_OS_USER_DOMAIN_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_USER_DOMAIN_NAME
- name: SERVICE_OS_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_USERNAME
- name: SERVICE_OS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PASSWORD
{{- end }}
