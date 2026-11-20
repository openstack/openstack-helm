..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode

..

=====================================================
Restarting Workloads When Their Credentials Change
=====================================================

Problem Description
===================

The MariaDB, RabbitMQ and Keystone controllers write the credentials of a
service into secrets that its workloads project as ``oslo.config`` snippets,
for example ``keystone-db-conn``. An OpenStack service reads its configuration
only when it starts. When a ``helm upgrade`` rotates a password, the MariaDB
db controller alters the account and rewrites the snippet, the kubelet
eventually refreshes the projected file, but the running service keeps the
old password and is denied as soon as it reconnects. Nothing restarts it, and
the upgrade fails on its own hooks, which call the service.

Restarting the workloads is not enough by itself. A pod that the upgrade
creates starts before the controller rewrites the snippet, so it mounts the
old content. The kubelet refreshes a projected secret only when it syncs the
pod: a container that waits for the new content sees it a minute or more
later, and a check against the API alone lets the service start on the stale
file.

A first fix for keystone (https://review.opendev.org/c/openstack/openstack-helm/+/1012861)
writes the Helm release revision into the ``Connection`` and the API's pod
template, and adds an init container that waits until the projected file
carries that revision. It works, but every chart would need its own init
container, the API restarts on every upgrade whether or not the credentials
changed, and the wait inside the init container takes up to a minute and a
half.

Use cases
---------

1. An operator rotates a database or messaging password with ``helm upgrade``,
   and the upgrade succeeds with every service running on the new password.
2. An upgrade that does not change the credentials restarts nothing.
3. A service never starts on a stale credentials snippet.

Rotating a password outside Helm is not a use case: the charts render the
password secrets, and a password changes only through an upgrade.

Proposed Change
===============

Have the chart mark the content of the snippet it expects, and have
``kubernetes-entrypoint`` wait until the snippet mounted in the pod carries
that mark. No new controller and no new custom resource.

Credentials marker
------------------

The chart already knows everything the snippet is rendered from: the user,
the password, the host, the database. It computes a marker from them, an
HMAC-SHA256 keyed by the database admin password, and renders it twice:

* as a comment line in the format of the ``Connection``, for example
  ``# credentials: 3f9a0c...``, so that the db controller writes it into the
  snippet together with the new connection URL;
* in the pod template, as the line the entrypoint init container waits for.

The pod template changes only when the marker changes, so the workload rolls
only when its credentials change (use case 2). The key keeps the marker from
being a hash of the password: whoever can read the pod template cannot test
password guesses against it. Rotating the admin password changes every
marker and restarts the services once.

Waiting for the snippet
-----------------------

A new ``kubernetes-entrypoint`` dependency, ``DEPENDENCY_FILE``, waits until
a file contains a line:

.. code-block:: json

  [{"path": "/etc/keystone/keystone.conf.d/database.conf",
    "line": "# credentials: 3f9a0c...",
    "timeout": 10}]

When the line does not appear within ``timeout`` seconds, the entrypoint
exits with an error. The kubelet then syncs the pod, refreshes its projected
secrets and restarts the init container, which finds the new content. The
entrypoint never succeeds before it has seen the line itself, and a refreshed
file does not go back, so the service always starts on the new snippet (use
case 3).

Measured on Kubernetes 1.34 with a pod whose secret changes while its init
container runs:

* the file seen by a running init container is not refreshed until the next
  periodic sync, up to 81 seconds in the keystone tests;
* after the init container exits, the kubelet refreshes the file
  asynchronously, and in 5 of 16 runs the main container started on the old
  content;
* with the exit on timeout, 6 of 6 runs restarted the init container once and
  started the main container on the new content, about 8 seconds after the
  secret changed.

The resolver reads a local file, like the existing ``socket`` dependency, so
it needs no access to the API and nothing about MariaDB.

Ordering of a rotation
----------------------

#. Helm applies the new password secret, the ``Connection`` with the new
   marker and the workload with the new pod template; the rollout starts.
#. The new pod mounts the old snippet, and its init container waits.
#. The db controller alters the account and rewrites the snippet in one
   sweep.
#. The init container times out, the kubelet refreshes the snippet, and the
   restarted init container finds the marker; the service starts.
#. The post-upgrade hooks reach the restarted service. The bootstrap jobs
   already retry (``backoffLimit`` 1000) while the old pods are denied.

Between steps 3 and 4 the old pods are denied new database connections. With
one replica the service is down while the new pod waits, as with any
restart.

Scope
-----

* ``kubernetes-entrypoint``: the ``DEPENDENCY_FILE`` dependency and the exit
  on timeout.
* ``helm-toolkit``: render ``DEPENDENCY_FILE`` from a ``files`` list in the
  dependencies, as it renders ``custom_resources`` today. The chart passes the
  snippet volume in the mounts of the init container.
* keystone first, replacing the init container proposed in the change above,
  then the other charts that project a ``Connection``.
* Messaging credentials work the same way, with a marker in the format of the
  RabbitMQ ``Connection``.

Backward compatibility
----------------------

A chart renders the marker and the file dependency only when its database
connection comes from a ``Connection``. An entrypoint image without the new
dependency ignores ``DEPENDENCY_FILE``, so a chart that sets it keeps working
as today, without the wait.

Security Impact
---------------

The marker is keyed, so it reveals nothing about a password, weak or not,
without the admin password. The entrypoint reads a file the pod already
mounts and needs no new RBAC.

Performance Impact
------------------

Workloads restart only when their credentials change, instead of on every
upgrade as in the keystone-only fix. A rotation delays the start of each new
pod by the init timeout and one restart of the init container.

Alternatives
------------

**Init container per chart waiting on the Helm release revision.** The
keystone-only fix above. Duplicated per chart, restarts on every upgrade, and
waits for the periodic sync.

**Release revision as the marker, or as the salt of the hash.** Simpler, but
the pod template changes on every upgrade, so every upgrade restarts the
service.

**Unkeyed hash of the password.** Restarts only on a change, but publishes a
hash that a weak password can be recovered from.

**Waiting on the** ``Connection`` **in kubernetes-entrypoint.** Ready, a
revision and ``observedGeneration`` tell that the controller wrote the new
snippet, but not that the pod sees it: the main container starts on the stale
file in about a third of the runs above.

**Stakater Reloader.** Restarts a workload when an annotated secret changes.
It patches objects that Helm rendered, so the next upgrade merges against
fields Helm does not own, it is one more controller to deploy, and it does
not keep a pod from starting on a stale file.

**A Dependency custom resource and a restart controller.** The first draft
of this spec. A new controller only for restarts, and custom resources are
applied after everything else in a release, so they cannot gate the
workloads of the same upgrade.

Implementation
==============

Assignee(s)
-----------

Primary assignee:
  smarkin (Sergiy Markin <smarkin@mirantis.com>)

Open questions
--------------

* The key of the marker: the database admin password, or a dedicated value.
* Whether the exit on timeout should be an option of the file dependency or
  the behaviour of every entrypoint dependency.

Work Items
----------

* ``DEPENDENCY_FILE`` in ``kubernetes-entrypoint``, with unit tests.
* ``files`` dependencies in the ``helm-toolkit`` init container snippet.
* The marker and the file dependency in keystone.
* The other charts that project a ``Connection``.

Testing
=======

The CRD job rotates the database password through ``helm upgrade``: the
upgrade succeeds and keystone issues tokens. A second upgrade with unchanged
values must leave the pod template, and so the API pods, unchanged.

Documentation Impact
====================

How a password is rotated, in the database and messaging documentation.

References
==========

* :doc:`../2026.1/mariadb_crd`
* :doc:`../2026.1/rabbitmq_crd`
* :doc:`../2026.2/keystone_crd`
