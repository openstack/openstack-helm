{{- define "joinListWithColon" -}}
{{ range $k, $v := . }}{{ if $k }},{{ end }}{{ $v }}{{ end }}
{{- end -}}

{{- define "template" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $v:= $context.Template.Name | split "/" -}}
{{- $n := len $v -}}
{{- $last := sub $n 1 | printf "_%d" | index $v -}}
{{- $wtf := $context.Template.Name | replace $last $name -}}
{{ include $wtf $context }}
{{- end -}}

{{- define "hash" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $v:= $context.Template.Name | split "/" -}}
{{- $n := len $v -}}
{{- $last := sub $n 1 | printf "_%d" | index $v -}}
{{- $wtf := $context.Template.Name | replace $last $name -}}
{{- include $wtf $context | sha256sum | quote -}}
{{- end -}}

{{- define "dep-check-init-cont" -}}
{{- $envALL := index . 0 -}}
{{- $deps := index . 1 -}}
{
  "name": "init",
  "image": {{ $envALL.Values.images.dep_check | default "quay.io/stackanetes/kubernetes-entrypoint:v0.1.0" | quote }},
  "imagePullPolicy": {{ $envALL.Values.images.pull_policy | default "IfNotPresent" | quote }},
  "env": [
    {
      "name": "NAMESPACE",
      "value": "{{ $envALL.Release.Namespace }}"
    },
    {
      "name": "INTERFACE_NAME",
      "value": "eth0"
    },
    {
      "name": "DEPENDENCY_SERVICE",
      "value": "{{  include "joinListWithColon"  $deps.service }}"
    },
    {
      "name": "DEPENDENCY_JOBS",
      "value": "{{  include "joinListWithColon" $deps.jobs }}"
    },
    {
      "name": "COMMAND",
      "value": "echo done"
    }
  ]
}
{{- end -}}