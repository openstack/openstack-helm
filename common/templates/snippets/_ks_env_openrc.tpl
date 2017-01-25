{{- define "env_ks_openrc_tpl" }}
{{- $ksUserSecret := .ksUserSecret }}
- name: OS_IDENTITY_API_VERSION
  value: "3"
- name: OS_AUTH_URL
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_AUTH_URL
- name: OS_REGION_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_REGION_NAME
- name: OS_PROJECT_DOMAIN_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PROJECT_DOMAIN_NAME
- name: OS_PROJECT_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PROJECT_NAME
- name: OS_USER_DOMAIN_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_USER_DOMAIN_NAME
- name: OS_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_USERNAME
- name: OS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $ksUserSecret }}
      key: OS_PASSWORD
{{- end }}
