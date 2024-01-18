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

*/}}

{{- define "helm-toolkit.manifests.ingress._host_rules" -}}
{{- $vHost := index . "vHost" -}}
{{- $backendName := index . "backendName" -}}
{{- $backendPort := index . "backendPort" -}}
{{- $pathType := index . "pathType" -}}
- host: {{ $vHost }}
  http:
    paths:
      - path: /
        pathType: {{ $pathType }}
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

{{- define "helm-toolkit.manifests.ingress" -}}
{{- $envAll := index . "envAll" -}}
{{- $backendService := index . "backendService" | default "api" -}}
{{- $backendServiceType := index . "backendServiceType" -}}
{{- $backendPort := index . "backendPort" -}}
{{- $endpoint := index . "endpoint" | default "public" -}}
{{- $pathType := index . "pathType" | default "Prefix" -}}
{{- $certIssuer := index . "certIssuer" | default "" -}}
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
{{- $hostRules := dict "vHost" $vHost "backendName" $backendName "backendPort" $backendPort "pathType" $pathType }}
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
{{- $hostNameFullRules := dict "vHost" $vHost "backendName" $backendName "backendPort" $backendPort "pathType" $pathType }}
{{ $hostNameFullRules | include "helm-toolkit.manifests.ingress._host_rules" | indent 4 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
