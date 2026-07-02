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
  identity:
    openrc:
      exclude_vars: []
      extra_vars: []
usage: |
  {{ include "helm-toolkit.snippets.keystone_openrc_env_vars" ( dict "ksUserSecret" .Values.secrets.identity.admin ) }}

  To use an alternative auth plugin (e.g. v3oidcaccesstoken), exclude unneeded
  vars and add plugin-specific ones:

  {{ include "helm-toolkit.snippets.keystone_openrc_env_vars" ( dict "ksUserSecret" .Values.secrets.identity.admin "excludeVars" (list "OS_USERNAME" "OS_PASSWORD" "OS_USER_DOMAIN_NAME") "extraVars" (list (dict "name" "OS_AUTH_TYPE" "value" "v3oidcaccesstoken") (dict "name" "OS_ACCESS_TOKEN" "secretKeyRef" (dict "name" "my-oidc-secret" "key" "access-token")) (dict "name" "OS_IDENTITY_PROVIDER" "value" "myidp") (dict "name" "OS_PROTOCOL" "value" "mapped")) ) }}

  See https://docs.openstack.org/keystoneauth/2026.1/plugin-options.html for
  available auth plugins and their required environment variables.
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
{{- $ksUserSecret := .ksUserSecret -}}
{{- $envAll := .envAll | default dict -}}
{{- $identityOpenrc := dict -}}
{{- if hasKey $envAll "Values" -}}
{{- if hasKey $envAll.Values "identity" -}}
{{- if hasKey $envAll.Values.identity "openrc" -}}
{{- $identityOpenrc = $envAll.Values.identity.openrc -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $excludeVars := ($identityOpenrc.exclude_vars | default list) -}}
{{- if hasKey . "excludeVars" -}}{{- $excludeVars = .excludeVars -}}{{- end -}}
{{- $extraVars := ($identityOpenrc.extra_vars | default list) -}}
{{- if hasKey . "extraVars" -}}{{- $extraVars = .extraVars -}}{{- end -}}
{{- if not (has "OS_IDENTITY_API_VERSION" $excludeVars) }}
- name: OS_IDENTITY_API_VERSION
  value: "3"
{{- end }}
{{- if not (has "OS_AUTH_URL" $excludeVars) }}
- name: OS_AUTH_URL
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_AUTH_URL
{{- end }}
{{- if not (has "OS_REGION_NAME" $excludeVars) }}
- name: OS_REGION_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_REGION_NAME
{{- end }}
{{- if not (has "OS_INTERFACE" $excludeVars) }}
- name: OS_INTERFACE
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_INTERFACE
{{- end }}
{{- if not (has "OS_ENDPOINT_TYPE" $excludeVars) }}
- name: OS_ENDPOINT_TYPE
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_INTERFACE
{{- end }}
{{- if not (has "OS_PROJECT_DOMAIN_NAME" $excludeVars) }}
- name: OS_PROJECT_DOMAIN_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PROJECT_DOMAIN_NAME
{{- end }}
{{- if not (has "OS_PROJECT_NAME" $excludeVars) }}
- name: OS_PROJECT_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PROJECT_NAME
{{- end }}
{{- if not (has "OS_USER_DOMAIN_NAME" $excludeVars) }}
- name: OS_USER_DOMAIN_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_USER_DOMAIN_NAME
{{- end }}
{{- if not (has "OS_USERNAME" $excludeVars) }}
- name: OS_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_USERNAME
{{- end }}
{{- if not (has "OS_PASSWORD" $excludeVars) }}
- name: OS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PASSWORD
{{- end }}
{{- if not (has "OS_DEFAULT_DOMAIN" $excludeVars) }}
- name: OS_DEFAULT_DOMAIN
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_DEFAULT_DOMAIN
{{- end }}
{{- if and $useCA (not (has "OS_CACERT" $excludeVars)) }}
- name: OS_CACERT
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_CACERT
{{- end }}
{{- range $extraVars }}
- name: {{ .name }}
{{- if hasKey . "value" }}
  value: {{ .value | quote }}
{{- else if hasKey . "secretKeyRef" }}
  valueFrom:
    secretKeyRef:
      name: {{ .secretKeyRef.name }}
      key: {{ .secretKeyRef.key }}
{{- else if hasKey . "configMapKeyRef" }}
  valueFrom:
    configMapKeyRef:
      name: {{ .configMapKeyRef.name }}
      key: {{ .configMapKeyRef.key }}
{{- end }}
{{- end }}
{{- end }}
