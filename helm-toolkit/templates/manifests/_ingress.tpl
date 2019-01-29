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

{{/*
abstract: |
  Creates a manifest for a services ingress rules.
examples:
  - values: |
      network:
        api:
          ingress:
            public: true
            classes:
              namespace: "nginx"
              cluster: "nginx-cluster"
            annotations:
              nginx.ingress.kubernetes.io/rewrite-target: /
      secrets:
        tls:
          key_manager:
            api:
              public: barbican-tls-public
      endpoints:
        cluster_domain_suffix: cluster.local
        key_manager:
          name: barbican
          hosts:
            default: barbican-api
            public: barbican
          host_fqdn_override:
            default: null
            public:
              host: barbican.openstackhelm.example
              tls:
                crt: |
                  FOO-CRT
                key: |
                  FOO-KEY
                ca: |
                  FOO-CA_CRT
          path:
            default: /
          scheme:
            default: http
            public: https
          port:
            api:
              default: 9311
              public: 80
    usage: |
      {{- include "helm-toolkit.manifests.ingress" ( dict "envAll" . "backendServiceType" "key-manager" "backendPort" "b-api" "endpoint" "public" ) -}}
    return: |
      ---
      apiVersion: extensions/v1beta1
      kind: Ingress
      metadata:
        name: barbican
        annotations:
          kubernetes.io/ingress.class: "nginx"
          nginx.ingress.kubernetes.io/rewrite-target: /

      spec:
        rules:
          - host: barbican
            http:
              paths:
                - path: /
                  backend:
                    serviceName: barbican-api
                    servicePort: b-api
          - host: barbican.default
            http:
              paths:
                - path: /
                  backend:
                    serviceName: barbican-api
                    servicePort: b-api
          - host: barbican.default.svc.cluster.local
            http:
              paths:
                - path: /
                  backend:
                    serviceName: barbican-api
                    servicePort: b-api
      ---
      apiVersion: extensions/v1beta1
      kind: Ingress
      metadata:
        name: barbican-namespace-fqdn
        annotations:
          kubernetes.io/ingress.class: "nginx"
          nginx.ingress.kubernetes.io/rewrite-target: /

      spec:
        tls:
          - secretName: barbican-tls-public
            hosts:
              - barbican.openstackhelm.example
        rules:
          - host: barbican.openstackhelm.example
            http:
              paths:
                - path: /
                  backend:
                    serviceName: barbican-api
                    servicePort: b-api
      ---
      apiVersion: extensions/v1beta1
      kind: Ingress
      metadata:
        name: barbican-cluster-fqdn
        annotations:
          kubernetes.io/ingress.class: "nginx-cluster"
          nginx.ingress.kubernetes.io/rewrite-target: /

      spec:
        tls:
          - secretName: barbican-tls-public
            hosts:
              - barbican.openstackhelm.example
        rules:
          - host: barbican.openstackhelm.example
            http:
              paths:
                - path: /
                  backend:
                    serviceName: barbican-api
                    servicePort: b-api
  - values: |
      network:
        api:
          ingress:
            public: true
            classes:
              namespace: "nginx"
              cluster: "nginx-cluster"
            annotations:
              nginx.ingress.kubernetes.io/rewrite-target: /
      secrets:
        tls:
          key_manager:
            api:
              public: barbican-tls-public
      endpoints:
        cluster_domain_suffix: cluster.local
        key_manager:
          name: barbican
          hosts:
            default: barbican-api
            public:
              host: barbican
              tls:
                crt: |
                  FOO-CRT
                key: |
                  FOO-KEY
                ca: |
                  FOO-CA_CRT
          host_fqdn_override:
            default: null
          path:
            default: /
          scheme:
            default: http
            public: https
          port:
            api:
              default: 9311
              public: 80
    usage: |
      {{- include "helm-toolkit.manifests.ingress" ( dict "envAll" . "backendServiceType" "key-manager" "backendPort" "b-api" "endpoint" "public" ) -}}
    return: |
      ---
      apiVersion: extensions/v1beta1
      kind: Ingress
      metadata:
        name: barbican
        annotations:
          kubernetes.io/ingress.class: "nginx"
          nginx.ingress.kubernetes.io/rewrite-target: /

      spec:
        tls:
          - secretName: barbican-tls-public
            hosts:
              - barbican
              - barbican.default
              - barbican.default.svc.cluster.local
        rules:
          - host: barbican
            http:
              paths:
                - path: /
                  backend:
                    serviceName: barbican-api
                    servicePort: b-api
          - host: barbican.default
            http:
              paths:
                - path: /
                  backend:
                    serviceName: barbican-api
                    servicePort: b-api
          - host: barbican.default.svc.cluster.local
            http:
              paths:
                - path: /
                  backend:
                    serviceName: barbican-api
                    servicePort: b-api
*/}}

{{- define "helm-toolkit.manifests.ingress._host_rules" -}}
{{- $vHost := index . "vHost" -}}
{{- $backendName := index . "backendName" -}}
{{- $backendPort := index . "backendPort" -}}
- host: {{ $vHost }}
  http:
    paths:
      - path: /
        backend:
          serviceName: {{ $backendName }}
          servicePort: {{ $backendPort }}
{{- end }}

{{- define "helm-toolkit.manifests.ingress" -}}
{{- $envAll := index . "envAll" -}}
{{- $backendService := index . "backendService" | default "api" -}}
{{- $backendServiceType := index . "backendServiceType" -}}
{{- $backendPort := index . "backendPort" -}}
{{- $endpoint := index . "endpoint" | default "public" -}}
{{- $ingressName := tuple $backendServiceType $endpoint $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
{{- $backendName := tuple $backendServiceType "internal" $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
{{- $hostName := tuple $backendServiceType $endpoint $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
{{- $hostNameFull := tuple $backendServiceType $endpoint $envAll | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ $ingressName }}
  annotations:
    kubernetes.io/ingress.class: {{ index $envAll.Values.network $backendService "ingress" "classes" "namespace" | quote }}
{{ toYaml (index $envAll.Values.network $backendService "ingress" "annotations") | indent 4 }}
spec:
{{- $host := index $envAll.Values.endpoints ( $backendServiceType | replace "-" "_" ) "hosts" }}
{{- if hasKey $host $endpoint }}
{{- $endpointHost := index $host $endpoint }}
{{- if kindIs "map" $endpointHost }}
{{- if hasKey $endpointHost "tls" }}
{{- if and ( not ( empty $endpointHost.tls.key ) ) ( not ( empty $endpointHost.tls.crt ) ) }}
{{- $secretName := index $envAll.Values.secrets "tls" ( $backendServiceType | replace "-" "_" ) $backendService $endpoint }}
{{- $_ := required "You need to specify a secret in your values for the endpoint" $secretName }}
  tls:
    - secretName: {{ $secretName }}
      hosts:
{{- range $key1, $vHost := tuple $hostName (printf "%s.%s" $hostName $envAll.Release.Namespace) (printf "%s.%s.svc.%s" $hostName $envAll.Release.Namespace $envAll.Values.endpoints.cluster_domain_suffix) }}
        - {{ $vHost }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
  rules:
{{- range $key1, $vHost := tuple $hostName (printf "%s.%s" $hostName $envAll.Release.Namespace) (printf "%s.%s.svc.%s" $hostName $envAll.Release.Namespace $envAll.Values.endpoints.cluster_domain_suffix) }}
{{- $hostRules := dict "vHost" $vHost "backendName" $backendName "backendPort" $backendPort }}
{{ $hostRules | include "helm-toolkit.manifests.ingress._host_rules" | indent 4 }}
{{- end }}
{{- if not ( hasSuffix ( printf ".%s.svc.%s" $envAll.Release.Namespace $envAll.Values.endpoints.cluster_domain_suffix) $hostNameFull) }}
{{- range $key2, $ingressController := tuple "namespace" "cluster" }}
{{- $hostNameFullRules := dict "vHost" $hostNameFull "backendName" $backendName "backendPort" $backendPort }}
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ printf "%s-%s-%s" $ingressName $ingressController "fqdn" }}
  annotations:
    kubernetes.io/ingress.class: {{ index $envAll.Values.network $backendService "ingress" "classes" $ingressController | quote }}
{{ toYaml (index $envAll.Values.network $backendService "ingress" "annotations") | indent 4 }}
spec:
{{- $host := index $envAll.Values.endpoints ( $backendServiceType | replace "-" "_" ) "host_fqdn_override" }}
{{- if hasKey $host $endpoint }}
{{- $endpointHost := index $host $endpoint }}
{{- if kindIs "map" $endpointHost }}
{{- if hasKey $endpointHost "tls" }}
{{- if and ( not ( empty $endpointHost.tls.key ) ) ( not ( empty $endpointHost.tls.crt ) ) }}
{{- $secretName := index $envAll.Values.secrets "tls" ( $backendServiceType | replace "-" "_" ) $backendService $endpoint }}
{{- $_ := required "You need to specify a secret in your values for the endpoint" $secretName }}
  tls:
    - secretName: {{ $secretName }}
      hosts:
        - {{ index $hostNameFullRules "vHost" }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
  rules:
{{ $hostNameFullRules | include "helm-toolkit.manifests.ingress._host_rules" | indent 4 }}
{{- end }}
{{- end }}
{{- end }}
