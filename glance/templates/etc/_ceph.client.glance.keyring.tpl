[client.{{ .Values.ceph.glance_user }}]
{{- if .Values.ceph.glance_keyring }}
    key = {{ .Values.ceph.glance_keyring }}
{{- else }}
    key = {{- include "secrets/ceph-client-key" . -}}
{{- end }}
