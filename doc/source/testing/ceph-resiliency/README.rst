========================================
Resiliency Tests for OpenStack-Helm/Ceph
========================================

Mission
=======

The goal of our resiliency tests for `OpenStack-Helm/Ceph
<https://github.com/openstack/openstack-helm/tree/master/ceph>`_ is to
show symptoms of software/hardware failure and provide the solutions.

Caveats:
   - Our focus lies on resiliency for various failure scenarios but
     not on performance or stress testing.

Software Failure
================
* `Monitor failure <./monitor-failure.html>`_
* `OSD failure <./osd-failure.html>`_

Hardware Failure
================
* `Disk failure <./disk-failure.html>`_
* `Host failure <./host-failure.html>`_

