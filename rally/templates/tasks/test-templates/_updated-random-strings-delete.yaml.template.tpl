heat_template_version: 2014-10-16

description: >
  Test template for create-update-delete-stack scenario in rally.
  The template deletes one resource from the stack defined by random-strings.yaml.template.

resources:
  test_string_one:
    type: OS::Heat::RandomString
    properties:
      length: 20
