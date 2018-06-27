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
  This function helps resolve uri style endpoints
values: |
  endpoints:
    cluster_domain_suffix: cluster.local
    oslo_db:
      hosts:
        default: mariadb
      host_fqdn_override:
        default: null
      path: /dbname
      scheme: mysql+pymysql
      port:
        mysql:
          default: 3306
usage: |
  {{ tuple "oslo_db" "internal" "mysql" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}
return: |
  mysql+pymysql://mariadb.default.svc.cluster.local:3306/dbname
*/}}

{{- define "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $port := index . 2 -}}
{{- $context := index . 3 -}}
{{- $typeYamlSafe := $type | replace "-" "_" }}
{{- $clusterSuffix := printf "%s.%s" "svc" $context.Values.endpoints.cluster_domain_suffix }}
{{- $endpointMap := index $context.Values.endpoints $typeYamlSafe }}
{{- with $endpointMap -}}
{{- $namespace := $endpointMap.namespace | default $context.Release.Namespace }}
{{- $endpointScheme :=  index .scheme $endpoint | default .scheme.default }}
{{- $endpointHost := index .hosts $endpoint | default .hosts.default }}
{{- $endpointPortMAP := index .port $port }}
{{- $endpointPort := index $endpointPortMAP $endpoint | default (index $endpointPortMAP "default") }}
{{- $endpointPath := index .path $endpoint | default .path.default | default "/" }}
{{- $endpointClusterHostname := printf "%s.%s.%s" $endpointHost $namespace $clusterSuffix }}
{{- if regexMatch "[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+" $endpointHost }}
{{- printf "%s://%s:%1.f%s" $endpointScheme $endpointHost $endpointPort $endpointPath -}}
{{- else -}}
{{- if kindIs "map" (index .host_fqdn_override $endpoint) }}
{{- $endpointFqdnHostname := index .host_fqdn_override $endpoint "host" | default .host_fqdn_override.default | default $endpointClusterHostname }}
{{- printf "%s://%s:%1.f%s" $endpointScheme $endpointFqdnHostname $endpointPort $endpointPath -}}
{{- else }}
{{- $endpointFqdnHostname := index .host_fqdn_override $endpoint | default .host_fqdn_override.default | default $endpointClusterHostname }}
{{- printf "%s://%s:%1.f%s" $endpointScheme $endpointFqdnHostname $endpointPort $endpointPath -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
