{{/*
Copyright 2018 The Openstack-Helm Authors.

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

{{- define "helm-toolkit.manifests.secret_ingress_tls" }}
{{- $envAll := index . "envAll" }}
{{- $endpoint := index . "endpoint" | default "public" }}
{{- $backendServiceType := index . "backendServiceType" }}
{{- $backendService := index . "backendService" | default "api" }}
{{- $host := index $envAll.Values.endpoints ( $backendServiceType | replace "-" "_" ) "host_fqdn_override" }}
{{- if $host.public }}
{{- if $host.public.tls }}
{{- if and $host.public.tls.key $host.public.tls.crt }}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ index $envAll.Values.secrets.tls ( $backendServiceType | replace "-" "_" ) $backendService $endpoint }}
type: kubernetes.io/tls
data:
  tls.crt: {{ $host.public.tls.crt | b64enc }}
  tls.key: {{ $host.public.tls.key | b64enc }}
{{- if $host.public.tls.ca }}
  ca.crt: {{ $host.public.tls.ca | b64enc }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
