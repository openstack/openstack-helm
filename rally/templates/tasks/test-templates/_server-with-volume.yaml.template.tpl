heat_template_version: 2013-05-23

parameters:
  # set all correct defaults for parameters before launch test
  image:
    type: string
    default: cirros-0.3.4-x86_64-uec
  flavor:
    type: string
    default: m1.tiny
  availability_zone:
    type: string
    description: The Availability Zone to launch the instance.
    default: nova
  volume_size:
    type: number
    description: Size of the volume to be created.
    default: 1
    constraints:
      - range: { min: 1, max: 1024 }
        description: must be between 1 and 1024 Gb.

resources:
  server:
    type: OS::Nova::Server
    properties:
      image: {get_param: image}
      flavor: {get_param: flavor}
  cinder_volume:
    type: OS::Cinder::Volume
    properties:
      size: { get_param: volume_size }
      availability_zone: { get_param: availability_zone }
  volume_attachment:
    type: OS::Cinder::VolumeAttachment
    properties:
      volume_id: { get_resource: cinder_volume }
      instance_uuid: { get_resource: server}
      mountpoint: /dev/vdc
