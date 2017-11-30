=============
Nginx Sidecar
=============

Blueprint: https://blueprints.launchpad.net/openstack-helm/+spec/nginx-sidecar

Problem Description
===================

In a secured deployment, TLS certificates are used to protect the transports
amongst the various components.  In some cases, this requires additional
mechanism to handle TLS offloading and to terminate the connection gracefully:

* services do not handle TLS offloading and termination,
* services whose native handling of TLS offloading and termination cause major
  performance impact, for example, eventlet.

Proposed Change
===============

This specification proposes to add a nginx sidecar container to the
pod for service that requires the tls offloading. The nginx can be used
to handle the TLS offoading and terminate the TLS connection, and routes
the traffic to the service via localhost (127.0.0.1).

Security Impact
---------------

This enhances the system's security design by allowing pods with services that
cannot natively manage TLS to secure the traffic to the service pod.

Performance Impact
------------------

There is no significant performance impact as the traffic will be locally
routed (via 127.0.0.1) and may potentially improve performance for services
whose native TLS handling is inefficient.

Alternatives
------------

* Instead of using nginx, haproxy can be used instead.

Implementation
==============

Assignee(s)
-----------

Primary assignee:
  Pete Birley <pete@port.direct>

Work Items
----------

* Update ``helm toolkit`` to provide snippet to create the nginx sidecar
  container for the services that require it.
* Update service charts to use the updated ``helm toolkit``.
* Update relevant Documentation.

Testing
=======

The testing will be performed by the OpenStack-Helm gate to demonstrate
the sidecar container correctly routes traffic to the correct services.

Documentation Impact
====================

OpenStack-Helm documentation will be updated to indicate the usage of the
nginx sidecar.
