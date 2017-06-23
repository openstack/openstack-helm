---
CinderVolumes.create_and_delete_volume:
- args:
    size: 1
  runner:
    type: "constant"
    times: 1
    concurrency: 1
  context:
    users:
      tenants: 1
      users_per_tenant: 1
  sla:
    failure_rate:
      max: 0
- args:
    size:
      min: 1
      max: 5
  runner:
    type: "constant"
    times: 1
    concurrency: 1
  context:
    users:
      tenants: 1
      users_per_tenant: 1
  sla:
    failure_rate:
      max: 0
