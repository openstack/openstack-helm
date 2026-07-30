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

{{- define "helm-toolkit.snippets.kubernetes_pod_rbac_roles" -}}
{{- $envAll := index . 0 -}}
{{- $deps := index . 1 -}}
{{- $namespace := index . 2 -}}
{{- $saName := index . 3 | replace "_" "-" }}
{{- $saNamespace := index . 4 -}}
{{- $releaseName := $envAll.Release.Name }}
{{- /*
Custom resource dependencies need rules of their own: their API group is not
one of the fixed groups below, and the resource name is not known until the
dependency names a kind. kubernetes-entrypoint reads them with a dynamic
client, so it needs get on the plural in that group. Discovery, which it uses
to find the plural, needs no rule -- it is granted to all authenticated users.
*/}}
{{- $customResources := list }}
{{- if has "custom_resources" $deps }}
{{- range $cr := (dig "custom_resources" list ($envAll.Values.__kubernetes_entrypoint_init_container.deps | default dict)) }}
{{- if eq ($cr.namespace | default $saNamespace) $namespace }}
{{- $customResources = append $customResources $cr }}
{{- end }}
{{- end }}
{{- end }}
{{- $coreResources := without $deps "custom_resources" }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ $releaseName }}-{{ $saNamespace }}-{{ $saName }}
  namespace: {{ $namespace }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ $releaseName }}-{{ $saNamespace }}-{{ $saName }}
subjects:
  - kind: ServiceAccount
    name: {{ $saName }}
    namespace: {{ $saNamespace }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ $releaseName }}-{{ $saNamespace }}-{{ $saName }}
  namespace: {{ $namespace }}
rules:
{{- if $coreResources }}
  - apiGroups:
      - ""
      - extensions
      - batch
      - apps
      - discovery.k8s.io
    verbs:
      - get
      - list
    resources:
      {{- range $k, $v := $coreResources -}}
      {{ if eq $v "daemonsets" }}
      - daemonsets
      {{- end -}}
      {{ if eq $v "jobs" }}
      - jobs
      {{- end -}}
      {{ if or (eq $v "pods") (eq $v "daemonsets") (eq $v "jobs") }}
      - pods
      {{- end -}}
      {{ if eq $v "services" }}
      - services
      - endpoints
      - endpointslices
      {{- end -}}
      {{ if eq $v "secrets" }}
      - secrets
      {{- end -}}
      {{- end -}}
{{- end }}
{{- range $cr := $customResources }}
  - apiGroups:
      - {{ regexReplaceAll "/.*$" $cr.apiVersion "" }}
    verbs:
      - get
    resources:
      {{- /* The plural is derived from the kind, which covers every kind whose
      plural is the lowercased kind plus an s. Anything irregular sets
      resource explicitly. */}}
      - {{ $cr.resource | default (printf "%ss" (lower $cr.kind)) }}
{{- end }}
{{- end -}}
