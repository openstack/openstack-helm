API Health Checks
=================

The Barbican, Cinder, CloudKitty, Freezer, Glance, Heat API and CloudFormation,
Magnum, Manila, Neutron, and Nova API and metadata charts configure the
``oslo.middleware`` ``/healthcheck`` endpoint with the ``disable_by_file``
backend. It checks whether a request worker can respond and whether a local
disable file exists. It does not check authentication, database, or
messaging dependencies.

The default disable file is ``/tmp/healthcheck_disable`` inside each API
container. The ``/tmp`` directory is backed by a writable ``emptyDir``
volume even when the container root filesystem is read-only. A Pod-local
temporary directory keeps this runtime marker separate from persistent
service data and avoids requiring a ``/var/lib/<service>`` mount.

Creating the file makes the endpoint return HTTP 503. Removing it restores
HTTP 200:

.. code-block:: console

    $ kubectl -n openstack exec <api-pod> -c <api-container> -- touch /tmp/healthcheck_disable
    $ kubectl -n openstack exec <api-pod> -c <api-container> -- rm /tmp/healthcheck_disable

The path can be overridden with
``conf.paste.app:healthcheck.disable_by_file_path``. Explicit overrides are
preserved, including Neutron's former ``/var/lib/neutron/healthcheck_disable``
path. Deployments that explicitly set a path under ``/etc`` must update it
to a writable location.

Where readiness uses ``/healthcheck``, the file makes the Pod unready and
removes it from Service endpoints. CloudKitty's default readiness probe
uses ``/``, so its disable file affects ``/healthcheck`` without changing
readiness.

Existing uWSGI stats liveness probes are independent of request workers.
Freezer and Manila use ``/healthcheck`` for liveness as well, so leaving the
file in place can restart their API containers. The file survives container
restarts in the same Pod; remove it to allow healthcheck probes to recover.
