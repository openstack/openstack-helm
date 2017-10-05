heat_template_version: 2014-10-16

description: Test template for rally create-update-delete scenario

resources:
  test_string_one:
    type: OS::Heat::RandomString
    properties:
      length: 20
  test_string_two:
    type: OS::Heat::RandomString
    properties:
      length: 20
