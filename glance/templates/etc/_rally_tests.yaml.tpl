---
GlanceImages.create_and_delete_image:
- args:
    container_format: {{ .Values.conf.rally_tests.images.container_format }}
    disk_format: {{ .Values.conf.rally_tests.images.disk_format }}
    image_location: {{ .Values.conf.rally_tests.images.image_location }}
  context:
    users:
      tenants: 1
      users_per_tenant: 1
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
GlanceImages.create_and_list_image:
- args:
    container_format: {{ .Values.conf.rally_tests.images.container_format }}
    disk_format: {{ .Values.conf.rally_tests.images.disk_format }}
    image_location: {{ .Values.conf.rally_tests.images.image_location }}
  context:
    users:
      tenants: 1
      users_per_tenant: 1
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
