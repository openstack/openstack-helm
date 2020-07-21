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
  Creates a manifest for a services public tls secret
examples:
  - values: |
      secrets:
        tls:
          key_manager:
            api:
              public: barbican-tls-public
      endpoints:
        key_manager:
          host_fqdn_override:
            public:
              tls:
                crt: |
                  FOO-CRT
                key: |
                  FOO-KEY
                ca: |
                  FOO-CA_CRT
  usage: |
    {{- include "helm-toolkit.manifests.secret_ingress_tls" ( dict "envAll" . "backendServiceType" "key-manager" ) -}}
  return: |
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: barbican-tls-public
    type: kubernetes.io/tls
    data:
      tls.key: Rk9PLUtFWQo=
      tls.crt: Rk9PLUNSVAoKRk9PLUNBX0NSVAo=

  - values: |
      secrets:
        tls:
          key_manager:
            api:
              public: barbican-tls-public
      endpoints:
        key_manager:
          host_fqdn_override:
            public:
              tls:
                crt: |
                  FOO-CRT
                  FOO-INTERMEDIATE_CRT
                  FOO-CA_CRT
                key: |
                  FOO-KEY
  usage: |
    {{- include "helm-toolkit.manifests.secret_ingress_tls" ( dict "envAll" . "backendServiceType" "key-manager" ) -}}
  return: |
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: barbican-tls-public
    type: kubernetes.io/tls
    data:
      tls.key: Rk9PLUtFWQo=
      tls.crt: Rk9PLUNSVApGT08tSU5URVJNRURJQVRFX0NSVApGT08tQ0FfQ1JUCg==
*/}}

{{- define "helm-toolkit.manifests.secret_ingress_tls" }}
{{- $envAll := index . "envAll" }}
{{- $endpoint := index . "endpoint" | default "public" }}
{{- $backendServiceType := index . "backendServiceType" }}
{{- $backendService := index . "backendService" | default "api" }}
{{- $host := index $envAll.Values.endpoints ( $backendServiceType | replace "-" "_" ) "host_fqdn_override" }}
{{- if hasKey $host $endpoint }}
{{- $endpointHost := index $host $endpoint }}
{{- if kindIs "map" $endpointHost }}
{{- if hasKey $endpointHost "tls" }}
{{- if and $endpointHost.tls.key $endpointHost.tls.crt }}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ index $envAll.Values.secrets.tls ( $backendServiceType | replace "-" "_" ) $backendService $endpoint }}
type: kubernetes.io/tls
data:
  tls.key: {{ $endpointHost.tls.key | b64enc }}
{{- if $endpointHost.tls.ca }}
  tls.crt: {{ list $endpointHost.tls.crt $endpointHost.tls.ca | join "\n" | b64enc }}
{{- else }}
  tls.crt: {{ $endpointHost.tls.crt | b64enc }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
