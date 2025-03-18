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

# This function creates a manifest for a services ingress rules.
# It can be used in charts dict created similar to the following:
# {- $serviceIngressOpts := dict "envAll" . "backendServiceType" "key-manager" -}
# { $serviceIngressOpts | include "helm-toolkit.manifests.service_ingress" }

{{- define "helm-toolkit.manifests.service_ingress" -}}
{{- $envAll := index . "envAll" -}}
{{- $backendServiceType := index . "backendServiceType" -}}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ tuple $backendServiceType "public" $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
spec:
  ports:
    - name: http
      port: 80
    - name: https
      port: 443
  selector:
    app: ingress-api
{{- if index $envAll.Values.endpoints $backendServiceType }}
{{- if index $envAll.Values.endpoints $backendServiceType "ip" }}
{{- if index $envAll.Values.endpoints $backendServiceType "ip" "ingress" }}
  clusterIP: {{ (index $envAll.Values.endpoints $backendServiceType "ip" "ingress") }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
