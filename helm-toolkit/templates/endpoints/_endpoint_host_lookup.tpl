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
  Resolves either the fully qualified hostname, of if defined in the host field
  IPv4 for an endpoint.
examples:
  - values: |
      endpoints:
        cluster_domain_suffix: cluster.local
        oslo_db:
          hosts:
            default: mariadb
          host_fqdn_override:
            default: null
    usage: |
      {{ tuple "oslo_db" "internal" . | include "helm-toolkit.endpoints.endpoint_host_lookup" }}
    return: |
      mariadb.default.svc.cluster.local
  - values: |
      endpoints:
        cluster_domain_suffix: cluster.local
        oslo_db:
          hosts:
            default:
             host: mariadb
          host_fqdn_override:
            default: null
    usage: |
      {{ tuple "oslo_db" "internal" . | include "helm-toolkit.endpoints.endpoint_host_lookup" }}
    return: |
      mariadb.default.svc.cluster.local
  - values: |
      endpoints:
        cluster_domain_suffix: cluster.local
        oslo_db:
          hosts:
            default: 127.0.0.1
          host_fqdn_override:
            default: null
    usage: |
      {{ tuple "oslo_db" "internal" . | include "helm-toolkit.endpoints.endpoint_host_lookup" }}
    return: |
      127.0.0.1
  - values: |
      endpoints:
        cluster_domain_suffix: cluster.local
        oslo_db:
          hosts:
            default:
             host: 127.0.0.1
          host_fqdn_override:
            default: null
    usage: |
      {{ tuple "oslo_db" "internal" . | include "helm-toolkit.endpoints.endpoint_host_lookup" }}
    return: |
      127.0.0.1
*/}}

{{- define "helm-toolkit.endpoints.endpoint_host_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $context := index . 2 -}}
{{- $endpointMap := index $context.Values.endpoints ( $type | replace "-" "_" ) }}
{{- $endpointScheme := $endpointMap.scheme }}
{{- $_ := set $context.Values "__endpointHost" ( index $endpointMap.hosts $endpoint | default $endpointMap.hosts.default ) }}
{{- if kindIs "map" $context.Values.__endpointHost }}
{{- $_ := set $context.Values "__endpointHost" ( index $context.Values.__endpointHost "host" ) }}
{{- end }}
{{- $endpointHost := $context.Values.__endpointHost }}
{{- if regexMatch "[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+" $endpointHost }}
{{- $endpointHostname := printf "%s" $endpointHost }}
{{- printf "%s" $endpointHostname -}}
{{- else }}
{{- $endpointHostname := tuple $type $endpoint $context | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}
{{- printf "%s" $endpointHostname -}}
{{- end }}
{{- end -}}
