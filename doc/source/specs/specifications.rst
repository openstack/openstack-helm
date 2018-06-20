=====================
Project Specfications
=====================

Specifications in this repository represent a consensus on the topics covered
within.  They should be considered a mandate on the path forward with regards
to the content on which they are drafted.

Purpose
-------

A specification should precede any broad-reaching technical changes or proposals
to OpenStack-Helm.  Examples of changes requiring a specification include:  a
standard format to the values.yaml files, multiple backend support for neutron,
and the approach for logging and monitoring in OpenStack-Helm.  Some additional
features will not need an accompanying specification, but may be tied back to an
existing specification.  An example of this would be introducing a service in
OpenStack-Helm that could be included under the scope of a specification already
drafted and approved.

Process
-------

Before drafting a specification, a blueprint should be filed in Storyboard_
along with any dependencies the blueprint requires.  Once the blueprint has been
registered, submit the specification as a patch set to the specs/ directory
using the supplied template.

More information about the blueprint + specification lifecycle can be found
here_.

.. _Storyboard: https://storyboard.openstack.org/#!/project_group/64
.. _here: https://wiki.openstack.org/wiki/Blueprints#Blueprints_and_Specs
