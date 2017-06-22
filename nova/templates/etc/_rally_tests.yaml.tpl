---
NovaAgents.list_agents:
- runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
NovaAggregates.create_and_get_aggregate_details:
- args:
    availability_zone: nova
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
NovaAggregates.create_and_update_aggregate:
- args:
    availability_zone: nova
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
NovaAggregates.list_aggregates:
- runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
NovaAvailabilityZones.list_availability_zones:
- args:
    detailed: true
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
NovaFlavors.create_and_delete_flavor:
- args:
    disk: 1
    ram: 500
    vcpus: 1
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
NovaFlavors.create_and_list_flavor_access:
- args:
    disk: 1
    ram: 500
    vcpus: 1
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
NovaFlavors.create_flavor:
- args:
    disk: 1
    ram: 500
    vcpus: 1
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
NovaFlavors.create_flavor_and_add_tenant_access:
- args:
    disk: 1
    ram: 500
    vcpus: 1
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
NovaFlavors.create_flavor_and_set_keys:
- args:
    disk: 1
    extra_specs:
      quota:disk_read_bytes_sec: 10240
    ram: 500
    vcpus: 1
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
NovaFlavors.list_flavors:
- args:
    detailed: true
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
NovaHosts.list_hosts:
- runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
NovaHypervisors.list_and_get_hypervisors:
- args:
    detailed: true
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
NovaHypervisors.list_and_get_uptime_hypervisors:
- args:
    detailed: true
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
NovaHypervisors.list_and_search_hypervisors:
- args:
    detailed: true
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
NovaHypervisors.list_hypervisors:
- args:
    detailed: true
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
NovaHypervisors.statistics_hypervisors:
- args: {}
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
NovaImages.list_images:
- args:
    detailed: true
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
NovaKeypair.create_and_delete_keypair:
- context:
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
NovaKeypair.create_and_list_keypairs:
- context:
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
NovaSecGroup.create_and_delete_secgroups:
- args:
    rules_per_security_group: 1
    security_group_count: 1
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
NovaSecGroup.create_and_list_secgroups:
- args:
    rules_per_security_group: 1
    security_group_count: 1
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
NovaSecGroup.create_and_update_secgroups:
- args:
    security_group_count: 1
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
NovaServerGroups.create_and_list_server_groups:
- args:
    all_projects: false
    kwargs:
      policies:
      - affinity
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
NovaServices.list_services:
- runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
