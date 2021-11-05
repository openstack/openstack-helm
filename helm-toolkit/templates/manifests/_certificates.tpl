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
  Creates a certificate using jetstack
examples:
  - values: |
      endpoints:
        dashboard:
          host_fqdn_override:
            default:
              host: null
              tls:
                secretName: keystone-tls-api
                issuerRef:
                  name: ca-issuer
                  duration: 2160h
                  organization:
                    - ACME
                  commonName: keystone-api.openstack.svc.cluster.local
                  privateKey:
                    size: 2048
                  usages:
                    - server auth
                    - client auth
                  dnsNames:
                    - cluster.local
                  issuerRef:
                    name: ca-issuer
    usage: |
      {{- $opts := dict "envAll" . "service" "dashboard" "type" "internal" -}}
      {{ $opts | include "helm-toolkit.manifests.certificates" }}
    return: |
      ---
      apiVersion: cert-manager.io/v1
      kind: Certificate
      metadata:
        name: keystone-tls-api
        namespace: NAMESPACE
      spec:
        commonName: keystone-api.openstack.svc.cluster.local
        dnsNames:
        - cluster.local
        duration: 2160h
        issuerRef:
          name: ca-issuer
        privateKey:
          size: 2048
        organization:
        - ACME
        secretName: keystone-tls-api
        usages:
        - server auth
        - client auth
*/}}

{{- define "helm-toolkit.manifests.certificates" -}}
{{- $envAll := index . "envAll" -}}
{{- $service := index . "service" -}}
{{- $type := index . "type" | default "" -}}
{{- $slice := index $envAll.Values.endpoints $service "host_fqdn_override" "default" "tls" -}}
{{/* Put in some sensible default value if one is not provided by values.yaml */}}
{{/* If a dnsNames list is not in the values.yaml, it can be overridden by a passed-in parameter.
  This allows user to use other HTK method to determine the URI and pass that into this method.*/}}
{{- if not (hasKey $slice "dnsNames") -}}
{{- $hostName := tuple $service $type $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" -}}
{{- $dnsNames := list $hostName (printf "%s.%s" $hostName $envAll.Release.Namespace) (printf "%s.%s.svc.%s" $hostName $envAll.Release.Namespace $envAll.Values.endpoints.cluster_domain_suffix) -}}
{{- $_ := $dnsNames | set (index $envAll.Values.endpoints $service "host_fqdn_override" "default" "tls") "dnsNames" -}}
{{- end -}}
{{/* Default privateKey size to 4096. This can be overridden. */}}
{{- if not (hasKey $slice "privateKey") -}}
{{- $_ := dict "size" ( printf "%d" 4096 | atoi ) | set (index $envAll.Values.endpoints $service "host_fqdn_override" "default" "tls") "privateKey" -}}
{{- else if empty (index $envAll.Values.endpoints $service "host_fqdn_override" "default" "tls" "privateKey" "size") -}}
{{- $_ := ( printf "%d" 4096 | atoi ) | set (index $envAll.Values.endpoints $service "host_fqdn_override" "default" "tls" "privateKey") "size" -}}
{{- end -}}
{{/* Default duration to 3 months. Note the min is 720h. This can be overridden. */}}
{{- if not (hasKey $slice "duration") -}}
{{- $_ := printf "%s" "2190h" | set (index $envAll.Values.endpoints $service "host_fqdn_override" "default" "tls") "duration" -}}
{{- end -}}
{{/* Default renewBefore to 15 days. This can be overridden. */}}
{{- if not (hasKey $slice "renewBefore") -}}
{{- $_ := printf "%s" "360h" | set (index $envAll.Values.endpoints $service "host_fqdn_override" "default" "tls") "renewBefore" -}}
{{- end -}}
{{/* Default the usage to server auth and client auth. This can be overridden. */}}
{{- if not (hasKey $slice "usages") -}}
{{- $_ := (list "server auth" "client auth") | set (index $envAll.Values.endpoints $service "host_fqdn_override" "default" "tls") "usages" -}}
{{- end -}}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: {{ index $envAll.Values.endpoints $service "host_fqdn_override" "default" "tls" "secretName" }}
  namespace: {{ $envAll.Release.Namespace }}
spec:
{{ $slice | toYaml | indent 2 }}
{{- end -}}
