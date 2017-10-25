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

# This function returns hostnames from endpoint definitions for use cases
# where the uri style return is not appropriate, and only the short hostname or
# kubernetes servicename is used or relevant in the template:
# { tuple "memcache" "internal" . | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }
# returns: the short internal hostname, which will also match the service name

{{- define "helm-toolkit.endpoints.hostname_short_endpoint_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $context := index . 2 -}}
{{- $typeYamlSafe := $type | replace "-" "_" }}
{{- $endpointMap := index $context.Values.endpoints $typeYamlSafe }}
{{- with $endpointMap -}}
{{- $endpointScheme := .scheme }}
{{- $endpointHost := index .hosts $endpoint | default .hosts.default}}
{{- $endpointHostname := printf "%s" $endpointHost }}
{{- printf "%s" $endpointHostname -}}
{{- end -}}
{{- end -}}
