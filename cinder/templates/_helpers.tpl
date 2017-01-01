{{- define "joinListWithColon" -}}
{{ range $k, $v := . }}{{ if $k }},{{ end }}{{ $v }}{{ end }}
{{- end -}}

{{- define "env_admin_openrc" }}
- name: OS_IDENTITY_API_VERSION
  value: "3"
- name: OS_AUTH_URL
  valueFrom:
    secretKeyRef:
      name: cinder-env-keystone-admin
      key: OS_AUTH_URL
- name: OS_REGION_NAME
  valueFrom:
    secretKeyRef:
      name: cinder-env-keystone-admin
      key: OS_REGION_NAME
- name: OS_PROJECT_DOMAIN_NAME
  valueFrom:
    secretKeyRef:
      name: cinder-env-keystone-admin
      key: OS_PROJECT_DOMAIN_NAME
- name: OS_PROJECT_NAME
  valueFrom:
    secretKeyRef:
      name: cinder-env-keystone-admin
      key: OS_PROJECT_NAME
- name: OS_USER_DOMAIN_NAME
  valueFrom:
    secretKeyRef:
      name: cinder-env-keystone-admin
      key: OS_USER_DOMAIN_NAME
- name: OS_USERNAME
  valueFrom:
    secretKeyRef:
      name: cinder-env-keystone-admin
      key: OS_USERNAME
- name: OS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: cinder-env-keystone-admin
      key: OS_PASSWORD
{{- end }}

{{- define "container_ks_service" }}
image: {{ .Values.images.ks_service }}
imagePullPolicy: {{ .Values.images.pull_policy }}
command:
  - bash
  - /tmp/ks-service.sh
volumeMounts:
  - name: ks-service-sh
    mountPath: /tmp/ks-service.sh
    subPath: ks-service.sh
    readOnly: true
env:
{{ include "env_admin_openrc" . | indent 2 }}
{{- end }}

{{- define "container_ks_endpoint" }}
image: {{ .Values.images.ks_endpoints }}
imagePullPolicy: {{ .Values.images.pull_policy }}
command:
  - bash
  - /tmp/ks-endpoints.sh
volumeMounts:
  - name: ks-endpoints-sh
    mountPath: /tmp/ks-endpoints.sh
    subPath: ks-endpoints.sh
    readOnly: true
env:
{{ include "env_admin_openrc" . | indent 2 }}
{{- end }}
