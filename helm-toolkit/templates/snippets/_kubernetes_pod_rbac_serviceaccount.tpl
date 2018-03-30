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

{{- define "helm-toolkit.snippets.kubernetes_pod_rbac_serviceaccount" -}}
{{- $envAll := index . 0 -}}
{{- $deps := index . 1 -}}
{{- $saName := index . 2 -}}
{{- $saNamespace := $envAll.Release.Namespace }}
{{- $randomKey := randAlphaNum 32 }}
{{- $allNamespace := dict $randomKey "" }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $saName }}
  namespace: {{ $saNamespace }}
{{- range $k, $v := $deps -}}
{{- if eq $k "services" }}
{{- range $serv := $v }}
{{- $endpointMap := index $envAll.Values.endpoints $serv.service }}
{{- $endpointNS := $endpointMap.namespace | default $saNamespace }}
{{- if not (contains "services" ((index $allNamespace $endpointNS) | default "")) }}
{{- $_ := set $allNamespace $endpointNS (printf "%s%s" "services," ((index $allNamespace $endpointNS) | default "")) }}
{{- end -}}
{{- end -}}
{{- else if and (eq $k "jobs") $v }}
{{- $_ := set $allNamespace $saNamespace  (printf "%s%s" "jobs," ((index $allNamespace $saNamespace) | default "")) }}
{{- else if and (eq $k "daemonset") $v }}
{{- $_ := set $allNamespace $saNamespace  (printf "%s%s" "daemonsets," ((index $allNamespace $saNamespace) | default "")) }}
{{- else if and (eq $k "pod") $v }}
{{- $_ := set $allNamespace $saNamespace  (printf "%s%s" "pods," ((index $allNamespace $saNamespace) | default "")) }}
{{- end -}}
{{- end -}}
{{- $_ := unset $allNamespace $randomKey }}
{{- range $ns, $vv := $allNamespace }}
{{- $resourceList := (splitList "," (trimSuffix "," $vv)) }}
{{- tuple $envAll $resourceList $saName $ns | include "helm-toolkit.snippets.kubernetes_pod_rbac_roles" }}
{{- end -}}
{{- end -}}
