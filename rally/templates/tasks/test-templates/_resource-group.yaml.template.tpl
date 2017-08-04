heat_template_version: 2014-10-16

description: Test template for rally create-update-delete scenario

resources:
  test_group:
    type: OS::Heat::ResourceGroup
    properties:
      count: 2
      resource_def:
        type: OS::Heat::RandomString
        properties:
          length: 20