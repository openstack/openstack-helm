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
  Creates a manifest for a authenticating a registry with a secret
examples:
  - values: |
      secrets:
        oci_image_registry:
          {{ $serviceName }}: {{ $keyName }}
      endpoints:
        oci_image_registry:
          name: oci-image-registry
          auth:
            enabled: true
             {{ $serviceName }}:
                name: {{ $userName }}
                password: {{ $password }}
  usage: |
    {{- include "helm-toolkit.manifests.secret_registry" ( dict "envAll" . "registryUser" .Chart.Name ) -}}
  return: |
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: {{ $secretName }}
    type: kubernetes.io/dockerconfigjson
    data:
      dockerconfigjson: {{ $dockerAuth }}

  - values: |
      secrets:
        oci_image_registry:
          {{ $serviceName }}: {{ $keyName }}
      endpoints:
        oci_image_registry:
          name: oci-image-registry
          auth:
            enabled: true
             {{ $serviceName }}:
                name: {{ $userName }}
                password: {{ $password }}
  usage: |
    {{- include "helm-toolkit.manifests.secret_registry" ( dict "envAll" . "registryUser" .Chart.Name ) -}}
  return: |
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: {{ $secretName }}
    type: kubernetes.io/dockerconfigjson
    data:
      dockerconfigjson: {{ $dockerAuth }}
*/}}

{{- define "helm-toolkit.manifests.secret_registry" }}
{{- $envAll := index . "envAll" }}
{{- $registryUser := index . "registryUser" }}
{{- $secretName := index $envAll.Values.secrets.oci_image_registry $registryUser }}
{{- $registryHost := tuple "oci_image_registry" "internal" $envAll | include "helm-toolkit.endpoints.endpoint_host_lookup" }}
{{/*
We only use "host:port" when port is non-null, else just use "host"
*/}}
{{- $registryPort := "" }}
{{- $port := $envAll.Values.endpoints.oci_image_registry.port.registry.default }}
{{- if $port }}
{{- $port = tuple "oci_image_registry" "internal" "registry" $envAll | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
{{- $registryPort = printf ":%s" $port }}
{{- end }}
{{- $imageCredentials := index $envAll.Values.endpoints.oci_image_registry.auth $registryUser }}
{{- $dockerAuthToken := printf "%s:%s" $imageCredentials.username $imageCredentials.password | b64enc }}
{{- $dockerAuth := printf "{\"auths\": {\"%s%s\": {\"auth\": \"%s\"}}}" $registryHost $registryPort $dockerAuthToken | b64enc }}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ $secretName }}
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: {{ $dockerAuth }}
{{- end -}}
