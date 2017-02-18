# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This file is required because we use a slightly different endpoint layout in
# the values yaml, until we can make this change for all services.


# this function returns the endpoint uri for a service, it takes an tuple
# input in the form: service-type, endpoint-class, port-name. eg:
# { tuple "orchestration" "public" "api" . | include "helm-toolkit.endpoint_type_lookup_addr" }
# will return the appropriate URI. Once merged this should phase out the above.

{{- define "helm-toolkit.endpoint_type_lookup_addr" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $port := index . 2 -}}
{{- $context := index . 3 -}}
{{- $endpointMap := index $context.Values.endpoints $type }}
{{- $fqdn := $context.Release.Namespace -}}
{{- if $context.Values.endpoints.fqdn -}}
{{- $fqdn := $context.Values.endpoints.fqdn -}}
{{- end -}}
{{- with $endpointMap -}}
{{- $endpointScheme := .scheme }}
{{- $endpointHost := index .hosts $endpoint | default .hosts.default}}
{{- $endpointPort := index .port $port }}
{{- $endpointPath := .path }}
{{- printf "%s://%s.%s:%1.f%s" $endpointScheme $endpointHost $fqdn $endpointPort $endpointPath  | quote -}}
{{- end -}}
{{- end -}}


#-------------------------------
# endpoint name lookup
#-------------------------------

# this function is used in endpoint management templates
# it returns the service type for an openstack service eg:
# { tuple orchestration . | include "ks_endpoint_type" }
# will return "heat"

{{- define "endpoint_name_lookup" -}}
{{- $type := index . 0 -}}
{{- $context := index . 1 -}}
{{- $endpointMap := index $context.Values.endpoints $type }}
{{- $endpointName := index $endpointMap "name" }}
{{- $endpointName | quote -}}
{{- end -}}
