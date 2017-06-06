---
KeystoneBasic.add_and_remove_user_role:
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
KeystoneBasic.authenticate_user_and_validate_token:
- args: {}
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
KeystoneBasic.create_add_and_list_user_roles:
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
KeystoneBasic.create_and_delete_ec2credential:
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
KeystoneBasic.create_and_delete_role:
- runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
KeystoneBasic.create_and_delete_service:
- args:
    description: test_description
    service_type: Rally_test_type
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
KeystoneBasic.create_and_get_role:
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
KeystoneBasic.create_and_list_ec2credentials:
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
KeystoneBasic.create_and_list_services:
- args:
    description: test_description
    service_type: Rally_test_type
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
KeystoneBasic.create_and_list_tenants:
- args: {}
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
KeystoneBasic.create_and_list_users:
- args: {}
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
KeystoneBasic.create_delete_user:
- args: {}
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
KeystoneBasic.create_tenant:
- args: {}
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
KeystoneBasic.create_tenant_with_users:
- args:
    users_per_tenant: 1
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
KeystoneBasic.create_update_and_delete_tenant:
- args: {}
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
KeystoneBasic.create_user:
- args: {}
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
KeystoneBasic.create_user_set_enabled_and_delete:
- args:
    enabled: true
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
- args:
    enabled: false
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
KeystoneBasic.create_user_update_password:
- args: {}
  runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
KeystoneBasic.get_entities:
- runner:
    concurrency: 1
    times: 1
    type: constant
  sla:
    failure_rate:
      max: 0
