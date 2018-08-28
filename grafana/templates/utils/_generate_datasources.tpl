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

# This function generates the required datasource configuration for grafana.
# This allows us to generate an arbitrary number of datasources for grafana

{{- define "grafana.utils.generate_datasources" -}}
{{- $envAll := index . "envAll" -}}
{{- $datasources := index . "datasources" -}}
{{- $_ := set $envAll.Values "__datasources" ( list ) }}
{{- range $datasource, $config := $datasources -}}
{{- if empty $config.url -}}
{{- $datasource_url := tuple $datasource "internal" "api" $envAll | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}
{{- $_ := set $config "url" $datasource_url }}
{{- end }}
{{- if and ($config.basicAuth) (empty $config.basicAuthUser) -}}
{{- $datasource_endpoint := index $envAll.Values.endpoints $datasource -}}
{{- $datasource_user :=  $datasource_endpoint.auth.user.username -}}
{{- $_ := set $config "basicAuthUser" $datasource_user -}}
{{- end }}
{{- if and ($config.basicAuth) (empty $config.basicAuthPassword) -}}
{{- $datasource_endpoint := index $envAll.Values.endpoints $datasource -}}
{{- $datasource_password :=  $datasource_endpoint.auth.user.password -}}
{{- $_ := set $config "basicAuthPassword" $datasource_password -}}
{{- end }}
{{- $__datasources := append $envAll.Values.__datasources $config }}
{{- $_ := set $envAll.Values "__datasources" $__datasources }}
{{- end }}
apiVersion: 1
datasources:
{{ toYaml $envAll.Values.__datasources }}
{{- end -}}
