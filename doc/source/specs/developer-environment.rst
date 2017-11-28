..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode

..

=====================
Developer Environment
=====================

https://blueprints.launchpad.net/openstack-helm/+spec/developer-environment

Problem Description
===================

Developers require a simple way of instantiating a working environment for
OpenStack-Helm, that allows them to quickly begin development of the project.
This is more complex to achieve than many OpenStack Projects that can simply
rely upon a devstack plugin to achieve this. This is as OpenStack-Helm is
focused on the deployment of OpenStack (and associated) Projects, rather than
the development of the projects themselves, and also requires additional
supporting infrastructure, e.g. Kubernetes and a CNI.

Use cases
---------
1. Development of OpenStack-Helm
2. PoC deployments of OpenStack-Helm

Proposed Change
===============

The OpenStack-Helm Zuulv2 gates were written to allow use outside of
OpenStack-Infra, to quickly set up a Kubernetes cluster, with the adoption of
Zuulv3 underway it is logical to extend this paradigm to the Zuulv3 Playbooks.
This will be driven via a ``Makefile`` that will allow developers to perform the
following actions:

* Prepare Host(s) for OpenStack-Helm deployment
* Deploy Kubernetes via KubeADM, with charts for CNI and DNS services

At this point, curated scripts will be used to deploy OpenStack-Helm services on
demand as desired, with documentation provided to allow a new developer to
quickly set up either a single or multimode deployment of a reference
`OpenStack Compute Kit <https://governance.openstack.org/tc/reference/tags/starter-kit_compute.html>`_
environment with the addition of:

* Ceph backed Object Storage
* Ceph backed Block Storage (cinder)
* Orchestration (heat)
* Web UI (horizon)

A set of scripts will be provided to exercise the deployed environment that
checks the basic functionality of the deployed cloud, driven where possible via
OpenStack heat:

* Create external network
* Setup access to the external network from the development machine
* Create tenant network
* Create tenant router to link tenant network and external
* Create SSH Key in nova
* Create VM on tenant network
* Assign Floating IP to VM
* SSH into VM and check it can access the internet

This deployment process will be gated, to ensure that the development
the environment is consistently working against ``master`` for the
OpenStack-Helm repositories.

Security Impact
---------------
There will be no security impact, as it will deploy the charts in
OpenStack-Helm[-infra/-addons] upon a reference KubeADM administered cluster.

Performance Impact
------------------
This feature will not affect the performance of OpenStack-Helm.

Alternatives
------------
The alternative would be to continue supporting the current bash driven
containerized KubeADM and Kubelet approach, though this has the following
issues:

* The containerized Kubelet cannot survive a restart, as it does not setup
  mounts correctly.
* The bash scripts are largely undocumented and have grown to the point where
  they are very hard for a new developer to work on.
* The move to Zuulv3 native operation of the OpenStack-Helm gates mean there
  would be no code reuse between the gate and developer environments, so
  supporting the existing code for Zuulv2 will incur significant tech-debt.

Implementation
==============

Assignee(s)
-----------

Primary assignee:
  portdirect (Pete Birley)

Work Items
----------

The following work items need to be completed for this Specification to be
implemented.

* Update of Developer Documentation
* Update of Makefile for OpenStack-Helm-Infra to allow modular deployment of
  components
* Develop scripts for bringing up OpenStack-Helm Charts and perform basic
  interactive tests
* Add gate for developer environment

Testing
=======
A gate will be added to OpenStack-Helm that runs through the developer
environment deployment process.

Documentation Impact
====================
The developer documentation in OpenStack-Helm should be updated to match the
gated developer deploy process.
