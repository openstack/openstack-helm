heat_template_version: 2013-05-23

description: >
  Test template for create-update-delete-stack scenario in rally.
  The template updates resource parameters without resource re-creation(replacement)
  in the stack defined by autoscaling_policy.yaml.template. It allows to measure
  performance of "pure" resource update operation only.

resources:
  test_group:
    type: OS::Heat::AutoScalingGroup
    properties:
      desired_capacity: 0
      max_size: 0
      min_size: 0
      resource:
        type: OS::Heat::RandomString
  test_policy:
    type: OS::Heat::ScalingPolicy
    properties:
      adjustment_type: change_in_capacity
      auto_scaling_group_id: { get_resource: test_group }
      scaling_adjustment: -1