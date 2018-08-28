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

{{/*
abstract: |
  Resolves the fully qualified hostname for an endpoint
values: |
  endpoints:
    cluster_domain_suffix: cluster.local
    oslo_db:
      hosts:
        default: mariadb
      host_fqdn_override:
        default: null
usage: |
  {{ tuple "oslo_db" "internal" . | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}
return: |
  mariadb.default.svc.cluster.local
*/}}

{{- define "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $context := index . 2 -}}
{{- $endpointMap := index $context.Values.endpoints ( $type | replace "-" "_" ) }}
{{- $endpointHostNamespaced := tuple $type $endpoint $context | include "helm-toolkit.endpoints.hostname_namespaced_endpoint_lookup" }}
{{- $endpointClusterHostname := printf "%s.svc.%s" $endpointHostNamespaced $context.Values.endpoints.cluster_domain_suffix }}
{{- if kindIs "map" (index $endpointMap.host_fqdn_override $endpoint) }}
{{- $endpointHostname := index $endpointMap.host_fqdn_override $endpoint "host" | default $endpointMap.host_fqdn_override.default | default $endpointMap.host_fqdn_override.default | default $endpointClusterHostname }}
{{- printf "%s" $endpointHostname -}}
{{- else }}
{{- $endpointHostname := index $endpointMap.host_fqdn_override $endpoint | default $endpointMap.host_fqdn_override.default | default $endpointClusterHostname }}
{{- printf "%s" $endpointHostname -}}
{{- end -}}
{{- end -}}
