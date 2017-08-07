{{/*
Copyright 2017 The Openstack-Helm Authors.

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

{{- define "helm-toolkit.snippets.keystone_openrc_env_vars" }}
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
{{- end }}
