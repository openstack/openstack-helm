heat_template_version: 2013-05-23

description: Template for testing caching.

parameters:
  count:
    type: number
    default: 40
  delay:
    type: number
    default: 0.1

resources:
  rg:
    type: OS::Heat::ResourceGroup
    properties:
      count: {get_param: count}
      resource_def:
          type: OS::Heat::TestResource
          properties:
            constraint_prop_secs: {get_param: delay}
