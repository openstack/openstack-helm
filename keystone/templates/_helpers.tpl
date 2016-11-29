{{- define "joinListWithColon" -}}
{{ range $k, $v := . }}{{ if $k }},{{ end }}{{ $v }}{{ end }}
{{- end -}}
