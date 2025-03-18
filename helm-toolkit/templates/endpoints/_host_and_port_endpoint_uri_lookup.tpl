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
  Resolves 'hostname:port' for an endpoint, or several hostname:port pairs for statefulset e.g
  'hostname1:port1,hostname2:port2,hostname3:port3',
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
  - values: |
      endpoints:
        oslo_cache:
          hosts:
            default: memcached
          host_fqdn_override:
            default: null
          statefulset:
            name: openstack-memcached-memcached
            replicas: 3
          port:
            memcache:
              default: 11211
    usage: |
      {{ tuple "oslo_cache" "internal" "memcache" . | include "helm-toolkit.endpoints.host_and_port_endpoint_uri_lookup" }}
    return: |
      openstack-memcached-memcached-0:11211,openstack-memcached-memcached-1:11211,openstack-memcached-memcached-2:11211
*/}}

{{- define "helm-toolkit.endpoints.host_and_port_endpoint_uri_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $port := index . 2 -}}
{{- $context := index . 3 -}}
{{- $ssMap := index $context.Values.endpoints ( $type | replace "-" "_" ) "statefulset" | default false -}}
{{- $local := dict "endpointHosts" list -}}
{{- $endpointPort := tuple $type $endpoint $port $context | include "helm-toolkit.endpoints.endpoint_port_lookup" -}}
{{- if $ssMap -}}
{{-   $endpointHostPrefix := $ssMap.name -}}
{{-   $endpointHostSuffix := tuple $type $endpoint $context | include "helm-toolkit.endpoints.endpoint_host_lookup" }}
{{-   range $podInt := until ( atoi (print $ssMap.replicas ) ) -}}
{{-     $endpointHostname := printf "%s-%d.%s:%s" $endpointHostPrefix $podInt $endpointHostSuffix $endpointPort -}}
{{-     $_ := set $local "endpointHosts" ( append $local.endpointHosts $endpointHostname ) -}}
{{-   end -}}
{{- else -}}
{{-   $endpointHostname := tuple $type $endpoint $context | include "helm-toolkit.endpoints.endpoint_host_lookup" -}}
{{-   $_ := set $local "endpointHosts" ( append $local.endpointHosts (printf "%s:%s" $endpointHostname $endpointPort) ) -}}
{{- end -}}
{{ include "helm-toolkit.utils.joinListWithComma" $local.endpointHosts }}
{{- end -}}
