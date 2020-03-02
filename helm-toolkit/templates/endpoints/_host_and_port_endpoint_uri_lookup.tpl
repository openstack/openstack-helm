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
  Resolves 'hostname:port' for an endpoint
examples:
  - values: |
      endpoints:
        cluster_domain_suffix: cluster.local
        oslo_db:
          hosts:
            default: mariadb
          host_fqdn_override:
            default: null
          port:
            mysql:
              default: 3306
    usage: |
      {{ tuple "oslo_db" "internal" "mysql" . | include "helm-toolkit.endpoints.host_and_port_endpoint_uri_lookup" }}
    return: |
      mariadb.default.svc.cluster.local:3306
  - values: |
      endpoints:
        cluster_domain_suffix: cluster.local
        oslo_db:
          hosts:
            default: 127.0.0.1
          host_fqdn_override:
            default: null
          port:
            mysql:
              default: 3306
    usage: |
      {{ tuple "oslo_db" "internal" "mysql" . | include "helm-toolkit.endpoints.host_and_port_endpoint_uri_lookup" }}
    return: |
      127.0.0.1:3306
*/}}

{{- define "helm-toolkit.endpoints.host_and_port_endpoint_uri_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $port := index . 2 -}}
{{- $context := index . 3 -}}
{{- $endpointPort := tuple $type $endpoint $port $context | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
{{- $endpointHostname := tuple $type $endpoint $context | include "helm-toolkit.endpoints.endpoint_host_lookup" }}
{{- printf "%s:%s" $endpointHostname $endpointPort -}}
{{- end -}}
