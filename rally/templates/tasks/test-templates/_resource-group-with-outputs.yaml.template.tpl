heat_template_version: 2013-05-23
parameters:
  attr_wait_secs:
    type: number
    default: 0.5

resources:
  rg:
    type: OS::Heat::ResourceGroup
    properties:
      count: 10
      resource_def:
        type: OS::Heat::TestResource
        properties:
          attr_wait_secs: {get_param: attr_wait_secs}

outputs:
  val1:
    value: {get_attr: [rg, resource.0.output]}
  val2:
    value: {get_attr: [rg, resource.1.output]}
  val3:
    value: {get_attr: [rg, resource.2.output]}
  val4:
    value: {get_attr: [rg, resource.3.output]}
  val5:
    value: {get_attr: [rg, resource.4.output]}
  val6:
    value: {get_attr: [rg, resource.5.output]}
  val7:
    value: {get_attr: [rg, resource.6.output]}
  val8:
    value: {get_attr: [rg, resource.7.output]}
  val9:
    value: {get_attr: [rg, resource.8.output]}
  val10:
    value: {get_attr: [rg, resource.9.output]}