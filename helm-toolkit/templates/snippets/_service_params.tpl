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
  Inserts kubernetes service parameters from values: the keys of service as
  is, type NodePort when node_port.enabled is true, and externalTrafficPolicy
  Local when external_policy_local is true. The last two take precedence over
  the same keys under service.
values: |
  network:
    serviceExample:
      service:
        type: LoadBalancer
        loadBalancerSourceRanges:
          - 192.0.2.0/24
      external_policy_local: true
usage: |
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name: service-example
  spec:
    ports:
    - name: s-example
      port: 1111
  {{ .Values.network.serviceExample | include "helm-toolkit.snippets.service_params" | indent 2 }}
return: |
  externalTrafficPolicy: Local
  loadBalancerSourceRanges:
  - 192.0.2.0/24
  type: LoadBalancer
*/}}

{{- define "helm-toolkit.snippets.service_params" }}
{{- $serviceParams := dict }}
{{- if hasKey . "service" }}
{{- $serviceParams = .service }}
{{- end }}
{{- if hasKey . "node_port" }}
{{- if hasKey .node_port "enabled" }}
{{- if .node_port.enabled }}
{{- $_ := set $serviceParams "type" "NodePort" }}
{{- end }}
{{- end }}
{{- end }}
{{- if hasKey . "external_policy_local" }}
{{- if .external_policy_local }}
{{- $_ := set $serviceParams "externalTrafficPolicy" "Local" }}
{{- end }}
{{- end }}
{{- if $serviceParams }}
{{- $serviceParams | toYaml }}
{{- end }}
{{- end }}
