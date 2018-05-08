..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode

..

===============================
OpenStack-Helm 1.0 Requirements
===============================

Topic:
osh-1.0-requirements_

.. _osh-1.0-requirements: https://review.openstack.org/#/q/topic:bp/osh-1.0-requirements

Problem Description
===================

OpenStack-Helm has undergone rapid development and maturation over its
lifetime, and is nearing the point of real-world readiness.  This spec
details the functionality that must be implemented in OpenStack-Helm for it to
be considered ready for a 1.0 release, as well as for general use.

Use case
---------
This spec describes a point-in-time readiness for OpenStack-Helm 1.0,
after which it will be for historical reference only.

Proposed Change
===============

The proposed requirements for a 1.0 release are as follows:

Gating
------
A foundational requirement of 1.0 readiness is the presence of robust gating
that will ensure functionality, backward compatibility, and upgradeability.
This will allow development to continue and for support for new versions of
OpenStack to be added post-1.0.
The following gating requirements must be met:

**Helm test for all charts**

Helm test is the building block for all gating.  Each chart must integrate a
helm-test script which validates proper functionality.  This is already a
merge criterion for new charts, but a handful of older charts still need
for helm test functionality to be added.  No additional charts will be merged
prior to 1.0 unless they meet this requirement (and others in this document).

**Resiliency across reboots**

All services should survive node reboots, and their functionality validated
following a reboot by a gate.

**Upgrades**

Gating must prove that upgrades from each supported OpenStack version to the
next operate flawlessly, using the default image set (LOCI).  Specifically,
each OpenStack chart should be upgraded from one release to the next, and
each infrastructure service from one minor version to the next.  Both the
container image and configuration must be modified as part of this upgrade.
At minimum, Newton to Ocata upgrade must be validated for the 1.0 release.

Code Completion and Refactoring
-------------------------------
A number of in-progress and planned development efforts must be completed
prior to 1.0, to ensure a stable OpenStack-Helm interface thereafter.

**Charts in the appropriate project**

All charts should migrate to their appropriate home project as follows:

- OpenStack-Helm for OpenStack services
- OpenStack-Helm-Infra for supporting services
- OpenStack-Helm-Addons for ancillary services

In particular, these charts must move to OpenStack-Helm-Infra:

- ceph
- etcd
- ingress
- ldap
- libvirt
- mariadb
- memcached
- mongodb
- openvswitch
- postgresql
- rabbitmq

**Combined helm-toolkit**

Currently both OpenStack-Helm and OpenStack-Helm-Infra have their own parallel
versions of the Helm-Toolkit library chart.  They must be combined into a
single chart in OpenStack-Helm-Infra prior to 1.0.

**Standardization of manifests**

Work is underway to refactor common manifest patterns into reusable snippets
in Helm-Toolkit.  The following manifests have yet to be combined:

- Database drop Job
- Prometheus exporters
- API Deployments
- Worker Deployments
- StatefulSets
- CronJobs
- Etc ConfigMaps
- Bin ConfigMaps

**Standardization of values**

OpenStack-Helm has developed a number of conventions around the format and
ordering of charts' `values.yaml` file, in support of both reusable Helm-Toolkit
functions and ease of developer ramp-up.  For 1.0 readiness, OpenStack-Helm must
cement these conventions within a spec, as well as the ordering of `values.yaml`
keys. These conventions must then be gated to guarantee conformity.
The spec in progress can be found here [1]_.

**Inclusion of all core services**

Charts for all core OpenStack services must be present to achieve 1.0
releasability.  The only core service outstanding at this time is Swift.

**Split Ceph chart**

The monolithic Ceph chart does not allow for following Ceph upgrade best
practices, namely to upgrade Mons, OSDs, and client services in that order.
The Ceph chart must therefore be split into at least three charts (one
for each of the above upgrade phases) prior to 1.0 to ensure smooth
in-place upgradability.

**Values-driven config files**

In order to maximize flexibility for operators, and to help facilitate
upgrades to newer versions of containerized software without editing
the chart itself, all configuration files will be specified dynamically
based on `values.yaml` and overrides.  In most cases the config files
will be generated based on the YAML values tree itself, and in some
cases the config file content will be specified in `values.yaml` as a
string literal.

Documentation
-------------
Comprehensive documentation is key to the ability for real-world operators to
benefit from OpenStack-Helm, and so it is a requirement for 1.0 releasability.
The following outstanding items must be completed from a documentation
perspective:

**Document version requirements**

Version requirements for the following must be documented and maintained:

- Kubernetes
- Helm
- Operating system
- External charts (Calico)

**Document Kubernetes requirements**

OpenStack-Helm supports a "bring your own Kubernetes" paradigm.  Any
particular k8s configuration or feature requirements must be
documented.

- Hosts must use KubeDNS / CoreDNS for resolution
- Kubernetes must enable mount propagation (until it is enabled by default)
- Helm must be installed

Examples of how to set up the above under KubeADM and KubeSpray-based clusters
must be documented as well.

**OpenStack-Helm release process**

The OpenStack-Helm release process will be somewhat orthogonal to the
OpenStack release process, and the differences and relationship between the
two must be documented in a spec.  This will help folks quickly understand why
OpenStack-Helm is a Release-Independent project from an OpenStack perspective.

**Release notes**

Release notes for the 1.0 release must be prepared, following OpenStack
best practices.  The criteria for future changes that should be included
in release notes in an ongoing fashion must be defined / documented as well.

- `values.yaml` changes
- New charts
- Any other changes to the external interface of OpenStack-Helm

**LMA Operations Guide**

A basic Logging, Monitoring, and Alerting-oriented operations guide must be in
place, illustrating for operators (and developers) how to set up and use an
example LMA setup for OpenStack and supporting services.  It will include
instructions on how to perform basic configuration and how to access and use
the user interfaces at a high level.  It will also link out to more detailed
documentation for the LMA tooling itself.

Process and Tooling
-------------------
To facilitate effective collaboration and communication across the
OpenStack-Helm community team, work items for the enhancements above will be
captured in Storyboard.  Therefore, migration from Launchpad to Storyboard
must be accomplished prior to the 1.0 release.  Going forward, Storyboard
will be leveraged as a tool to collaboratively define and communicate the
OpenStack-Helm roadmap.

Security Impact
---------------
No impact

Performance Impact
------------------
No impact

Alternatives
------------
This spec lays out the criteria for a stable and reliable 1.0 release, which
can serve as the basis for real-world use as well as ongoing development.
The alternative approaches would be to either iterate indefinitely without
defining a 1.0 release, which would fail to signal to operators the point at
which the platform is ready for real-world use; or, to define a 1.0 release
which fails to satisfy key features which real-world operators need.

Implementation
==============

This spec describes a wide variety of self-contained work efforts, which will
be implemented individually by the whole OpenStack-Helm team.

Assignee(s)
-----------

Primary assignee:

- mattmceuen (Matt McEuen <matt.mceuen@att.com>) for coordination
- powerds (DaeSeong Kim <daeseong.kim@sk.com>) for the
  `values.yaml` ordering spec [1]_
- portdirect (Pete Birley <pete@port.direct>) for the
  release management spec [2]_
- randeep.jalli (Randeep Jalli <rj2083@att.com>) and
  renmak (Renis Makadia <renis.makadia@att.com>) for splitting
  up the Ceph chart
- rwellum (Rich Wellum <richwellum@gmail.com>) for coordination
  of Storyboard adoption
- Additional assignees TBD

Work Items
----------

See above for the list of work items.

Testing
=======
See above for gating requirements.

Documentation Impact
====================
See above for documentation requirements.

References
==========

.. [1] https://review.openstack.org/#/c/552485/
.. [2] TODO - release management spec
