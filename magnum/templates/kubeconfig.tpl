{{- define "kubeconfig.tpl" }}
apiVersion: v1
kind: Config
clusters:
- name: {{ .Values.conf.capi.clusterName }}
  cluster:
    server: {{ .Values.conf.capi.apiServer }}
    certificate-authority-data: {{ .Values.conf.capi.certificateAuthorityData | quote }}
contexts:
- name: {{ .Values.conf.capi.contextName }}
  context:
    cluster: {{ .Values.conf.capi.clusterName }}
    user: {{ .Values.conf.capi.userName }}
current-context: {{ .Values.conf.capi.contextName }}
users:
- name: {{ .Values.conf.capi.userName }}
  user:
    client-certificate-data: {{ .Values.conf.capi.clientCertificateData | quote }}
    client-key-data: {{ .Values.conf.capi.clientKeyData | quote }}
{{- end }}
