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

# FIXME(portdirect): it appears the port input here serves no purpose,
# and should be removed. In addition this function is bugged, do we use it?

{{/*
abstract: |
  Resolves the scheme for an endpoint
values: |
  endpoints:
    cluster_domain_suffix: cluster.local
    oslo_db:
      scheme:
        default:
          mysql+pymysql
      port:
        mysql:
          default: 3306
usage: |
  {{ tuple "oslo_db" "internal" "mysql" . | include "helm-toolkit.endpoints.keystone_endpoint_scheme_lookup" }}
return: |
  mysql+pymysql
*/}}

# This function returns the scheme for a service, it takes an tuple
# input in the form: service-type, endpoint-class, port-name. eg:
# { tuple "etcd" "internal" "client" . | include "helm-toolkit.endpoints.keystone_scheme_lookup" }
# will return the scheme setting for this particular endpoint.  In other words, for most endpoints
# it will return either 'http' or 'https'

{{- define "helm-toolkit.endpoints.keystone_endpoint_scheme_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $port := index . 2 -}}
{{- $context := index . 3 -}}
{{- $endpointMap := index $context.Values.endpoints ( $type | replace "-" "_" ) }}
{{- if kindIs "string" $endpointMap.scheme }}
{{- printf "%s" $endpointMap.scheme | default "http" -}}
{{- else -}}
{{- $endpointScheme := index $endpointMap.scheme $endpoint | default $endpointMap.scheme.default | default "http" }}
{{- printf "%s" $endpointScheme -}}
{{- end -}}
{{- end -}}
