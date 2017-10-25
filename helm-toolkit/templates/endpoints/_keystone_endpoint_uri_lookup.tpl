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

# This function returns the endpoint uri for a service, it takes an tuple
# input in the form: service-type, endpoint-class, port-name. eg:
# { tuple "orchestration" "public" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }
# will return the appropriate URI.

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
{{- $endpointHostname := index .host_fqdn_override $endpoint | default .host_fqdn_override.default | default $endpointClusterHostname }}
{{- printf "%s://%s:%1.f%s" $endpointScheme $endpointHostname $endpointPort $endpointPath -}}
{{- end -}}
{{- end -}}
