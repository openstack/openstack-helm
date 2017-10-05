heat_template_version: 2013-05-23

parameters:
  # set all correct defaults for parameters before launch test
  public_net:
    type: string
    default: public
  image:
    type: string
    default: cirros-0.3.4-x86_64-uec
  flavor:
    type: string
    default: m1.tiny
  cidr:
    type: string
    default: 11.11.11.0/24

resources:
  server:
    type: OS::Nova::Server
    properties:
      image: {get_param: image}
      flavor: {get_param: flavor}
      networks:
        - port: { get_resource: server_port }

  router:
    type: OS::Neutron::Router
    properties:
      external_gateway_info:
        network: {get_param: public_net}

  router_interface:
    type: OS::Neutron::RouterInterface
    properties:
      router_id: { get_resource: router }
      subnet_id: { get_resource: private_subnet }

  private_net:
    type: OS::Neutron::Net

  private_subnet:
    type: OS::Neutron::Subnet
    properties:
      network: { get_resource: private_net }
      cidr: {get_param: cidr}

  port_security_group:
    type: OS::Neutron::SecurityGroup
    properties:
      name: default_port_security_group
      description: >
        Default security group assigned to port. The neutron default group is not
        used because neutron creates several groups with the same name=default and
        nova cannot chooses which one should it use.

  server_port:
    type: OS::Neutron::Port
    properties:
      network: {get_resource: private_net}
      fixed_ips:
        - subnet: { get_resource: private_subnet }
      security_groups:
        - { get_resource: port_security_group }
