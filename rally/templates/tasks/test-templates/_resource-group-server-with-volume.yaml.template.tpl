heat_template_version: 2014-10-16

description: >
  Test template that creates a resource group with servers and volumes.
  The template allows to create a lot of nested stacks with standard
  configuration: nova instance, cinder volume attached to that instance

parameters:

  num_instances:
    type: number
    description: number of instances that should be created in resource group
    constraints:
      - range: {min: 1}
  instance_image:
    type: string
    default: cirros-0.3.4-x86_64-uec
  instance_volume_size:
    type: number
    description: Size of volume to attach to instance
    default: 1
    constraints:
      - range: {min: 1, max: 1024}
  instance_flavor:
    type: string
    description: Type of the instance to be created.
    default: m1.tiny
  instance_availability_zone:
    type: string
    description: The Availability Zone to launch the instance.
    default: nova

resources:
  group_of_volumes:
    type: OS::Heat::ResourceGroup
    properties:
      count: {get_param: num_instances}
      resource_def:
        type: templates/server-with-volume.yaml.template
        properties:
          image: {get_param: instance_image}
          volume_size: {get_param: instance_volume_size}
          flavor: {get_param: instance_flavor}
          availability_zone: {get_param: instance_availability_zone}
