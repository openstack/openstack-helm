==============================================
Resiliency Tests for OpenStack-Helm-Infra/Ceph
==============================================

Mission
=======

The goal of our resiliency tests for `OpenStack-Helm-Infra/Ceph
<https://github.com/openstack/openstack-helm-infra/tree/master/ceph>`_ is to
show symptoms of software/hardware failure and provide the solutions.

Caveats:
   - Our focus lies on resiliency for various failure scenarios but
     not on performance or stress testing.

Software Failure
================
* `CRUSH Failure Domain <./failure-domain.html>`_

Hardware Failure
================
