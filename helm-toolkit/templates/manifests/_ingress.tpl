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
      {{- include "helm-toolkit.manifests.ingress" ( dict "envAll" . "backendServiceType" "key-manager" "backendPort" "b-api" "endpoint" "public" "pathType" "Prefix" ) -}}
    return: |
      ---
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: barbican
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /

      spec:
        ingressClassName: "nginx"
        rules:
          - host: barbican
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: barbican-api
                      port:
                        name: b-api
          - host: barbican.default
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: barbican-api
                      port:
                        name: b-api
          - host: barbican.default.svc.cluster.local
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: barbican-api
                      port:
                        name: b-api
      ---
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: barbican-namespace-fqdn
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /

      spec:
        ingressClassName: "nginx"
        tls:
          - secretName: barbican-tls-public
            hosts:
              - barbican.openstackhelm.example
        rules:
          - host: barbican.openstackhelm.example
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: barbican-api
                      port:
                        name: b-api
      ---
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: barbican-cluster-fqdn
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /

      spec:
        ingressClassName: "nginx-cluster"
        tls:
          - secretName: barbican-tls-public
            hosts:
              - barbican.openstackhelm.example
        rules:
          - host: barbican.openstackhelm.example
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: barbican-api
                      port:
                        name: b-api
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
      {{- include "helm-toolkit.manifests.ingress" ( dict "envAll" . "backendServiceType" "key-manager" "backendPort" "b-api" "endpoint" "public" "pathType" "Prefix" ) -}}
    return: |
      ---
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: barbican
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /

      spec:
        ingressClassName: "nginx"
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
                  pathType: Prefix
                  backend:
                    service:
                      name: barbican-api
                      port:
                        name: b-api
          - host: barbican.default
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: barbican-api
                      port:
                        name: b-api
          - host: barbican.default.svc.cluster.local
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: barbican-api
                      port:
                        name: b-api
  - values: |
      cert_issuer_type: issuer
      network:
        api:
          ingress:
            public: true
            classes:
              namespace: "nginx"
              cluster: "nginx-cluster"
            annotations:
              nginx.ingress.kubernetes.io/secure-backends: "true"
              nginx.ingress.kubernetes.io/backend-protocol: "https"
      secrets:
        tls:
          key_manager:
            api:
              public: barbican-tls-public
              internal: barbican-tls-api
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
          certs:
            barbican_tls_api:
              secretName: barbican-tls-api
              issuerRef:
                name: ca-issuer
                kind: Issuer
    usage: |
      {{- include "helm-toolkit.manifests.ingress" ( dict "envAll" . "backendServiceType" "key-manager" "backendPort" "b-api" "endpoint" "public" "certIssuer" "ca-issuer" "pathType" "Prefix" ) -}}
    return: |
      ---
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: barbican
        annotations:
          cert-manager.io/issuer: ca-issuer
          certmanager.k8s.io/issuer: ca-issuer
          nginx.ingress.kubernetes.io/backend-protocol: https
          nginx.ingress.kubernetes.io/secure-backends: "true"
      spec:
        ingressClassName: "nginx"
        tls:
          - secretName: barbican-tls-public-certmanager
            hosts:
              - barbican
              - barbican.default
              - barbican.default.svc.cluster.local
        rules:
          - host: barbican
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: barbican-api
                      port:
                        name: b-api
          - host: barbican.default
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: barbican-api
                      port:
                        name: b-api
          - host: barbican.default.svc.cluster.local
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: barbican-api
                      port:
                        name: b-api

  - values: |
      network:
        api:
          ingress:
            public: true
            classes:
              namespace: "nginx"
              cluster: "nginx-cluster"
            annotations:
              nginx.ingress.kubernetes.io/secure-backends: "true"
              nginx.ingress.kubernetes.io/backend-protocol: "https"
      secrets:
        tls:
          key_manager:
            api:
              public: barbican-tls-public
              internal: barbican-tls-api
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
          certs:
            barbican_tls_api:
              secretName: barbican-tls-api
              issuerRef:
                name: ca-issuer
                kind: ClusterIssuer
    usage: |
      {{- include "helm-toolkit.manifests.ingress" ( dict "envAll" . "backendServiceType" "key-manager" "backendPort" "b-api" "endpoint" "public" "certIssuer" "ca-issuer" "pathType" "Prefix" ) -}}
    return: |
      ---
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: barbican
        annotations:
          cert-manager.io/cluster-issuer: ca-issuer
          certmanager.k8s.io/cluster-issuer: ca-issuer
          nginx.ingress.kubernetes.io/backend-protocol: https
          nginx.ingress.kubernetes.io/secure-backends: "true"
      spec:
        ingressClassName: "nginx"
        tls:
          - secretName: barbican-tls-public-certmanager
            hosts:
              - barbican
              - barbican.default
              - barbican.default.svc.cluster.local
        rules:
          - host: barbican
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: barbican-api
                      port:
                        name: b-api
          - host: barbican.default
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: barbican-api
                      port:
                        name: b-api
          - host: barbican.default.svc.cluster.local
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: barbican-api
                      port:
                        name: b-api
  # Sample usage for multiple DNS names associated with the same public
  # endpoint and certificate
  - values: |
      endpoints:
        cluster_domain_suffix: cluster.local
        grafana:
          name: grafana
          hosts:
            default: grafana-dashboard
            public: grafana
          host_fqdn_override:
            public:
              host: grafana.openstackhelm.example
              tls:
                dnsNames:
                  - grafana-alt.openstackhelm.example
                crt: "BASE64 ENCODED CERT"
                key: "BASE64 ENCODED KEY"
      network:
        grafana:
          ingress:
            classes:
              namespace: "nginx"
              cluster: "nginx-cluster"
            annotations:
              nginx.ingress.kubernetes.io/rewrite-target: /
      secrets:
        tls:
          grafana:
            grafana:
              public: grafana-tls-public
    usage: |
      {{- $ingressOpts := dict "envAll" . "backendService" "grafana" "backendServiceType" "grafana" "backendPort" "dashboard" "pathType" "Prefix" -}}
      {{ $ingressOpts | include "helm-toolkit.manifests.ingress" }}
    return: |
      ---
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: grafana
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /

      spec:
        ingressClassName: "nginx"
        rules:
          - host: grafana
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: grafana-dashboard
                      port:
                        name: dashboard
          - host: grafana.default
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: grafana-dashboard
                      port:
                        name: dashboard
          - host: grafana.default.svc.cluster.local
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: grafana-dashboard
                      port:
                        name: dashboard
      ---
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: grafana-namespace-fqdn
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /

      spec:
        ingressClassName: "nginx"
        tls:
          - secretName: grafana-tls-public
            hosts:
              - grafana.openstackhelm.example
              - grafana-alt.openstackhelm.example
        rules:
          - host: grafana.openstackhelm.example
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: grafana-dashboard
                      port:
                        name: dashboard
          - host: grafana-alt.openstackhelm.example
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: grafana-dashboard
                      port:
                        name: dashboard
      ---
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: grafana-cluster-fqdn
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /

      spec:
        ingressClassName: "nginx-cluster"
        tls:
          - secretName: grafana-tls-public
            hosts:
              - grafana.openstackhelm.example
              - grafana-alt.openstackhelm.example
        rules:
          - host: grafana.openstackhelm.example
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: grafana-dashboard
                      port:
                        name: dashboard
          - host: grafana-alt.openstackhelm.example
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: grafana-dashboard
                      port:
                        name: dashboard
  # Sample usage for custom ingressPaths (multiple paths)
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
          identity:
            api:
              public: keystone-tls-public
      endpoints:
        cluster_domain_suffix: cluster.local
        identity:
          name: keystone
          hosts:
            default: keystone-api
            public: keystone
          host_fqdn_override:
            default: null
          path:
            default: /v3
          scheme:
            default: http
            public: https
          port:
            api:
              default: 5000
              public: 80
    usage: |
      {{- include "helm-toolkit.manifests.ingress" ( dict "envAll" . "backendServiceType" "identity" "backendPort" "ks-pub" "endpoint" "public" "ingressPaths" (list "/v3" "/v2.0") "pathType" "Prefix" ) -}}
    return: |
      ---
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: keystone
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /

      spec:
        ingressClassName: "nginx"
        rules:
          - host: keystone
            http:
              paths:
                - path: /v3
                  pathType: Prefix
                  backend:
                    service:
                      name: keystone-api
                      port:
                        name: ks-pub
                - path: /v2.0
                  pathType: Prefix
                  backend:
                    service:
                      name: keystone-api
                      port:
                        name: ks-pub
          - host: keystone.default
            http:
              paths:
                - path: /v3
                  pathType: Prefix
                  backend:
                    service:
                      name: keystone-api
                      port:
                        name: ks-pub
                - path: /v2.0
                  pathType: Prefix
                  backend:
                    service:
                      name: keystone-api
                      port:
                        name: ks-pub
          - host: keystone.default.svc.cluster.local
            http:
              paths:
                - path: /v3
                  pathType: Prefix
                  backend:
                    service:
                      name: keystone-api
                      port:
                        name: ks-pub
                - path: /v2.0
                  pathType: Prefix
                  backend:
                    service:
                      name: keystone-api
                      port:
                        name: ks-pub
  # Sample usage for additionalBackends (multiple backends with different paths)
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
          shipyard:
            api:
              public: shipyard-tls-public
      endpoints:
        cluster_domain_suffix: cluster.local
        shipyard:
          name: shipyard
          hosts:
            default: shipyard-int
            public: shipyard
          host_fqdn_override:
            default: null
          path:
            default: /api/v1.0
          scheme:
            default: http
            public: https
          port:
            api:
              default: 9000
              public: 80
        airflow_web:
          name: airflow-web
          hosts:
            default: airflow-web-int
            public: airflow-web
          host_fqdn_override:
            default: null
          path:
            default: /airflow
          scheme:
            default: http
          port:
            api:
              default: 8080
    usage: |
      {{- include "helm-toolkit.manifests.ingress" ( dict "envAll" . "backendServiceType" "shipyard" "backendPort" "api" "endpoint" "public" "pathType" "Prefix" "additionalBackends" (list (dict "backendServiceType" "airflow-web" "backendPort" "api")) ) -}}
    return: |
      ---
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: shipyard
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /

      spec:
        ingressClassName: "nginx"
        rules:
          - host: shipyard
            http:
              paths:
                - path: /api/v1.0
                  pathType: Prefix
                  backend:
                    service:
                      name: shipyard-int
                      port:
                        name: api
                - path: /airflow
                  pathType: Prefix
                  backend:
                    service:
                      name: airflow-web-int
                      port:
                        name: api
          - host: shipyard.default
            http:
              paths:
                - path: /api/v1.0
                  pathType: Prefix
                  backend:
                    service:
                      name: shipyard-int
                      port:
                        name: api
                - path: /airflow
                  pathType: Prefix
                  backend:
                    service:
                      name: airflow-web-int
                      port:
                        name: api
          - host: shipyard.default.svc.cluster.local
            http:
              paths:
                - path: /api/v1.0
                  pathType: Prefix
                  backend:
                    service:
                      name: shipyard-int
                      port:
                        name: api
                - path: /airflow
                  pathType: Prefix
                  backend:
                    service:
                      name: airflow-web-int
                      port:
                        name: api

*/}}

{{- define "helm-toolkit.manifests.ingress._host_rules" -}}
{{- $vHost := index . "vHost" -}}
{{- $backendName := index . "backendName" -}}
{{- $backendPort := index . "backendPort" -}}
{{- $pathType := index . "pathType" -}}
{{- $ingressPaths := index . "ingressPaths" | default "/" -}}
{{- if kindIs "string" $ingressPaths -}}
{{-   $ingressPaths = list $ingressPaths -}}
{{- end -}}
{{- $additionalBackends := index . "additionalBackends" | default list -}}
- host: {{ $vHost }}
  http:
    paths:
{{- range $p := $ingressPaths }}
{{- if kindIs "map" $p }}
      - path: {{ $p.path }}
        pathType: {{ $p.pathType | default $pathType }}
{{- else }}
      - path: {{ $p }}
        pathType: {{ $pathType }}
{{- end }}
        backend:
          service:
            name: {{ $backendName }}
            port:
{{- if or (kindIs "int" $backendPort) (regexMatch "^[0-9]{1,5}$" $backendPort) }}
              number: {{ $backendPort | int }}
{{- else }}
              name: {{ $backendPort | quote }}
{{- end }}
{{- end }}
{{- range $ab := $additionalBackends }}
{{- $abPaths := $ab.ingressPaths | default "/" -}}
{{- if kindIs "string" $abPaths -}}
{{-   $abPaths = list $abPaths -}}
{{- end -}}
{{- range $p := $abPaths }}
{{- if kindIs "map" $p }}
      - path: {{ $p.path }}
        pathType: {{ $p.pathType | default $pathType }}
{{- else }}
      - path: {{ $p }}
        pathType: {{ $pathType }}
{{- end }}
        backend:
          service:
            name: {{ $ab.backendName }}
            port:
{{- if or (kindIs "int" $ab.backendPort) (regexMatch "^[0-9]{1,5}$" $ab.backendPort) }}
              number: {{ $ab.backendPort | int }}
{{- else }}
              name: {{ $ab.backendPort | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "helm-toolkit.manifests.ingress" -}}
{{- $envAll := index . "envAll" -}}
{{- $backendService := index . "backendService" | default "api" -}}
{{- $backendServiceType := index . "backendServiceType" -}}
{{- $backendPort := index . "backendPort" -}}
{{- $endpoint := index . "endpoint" | default "public" -}}
{{- $pathType := index . "pathType" | default "Prefix" -}}
{{- $certIssuer := index . "certIssuer" | default "" -}}
{{- $ingressPaths := index . "ingressPaths" | default "/" -}}
{{- $additionalBackendsInput := index . "additionalBackends" | default list -}}
{{- $additionalBackends := list -}}
{{- range $ab := $additionalBackendsInput -}}
{{-   $abServiceType := $ab.backendServiceType -}}
{{-   $abBackendName := tuple $abServiceType "internal" $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" -}}
{{-   $abBackendPort := $ab.backendPort -}}
{{-   $abPaths := "" -}}
{{-   $abEndpointMap := index $envAll.Values.endpoints ( $abServiceType | replace "-" "_" ) -}}
{{-   if hasKey $abEndpointMap "path" -}}
{{-     if kindIs "string" $abEndpointMap.path -}}
{{-       $abPaths = $abEndpointMap.path -}}
{{-     else if kindIs "map" $abEndpointMap.path -}}
{{-       if hasKey $abEndpointMap.path "default" -}}
{{-         $abPaths = index $abEndpointMap.path "default" -}}
{{-       end -}}
{{-     end -}}
{{-   end -}}
{{-   if not $abPaths -}}
{{-     $abPaths = "/" -}}
{{-   end -}}
{{-   $additionalBackends = append $additionalBackends (dict "backendName" $abBackendName "backendPort" $abBackendPort "ingressPaths" $abPaths) -}}
{{- end -}}
{{- $ingressName := tuple $backendServiceType $endpoint $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
{{- $backendName := tuple $backendServiceType "internal" $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
{{- $hostName := tuple $backendServiceType $endpoint $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
{{- $hostNameFull := tuple $backendServiceType $endpoint $envAll | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}
{{- $certIssuerType := "cluster-issuer" -}}
{{- if $envAll.Values.cert_issuer_type }}
{{- $certIssuerType = $envAll.Values.cert_issuer_type }}
{{- end }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $ingressName }}
  annotations:
{{- if $certIssuer }}
    cert-manager.io/{{ $certIssuerType }}: {{ $certIssuer }}
    certmanager.k8s.io/{{ $certIssuerType }}: {{ $certIssuer }}
{{- $slice := index $envAll.Values.endpoints $backendServiceType "host_fqdn_override" "default" "tls" -}}
{{- if (hasKey $slice "duration") }}
    cert-manager.io/duration: {{ index $slice "duration" }}
{{- end }}
{{- end }}
{{ toYaml (index $envAll.Values.network $backendService "ingress" "annotations") | indent 4 }}
spec:
  ingressClassName: {{ index $envAll.Values.network $backendService "ingress" "classes" "namespace" | quote }}
{{- $host := index $envAll.Values.endpoints ( $backendServiceType | replace "-" "_" ) "hosts" }}
{{- if $certIssuer }}
{{- $secretName := index $envAll.Values.secrets "tls" ( $backendServiceType | replace "-" "_" ) $backendService $endpoint }}
{{- $_ := required "You need to specify a secret in your values for the endpoint" $secretName }}
  tls:
    - secretName: {{ printf "%s-ing" $secretName }}
      hosts:
{{- range $key1, $vHost := tuple $hostName (printf "%s.%s" $hostName $envAll.Release.Namespace) (printf "%s.%s.svc.%s" $hostName $envAll.Release.Namespace $envAll.Values.endpoints.cluster_domain_suffix) }}
        - {{ $vHost }}
{{- end }}
{{- else }}
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
{{- end }}
  rules:
{{- range $key1, $vHost := tuple $hostName (printf "%s.%s" $hostName $envAll.Release.Namespace) (printf "%s.%s.svc.%s" $hostName $envAll.Release.Namespace $envAll.Values.endpoints.cluster_domain_suffix) }}
{{- $hostRules := dict "vHost" $vHost "backendName" $backendName "backendPort" $backendPort "pathType" $pathType "ingressPaths" $ingressPaths "additionalBackends" $additionalBackends }}
{{ $hostRules | include "helm-toolkit.manifests.ingress._host_rules" | indent 4 }}
{{- end }}
{{- if not ( hasSuffix ( printf ".%s.svc.%s" $envAll.Release.Namespace $envAll.Values.endpoints.cluster_domain_suffix) $hostNameFull) }}
{{- $ingressConf := $envAll.Values.network -}}
{{- $ingressClasses := ternary (tuple "namespace") (tuple "namespace" "cluster") (and (hasKey $ingressConf "use_external_ingress_controller") $ingressConf.use_external_ingress_controller) }}
{{- range $key2, $ingressController := $ingressClasses }}
{{- $vHosts := list $hostNameFull }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ printf "%s-%s-%s" $ingressName $ingressController "fqdn" }}
  annotations:
{{ toYaml (index $envAll.Values.network $backendService "ingress" "annotations") | indent 4 }}
spec:
  ingressClassName: {{ index $envAll.Values.network $backendService "ingress" "classes" $ingressController | quote }}
{{- $host := index $envAll.Values.endpoints ( $backendServiceType | replace "-" "_" ) "host_fqdn_override" }}
{{- if hasKey $host $endpoint }}
{{- $endpointHost := index $host $endpoint }}
{{- if kindIs "map" $endpointHost }}
{{- if hasKey $endpointHost "tls" }}
{{- range $v := without (index $endpointHost.tls "dnsNames" | default list) $hostNameFull }}
{{- $vHosts = append $vHosts $v }}
{{- end }}
{{- if hasKey $envAll.Values.endpoints "alias_fqdn" }}
{{- $alias_host := $envAll.Values.endpoints.alias_fqdn }}
{{- $vHosts = append $vHosts $alias_host }}
{{- end }}
{{- $secretName := index $envAll.Values.secrets "tls" ( $backendServiceType | replace "-" "_" ) $backendService $endpoint }}
{{- $_ := required "You need to specify a secret in your values for the endpoint" $secretName }}
  tls:
    - secretName: {{ $secretName }}
      hosts:
{{- range $vHost := $vHosts }}
        - {{ $vHost }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
  rules:
{{- range $vHost := $vHosts }}
{{- $hostNameFullRules := dict "vHost" $vHost "backendName" $backendName "backendPort" $backendPort "pathType" $pathType "ingressPaths" $ingressPaths "additionalBackends" $additionalBackends }}
{{ $hostNameFullRules | include "helm-toolkit.manifests.ingress._host_rules" | indent 4 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
