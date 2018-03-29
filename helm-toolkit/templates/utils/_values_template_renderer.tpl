{{/*
Copyright 2018 The Openstack-Helm Authors.

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
This function renders out configuration sections into a format suitable for
incorporation into a config-map. This allows various forms of input to be
rendered out as appropriate, as illustrated in the following example:

With the input:

  conf:
    some:
      config_to_render: |
        #We can use all of gotpl here: eg macros, ranges etc.
        Listen 0.0.0.0:{{ tuple "dashboard" "internal" "web" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
      config_to_complete:
        #here we can fill out params, but things need to be valid yaml as input
        '{{ .Release.Name }}': '{{ printf "%s-%s" .Release.Namespace "namespace" }}'
      static_config:
        #this is just passed though as yaml to the configmap
        foo: bar

And the template:

  {{- $envAll := . }}
  ---
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: application-etc
  data:
  {{- include "helm-toolkit.snippets.values_template_renderer" (dict "envAll" $envAll "template" .Values.conf.some.config_to_render "key" "config_to_render.conf") | indent 2 }}
  {{- include "helm-toolkit.snippets.values_template_renderer" (dict "envAll" $envAll "template" .Values.conf.some.config_to_complete "key" "config_to_complete.yaml") | indent 2 }}
  {{- include "helm-toolkit.snippets.values_template_renderer" (dict "envAll" $envAll "template" .Values.conf.some.static_config "key" "static_config.yaml") | indent 2 }}

The rendered output will match:

  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: application-etc
  data:
    config_to_render.conf: |
      #We can use all of gotpl here: eg macros, ranges etc.
      Listen 0.0.0.0:80

    config_to_complete.yaml: |
      'RELEASE-NAME': 'default-namespace'

    static_config.yaml: |
      foo: bar

*/}}

{{- define "helm-toolkit.snippets.values_template_renderer" -}}
{{- $envAll := index . "envAll" -}}
{{- $template := index . "template" -}}
{{- $key := index . "key" -}}
{{- with $envAll -}}
{{- $templateRendered := tpl ( $template | toYaml ) . }}
{{- if hasPrefix  "|\n" $templateRendered }}
{{ $key }}: {{ $templateRendered }}
{{- else }}
{{ $key }}: |
{{ $templateRendered | indent 2 }}
{{- end -}}
{{- end -}}
{{- end -}}
