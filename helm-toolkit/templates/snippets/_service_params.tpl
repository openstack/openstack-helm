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
  Inserts kubernetes service parameters from values as is.
values: |
  network:
    serviceExample:
      service:
        type: loadBalancer
        loadBalancerIP: 1.1.1.1
usage: |
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name: 'serviceExample'
  spec:
    ports:
    - name: s-example
      port: 1111
  {{ .Values.network.serviceExample | include "helm-toolkit.snippets.service_params" | indent 2 }}
return: |
  type: loadBalancer
  loadBalancerIP: 1.1.1.1
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
