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
  Renders out configuration sections into a format suitable for incorporation
  into a config-map. Allowing various forms of input to be rendered out as
  appropriate.
values: |
  conf:
    inputs:
      - foo
      - bar
    some:
      config_to_render: |
        #We can use all of gotpl here: eg macros, ranges etc.
        {{ include "helm-toolkit.utils.joinListWithComma" .Values.conf.inputs }}
      config_to_complete:
        #here we can fill out params, but things need to be valid yaml as input
        '{{ .Release.Name }}': '{{ printf "%s-%s" .Release.Namespace "namespace" }}'
      static_config:
        #this is just passed though as yaml to the configmap
        foo: bar
usage: |
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
return: |
  ---
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: application-etc
  data:
    config_to_render.conf: |
      #We can use all of gotpl here: eg macros, ranges etc.
      foo,bar

    config_to_complete.yaml: |
      'RELEASE-NAME': 'default-namespace'

    static_config.yaml: |
      foo: bar
*/}}

{{- define "helm-toolkit.snippets.values_template_renderer" -}}
{{- $envAll := index . "envAll" -}}
{{- $template := index . "template" -}}
{{- $key := index . "key" -}}
{{- $format := index . "format" | default "configMap" -}}
{{- with $envAll -}}
{{- $templateRendered := tpl ( $template | toYaml ) . }}
{{- if eq $format "Secret" }}
{{- if hasPrefix "|\n" $templateRendered }}
{{ $key }}: {{ regexReplaceAllLiteral "\n  " ( $templateRendered | trimPrefix "|\n" | trimPrefix "  " ) "\n" | b64enc }}
{{- else }}
{{ $key }}: {{ $templateRendered | b64enc }}
{{- end -}}
{{- else }}
{{- if hasPrefix "|\n" $templateRendered }}
{{ $key }}: |
{{ regexReplaceAllLiteral "\n  " ( $templateRendered | trimPrefix "|\n" | trimPrefix "  " ) "\n" | indent 2 }}
{{- else }}
{{ $key }}: |
{{ $templateRendered | indent 2 }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
