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

{{- define "helm-toolkit.manifests.secret_ks_etc" -}}
{{- $envAll := index . "envAll" -}}
{{- $serviceName := index . "serviceName" -}}
{{- $serviceUserSections := index . "serviceUserSections" -}}
{{- $serviceNamePretty := $serviceName | replace "_" "-" -}}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ printf "%s-ks-etc" $serviceNamePretty | quote }}
  annotations:
    {{ tuple $envAll | include "helm-toolkit.snippets.release_uuid" }}
{{ tuple "ks_etc" $serviceName $envAll | include "helm-toolkit.snippets.custom_secret_annotations" | indent 4 }}
type: Opaque
data:
{{- range $epName, $sectionName := $serviceUserSections }}
{{- $epAuth := index $envAll.Values.endpoints.identity.auth $epName -}}
{{- $configSection := dict
  "region_name" $epAuth.region_name
  "project_name" $epAuth.project_name
  "project_domain_name" $epAuth.project_domain_name
  "user_domain_name" $epAuth.user_domain_name
  "username" $epAuth.username
  "password" $epAuth.password
-}}
{{- $configSnippet := dict $sectionName $configSection }}
{{ printf "%s_%s.conf" $serviceName $sectionName | indent 2 }}: {{ include "helm-toolkit.utils.to_oslo_conf" $configSnippet | b64enc }}
{{- end }}
{{- end -}}
