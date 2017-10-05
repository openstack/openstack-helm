heat_template_version: 2014-10-16

description: >
  Test template for create-update-delete-stack scenario in rally.
  The template updates one resource from the stack defined by resource-group.yaml.template
  and adds children resources to that resource.

resources:
  test_group:
    type: OS::Heat::ResourceGroup
    properties:
      count: 3
      resource_def:
        type: OS::Heat::RandomString
        properties:
          length: 20
