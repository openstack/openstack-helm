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
  Fills in the fluent handler and formatter of conf.logging when the
  logging configuration uses them and does not define them. The handler
  sends to the internal fluentd endpoint with the tag
  "<namespace>.<deploymentName>". Renders nothing; it changes
  conf.logging in place.
values: |
  conf:
    logging:
      handlers:
        keys:
          - stdout
          - fluent
      formatters:
        keys:
          - context
          - fluent
usage: |
  {{- dict "envAll" . "deploymentName" .deployment_name | include "helm-toolkit.snippets.oslo_logging_fluent" -}}
return: |
  conf.logging.handler_fluent:
    class: fluent.handler.FluentHandler
    formatter: fluent
    args: ('<namespace>.<deploymentName>', '<fluentd host>', <fluentd port>)
  conf.logging.formatter_fluent:
    class: oslo_log.formatters.FluentFormatter
*/}}

{{- define "helm-toolkit.snippets.oslo_logging_fluent" -}}
{{- $envAll := index . "envAll" -}}
{{- $deploymentName := index . "deploymentName" | default $envAll.Release.Name -}}
{{- $logging := $envAll.Values.conf.logging -}}
{{- if and (empty $logging.handler_fluent) (has "fluent" $logging.handlers.keys) -}}
{{- $fluentd_host := tuple "fluentd" "internal" $envAll | include "helm-toolkit.endpoints.hostname_namespaced_endpoint_lookup" }}
{{- $fluentd_port := tuple "fluentd" "internal" "service" $envAll | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
{{- $fluent_args := printf "('%s.%s', '%s', %s)" $envAll.Release.Namespace $deploymentName $fluentd_host $fluentd_port }}
{{- $handler_fluent := dict "class" "fluent.handler.FluentHandler" "formatter" "fluent" "args" $fluent_args -}}
{{- $_ := set $logging "handler_fluent" $handler_fluent -}}
{{- end -}}
{{- if and (empty $logging.formatter_fluent) (has "fluent" $logging.formatters.keys) -}}
{{- $formatter_fluent := dict "class" "oslo_log.formatters.FluentFormatter" -}}
{{- $_ := set $logging "formatter_fluent" $formatter_fluent -}}
{{- end -}}
{{- end -}}
