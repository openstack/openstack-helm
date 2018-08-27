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
  Creates a network policy manifest for services.
values: |
  network_policy:
    myLabel:
      ingress:
        - from:
          - podSelector:
              matchLabels:
                application: keystone
          ports:
          - protocol: TCP
            port: 80
usage: |
  {{ dict "envAll" . "name" "application" "label" "myLabel" | include "helm-toolkit.manifests.kubernetes_network_policy" }}
return: |
  ---
  apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    name: RELEASE-NAME
    namespace: NAMESPACE
  spec:
    policyTypes:
      - Ingress
      - Egress
    podSelector:
      matchLabels:
        application: myLabel
    ingress:
      - from:
        - podSelector:
            matchLabels:
              application: keystone
        ports:
        - protocol: TCP
          port: 80
    egress:
      - {}
*/}}

{{- define "helm-toolkit.manifests.kubernetes_network_policy" -}}
{{- $envAll := index . "envAll" -}}
{{- $name := index . "name" -}}
{{- $label := index . "label" -}}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ $label }}-netpol
  namespace: {{ $envAll.Release.Namespace }}
spec:
  policyTypes:
    - Egress
{{- if hasKey (index $envAll.Values "network_policy") $label }}
{{- if index $envAll.Values.network_policy $label "ingress" }}
    - Ingress
{{- end }}
{{- end }}
  podSelector:
    matchLabels:
      {{ $name }}: {{ $label }}
  egress:
    - {}
{{- if hasKey (index $envAll.Values "network_policy") $label }}
{{- if index $envAll.Values.network_policy $label "ingress" }}
  ingress:
{{ index $envAll.Values.network_policy $label "ingress" | toYaml | indent 4 }}
{{- end }}
{{- end }}
{{- end }}
