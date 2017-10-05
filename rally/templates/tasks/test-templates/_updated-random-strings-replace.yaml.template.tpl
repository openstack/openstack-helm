heat_template_version: 2014-10-16

description: >
  Test template for create-update-delete-stack scenario in rally.
  The template deletes one resource from the stack defined by
  random-strings.yaml.template and re-creates it with the updated parameters
  (so-called update-replace). That happens because some parameters cannot be
  changed without resource re-creation. The template allows to measure performance
  of update-replace operation.

resources:
  test_string_one:
    type: OS::Heat::RandomString
    properties:
      length: 20
  test_string_two:
    type: OS::Heat::RandomString
    properties:
      length: 40
