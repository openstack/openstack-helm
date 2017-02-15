{{- define "helm-toolkit.keystone_user_create_env_vars" }}
{{- $ksUserSecret := .ksUserSecret }}
- name: SERVICE_OS_REGION_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_REGION_NAME
- name: SERVICE_OS_PROJECT_DOMAIN_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PROJECT_DOMAIN_NAME
- name: SERVICE_OS_PROJECT_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PROJECT_NAME
- name: SERVICE_OS_USER_DOMAIN_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_USER_DOMAIN_NAME
- name: SERVICE_OS_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_USERNAME
- name: SERVICE_OS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PASSWORD
{{- end }}
