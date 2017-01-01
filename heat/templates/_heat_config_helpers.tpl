{{- define "heat_config_volume_mounts" }}
- name: pod-etc-heat
  mountPath: /etc/heat
- name: pod-var-cache-heat
  mountPath: /var/cache/heat
- name: heat-json-policy
  mountPath: /etc/heat/policy.json
  subPath: policy.json
  readOnly: true
- name: heat-conf-cache
  mountPath: /etc/heat/conf/heat-cache.conf
  subPath: heat-cache.conf
  readOnly: true
- name: heat-conf-db
  mountPath: /etc/heat/conf/heat-db.conf
  subPath: heat-db.conf
  readOnly: true
- name: heat-conf-endpoints
  mountPath: /etc/heat/conf/heat-endpoints.conf
  subPath: heat-endpoints.conf
  readOnly: true
- name: heat-conf-keystone
  mountPath: /etc/heat/conf/heat-keystone.conf
  subPath: heat-keystone.conf
  readOnly: true
- name: heat-conf-log
  mountPath: /etc/heat/conf/heat-log.conf
  subPath: heat-log.conf
  readOnly: true
- name: heat-conf-messaging
  mountPath: /etc/heat/conf/heat-messaging.conf
  subPath: heat-messaging.conf
  readOnly: true
- name: heat-conf-options
  mountPath: /etc/heat/conf/heat-options.conf
  subPath: heat-options.conf
  readOnly: true
- name: heat-conf-paste
  mountPath: /etc/heat/conf/heat-paste.conf
  subPath: heat-paste.conf
  readOnly: true
- name: heat-conf-stack-domain
  mountPath: /etc/heat/conf/heat-stack-domain.conf
  subPath: heat-stack-domain.conf
  readOnly: true
- name: heat-conf-trustee
  mountPath: /etc/heat/conf/heat-trustee.conf
  subPath: heat-trustee.conf
  readOnly: true
{{- end }}

{{- define "heat_config_volumes" }}
- name: pod-etc-heat
  emptyDir: {}
- name: pod-var-cache-heat
  emptyDir: {}
- name: heat-json-policy
  configMap:
    name: heat-json-policy
- name: heat-conf-cache
  configMap:
    name: heat-conf-cache
- name: heat-conf-db
  secret:
    secretName: heat-conf-db
- name: heat-conf-endpoints
  configMap:
    name: heat-conf-endpoints
- name: heat-conf-keystone
  secret:
    secretName: heat-conf-keystone
- name: heat-conf-log
  configMap:
    name: heat-conf-log
- name: heat-conf-messaging
  secret:
    secretName: heat-conf-messaging
- name: heat-conf-options
  configMap:
    name: heat-conf-options
- name: heat-conf-paste
  configMap:
    name: heat-conf-paste
- name: heat-conf-stack-domain
  secret:
    secretName: heat-conf-stack-domain
- name: heat-conf-trustee
  secret:
    secretName: heat-conf-trustee
{{- end }}
