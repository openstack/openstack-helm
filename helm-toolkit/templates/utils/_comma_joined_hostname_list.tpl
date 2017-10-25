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

{{- define "helm-toolkit.utils.comma_joined_hostname_list" -}}
{{- $deps := index . 0 -}}
{{- $envAll := index . 1 -}}
{{- range $k, $v := $deps -}}{{- if $k -}},{{- end -}}{{ tuple $v.service $v.endpoint $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}{{- end -}}
{{- end -}}
