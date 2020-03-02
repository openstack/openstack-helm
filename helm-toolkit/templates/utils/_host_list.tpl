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
  Returns a list of unique hosts for an endpoint, in yaml.
values: |
  endpoints:
    cluster_domain_suffix: cluster.local
    oslo_db:
      hosts:
        default: mariadb
      host_fqdn_override:
        default: mariadb
usage: |
  {{ tuple "oslo_db" "internal" . | include "helm-toolkit.utils.host_list" }}
return: |
  hosts:
  - mariadb
  - mariadb.default
*/}}

{{- define "helm-toolkit.utils.host_list" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $context := index . 2 -}}
{{- $host_fqdn := tuple $type $endpoint $context | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}
{{- $host_namespaced := tuple $type $endpoint $context | include "helm-toolkit.endpoints.hostname_namespaced_endpoint_lookup" }}
{{- $host_short := tuple $type $endpoint $context | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
{{/* It is important that the FQDN host is 1st in this list, to ensure other function can use the 1st element for cert gen CN etc */}}
{{- $host_list := list $host_fqdn $host_namespaced $host_short | uniq }}
{{- dict "hosts" $host_list | toYaml }}
{{- end -}}
