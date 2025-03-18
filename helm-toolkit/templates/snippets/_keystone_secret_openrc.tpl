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

{{- define "helm-toolkit.snippets.keystone_secret_openrc" }}
{{- $userClass := index . 0 -}}
{{- $identityEndpoint := index . 1 -}}
{{- $context := index . 2 -}}
{{- $userContext := index $context.Values.endpoints.identity.auth $userClass }}
OS_AUTH_URL: {{ tuple "identity" $identityEndpoint "api" $context | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" | b64enc }}
OS_REGION_NAME: {{ $userContext.region_name | b64enc }}
OS_INTERFACE: {{ $userContext.interface | default "internal" | b64enc }}
OS_PROJECT_DOMAIN_NAME: {{ $userContext.project_domain_name | b64enc }}
OS_PROJECT_NAME: {{ $userContext.project_name | b64enc }}
OS_USER_DOMAIN_NAME: {{ $userContext.user_domain_name | b64enc }}
OS_USERNAME: {{ $userContext.username | b64enc }}
OS_PASSWORD: {{ $userContext.password | b64enc }}
OS_DEFAULT_DOMAIN: {{ $userContext.default_domain_id | default "default" | b64enc }}
{{- if $userContext.cacert }}
OS_CACERT: {{ $userContext.cacert | b64enc }}
{{- end }}
{{- end }}
