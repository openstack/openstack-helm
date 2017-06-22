---
NeutronNetworks.create_and_delete_networks:
- args:
    network_create_args: {}
  context:
    quotas:
      neutron:
        network: -1
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
NeutronNetworks.create_and_delete_ports:
- args:
    network_create_args: {}
    port_create_args: {}
    ports_per_network: 10
  context:
    network: {}
    quotas:
      neutron:
        network: -1
        port: -1
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
NeutronNetworks.create_and_delete_routers:
- args:
    network_create_args: {}
    router_create_args: {}
    subnet_cidr_start: 1.1.0.0/30
    subnet_create_args: {}
    subnets_per_network: 2
  context:
    network: {}
    quotas:
      neutron:
        network: -1
        router: -1
        subnet: -1
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
NeutronNetworks.create_and_delete_subnets:
- args:
    network_create_args: {}
    subnet_cidr_start: 1.1.0.0/30
    subnet_create_args: {}
    subnets_per_network: 2
  context:
    network: {}
    quotas:
      neutron:
        network: -1
        subnet: -1
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
NeutronNetworks.create_and_list_routers:
- args:
    network_create_args: {}
    router_create_args: {}
    subnet_cidr_start: 1.1.0.0/30
    subnet_create_args: {}
    subnets_per_network: 2
  context:
    network: {}
    quotas:
      neutron:
        network: -1
        router: -1
        subnet: -1
    users:
      tenants: 3
      users_per_tenant: 3
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
NeutronNetworks.create_and_list_subnets:
- args:
    network_create_args: {}
    subnet_cidr_start: 1.1.0.0/30
    subnet_create_args: {}
    subnets_per_network: 2
  context:
    network: {}
    quotas:
      neutron:
        network: -1
        subnet: -1
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
NeutronNetworks.create_and_show_network:
- args:
    network_create_args: {}
  context:
    quotas:
      neutron:
        network: -1
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
NeutronNetworks.create_and_update_networks:
- args:
    network_create_args: {}
    network_update_args:
      admin_state_up: false
      name: _updated
  context:
    quotas:
      neutron:
        network: -1
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
NeutronNetworks.create_and_update_ports:
- args:
    network_create_args: {}
    port_create_args: {}
    port_update_args:
      admin_state_up: false
      device_id: dummy_id
      device_owner: dummy_owner
      name: _port_updated
    ports_per_network: 5
  context:
    network: {}
    quotas:
      neutron:
        network: -1
        port: -1
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
NeutronNetworks.create_and_update_routers:
- args:
    network_create_args: {}
    router_create_args: {}
    router_update_args:
      admin_state_up: false
      name: _router_updated
    subnet_cidr_start: 1.1.0.0/30
    subnet_create_args: {}
    subnets_per_network: 2
  context:
    network: {}
    quotas:
      neutron:
        network: -1
        router: -1
        subnet: -1
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
NeutronNetworks.create_and_update_subnets:
- args:
    network_create_args: {}
    subnet_cidr_start: 1.4.0.0/16
    subnet_create_args: {}
    subnet_update_args:
      enable_dhcp: false
      name: _subnet_updated
    subnets_per_network: 2
  context:
    network: {}
    quotas:
      neutron:
        network: -1
        subnet: -1
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
NeutronNetworks.list_agents:
- args:
    agent_args: {}
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
NeutronSecurityGroup.create_and_list_security_groups:
- args:
    security_group_create_args: {}
  context:
    quotas:
      neutron:
        security_group: -1
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
NeutronSecurityGroup.create_and_update_security_groups:
- args:
    security_group_create_args: {}
    security_group_update_args: {}
  context:
    quotas:
      neutron:
        security_group: -1
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
