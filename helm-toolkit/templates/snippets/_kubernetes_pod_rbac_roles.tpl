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
{{- $saName := index . 2 | replace "_" "-" }}
{{- $saNamespace := index . 3 -}}
{{- $releaseName := $envAll.Release.Name }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ $releaseName }}-{{ $saName }}
  namespace: {{ $saNamespace }}
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
  namespace: {{ $saNamespace }}
rules:
  - apiGroups:
      - ""
      - extensions
      - batch
      - apps
    verbs:
      - get
      - list
    resources:
      {{- range $k, $v := $deps -}}
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
      {{- end -}}
      {{ if eq $v "secrets" }}
      - secrets
      {{- end -}}
      {{- end -}}
{{- end -}}
