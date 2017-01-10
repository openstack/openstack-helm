[client.{{ .Values.ceph.cinder_user }}]
{{- if .Values.ceph.cinder_keyring }}
    key = {{ .Values.ceph.cinder_keyring }}
{{- else }}
    key = {{- include "secrets/ceph-client-key" . -}}
{{- end }}
