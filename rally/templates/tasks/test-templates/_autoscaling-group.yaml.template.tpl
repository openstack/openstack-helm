heat_template_version: 2013-05-23

parameters:
  flavor:
    type: string
    default: m1.tiny
    constraints:
      - custom_constraint: nova.flavor
  image:
    type: string
    default: cirros-0.3.4-x86_64-uec
    constraints:
      - custom_constraint: glance.image
  scaling_adjustment:
    type: number
    default: 1
  max_size:
    type: number
    default: 5
    constraints:
      - range: {min: 1}


resources:
  asg:
    type: OS::Heat::AutoScalingGroup
    properties:
      resource:
        type: OS::Nova::Server
        properties:
            image: { get_param: image }
            flavor: { get_param: flavor }
      min_size: 1
      desired_capacity: 3
      max_size: { get_param: max_size }

  scaling_policy:
    type: OS::Heat::ScalingPolicy
    properties:
      adjustment_type: change_in_capacity
      auto_scaling_group_id: {get_resource: asg}
      scaling_adjustment: { get_param: scaling_adjustment }

outputs:
  scaling_url:
    value: {get_attr: [scaling_policy, alarm_url]}
