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
endpoints:
  kube_dns:
    namespace: kube-system
    name: kubernetes-dns
    hosts:
      default: kube-dns
    host_fqdn_override:
      default: null
    path:
      default: null
    scheme: http
    port:
      dns_tcp:
        default: 53
      dns:
        default: 53
        protocol: UDP
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
      egress:
        - to:
          - namespaceSelector:
              matchLabels:
                name: default
          - namespaceSelector:
              matchLabels:
                name: kube-public
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
      - to:
          - podSelector:
              matchLabels:
                application: kube-dns
          - namespaceSelector:
              matchLabels:
                 name: kube-system
          ports:
          - protocol: TCP
            port: 53
          - protocol: UDP
            port: 53
      - to:
          - namespaceSelector:
              matchLabels:
                 name: kube-public
          - namespaceSelector:
              matchLabels:
                 name: default
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
{{- range $key, $value := $envAll.Values.endpoints }}
{{- if kindIs "map" $value }}
    - to:
{{- if index $value "namespace" }}
      - namespaceSelector:
          matchLabels:
            name: {{ index $value "namespace" }}
{{- else if index $value "hosts" }}
{{- $defaultValue := index $value "hosts" "internal" }}
{{- if hasKey (index $value "hosts") "internal" }}
{{- $a := split "-" $defaultValue }}
      - podSelector:
          matchLabels:
            application: {{ printf "%s" (index $a._0) | default $defaultValue }}
{{- else }}
{{- $defaultValue := index $value "hosts" "default" }}
{{- $a := split "-" $defaultValue }}
      - podSelector:
          matchLabels:
            application: {{ printf "%s" (index $a._0) | default $defaultValue }}
{{- end }}
{{- end }}
      ports:
{{- if index $value "port" }}
{{- range $k, $v := index $value "port" }}
{{- if $k }}
{{- range $pk, $pv := $v }}
{{- if (ne $pk "protocol") }}
      - port: {{ $pv }}
        protocol: {{ $v.protocol | default "TCP" }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- if hasKey (index $envAll.Values "network_policy") $label }}
{{- if index $envAll.Values.network_policy $label "egress" }}
{{ index $envAll.Values.network_policy $label "egress" | toYaml | indent 4 }}
{{- end }}
{{- if index $envAll.Values.network_policy $label "ingress" }}
  ingress:
{{ index $envAll.Values.network_policy $label "ingress" | toYaml | indent 4 }}
{{- end }}
{{- end }}
{{- end }}
