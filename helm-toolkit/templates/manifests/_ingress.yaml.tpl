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

# This function creates a manifest for a services ingress rules.
# It can be used in charts dict created similar to the following:
# {- $ingressOpts := dict "envAll" . "backendServiceType" "key-manager" -}
# { $ingressOpts | include "helm-toolkit.manifests.ingress" }

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
{{- $ingressName := tuple $backendServiceType "public" $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
{{- $backendName := tuple $backendServiceType "internal" $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
{{- $hostName := tuple $backendServiceType "public" $envAll | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
{{- $hostNameFull := tuple $backendServiceType "public" $envAll | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ $ingressName }}
  annotations:
    kubernetes.io/ingress.class: {{ index $envAll.Values.network $backendService "ingress" "classes" "namespace" | quote }}
{{ toYaml (index $envAll.Values.network $backendService "ingress" "annotations") | indent 4 }}
spec:
  rules:
{{- range $key1, $vHost := tuple $hostName (printf "%s.%s" $hostName $envAll.Release.Namespace) (printf "%s.%s.svc.%s" $hostName $envAll.Release.Namespace $envAll.Values.endpoints.cluster_domain_suffix)}}
{{- $hostRules := dict "vHost" $vHost "backendName" $backendName "backendPort" $backendPort }}
{{ $hostRules | include "helm-toolkit.manifests.ingress._host_rules" | indent 4}}
{{- end }}
{{- if not ( hasSuffix ( printf ".%s.svc.%s" $envAll.Release.Namespace $envAll.Values.endpoints.cluster_domain_suffix) $hostNameFull) }}
{{- $hostNameFullRules := dict "vHost" $hostNameFull "backendName" $backendName "backendPort" $backendPort }}
{{ $hostNameFullRules | include "helm-toolkit.manifests.ingress._host_rules" | indent 4}}
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ printf "%s-%s" $ingressName "fqdn" }}
  annotations:
    kubernetes.io/ingress.class: {{ index $envAll.Values.network $backendService "ingress" "classes" "cluster" | quote }}
{{ toYaml (index $envAll.Values.network $backendService "ingress" "annotations") | indent 4 }}
spec:
  rules:
{{ $hostNameFullRules | include "helm-toolkit.manifests.ingress._host_rules" | indent 4}}
{{- end }}
{{- end }}
