====================
Values File Ordering
====================

Problem Description
===================

Each chart's values.yaml file contains various settings such as docker
image definition, chart structure setting, form of the resources being
distributed, and process configuration.  Currently, the structure of the yaml
file is complicated, and finding keys between charts proves difficult due to the
lack of uniform values organization across charts.

This specification proposes introducing a uniform values.yaml structure across
all charts in openstack-helm, openstack-helm-infra, and openstack-helm-addons,
with the goal of reducing the complexities of working across multiple charts and
reducing the effort for creating new charts.

Proposed Change
===============

This specification proposes defining entries in the values.yaml file into two
categories: top-level keys, and their children (sub-level) keys.

* The top-level keys are based on the organizational keys common to all charts
  in the openstack-helm repositories.  The top-level keys are strictly ordered
  according to function, which creates a common organization pattern between all
  charts.
* All keys under top-level keys are listed in alphabetical order, with the
  exception of the conf key.  As some configuration files require a strict
  ordering of their content, excluding this key from any alphabetical
  organization is required.

This specification also proposes to restrict the addition of any new top-level
keys in charts across all OpenStack-Helm repositories, in order to maintain the
common structure the ordering creates.  The addition of a new top-level key
shall be agreed upon by the OpenStack-Helm team on a case-by-case basis.  The
addition of any new top-level keys should be documented, and this specification
shall be amended to account for any added keys.

Top-level keys are placed in this order:

* images
  * sub-keys (alphabetical order)
* labels
  * sub-keys (alphabetical order)
* dependencies
  * sub-keys (alphabetical order)
* pod
  * sub-keys (alphabetical order)
* secrets
  * sub-keys (alphabetical order)
* endpoints
  * sub-keys (alphabetical order)
* bootstrap
  * sub-keys (alphabetical order)
* network
  * sub-keys (alphabetical order)
* manifests
  * sub-keys (alphabetical order)
* monitoring
  * sub-keys (alphabetical order)
* conf
  * sub-keys (up-to-chart-developer)

Security Impact
---------------

No security impact.

Performance Impact
------------------

This feature will not affect the performance of OpenStack-Helm.

Alternatives
------------

The alternative is to provide no organization layout for charts across all
openstack-helm repositories.

Implementation
==============

Assignee(s)
-----------

Primary assignees:
  powerds0111 (DaeSeong Kim <daeseong.kim@sk.com>)
  srwilkers (Steve Wilkerson <sw5822@att.com>)

Work Items
----------

The following work items need to be completed for this specification to be
implemented.

* Update of developer documentation
* Add a template highlighting the updated values ordering for use in chart
  development
* Change ordering of keys across all charts in openstack-helm,
  openstack-helm-infra, and openstack-helm-addons

Testing
=======

To successfully enforce the ordering defined here, our gates need a method for
validating the ordering and the schema of all values.yaml files.  Without such
a mechanism, the overhead associated with properly reviewing and validating any
changes to the structure will be substantial.  A tool, such as yamllint, would
provide this functionality and remove the need to write a custom validation tool

Documentation Impact
====================

The developer documentation in OpenStack-Helm should be updated to guide key
ordering on value files.
