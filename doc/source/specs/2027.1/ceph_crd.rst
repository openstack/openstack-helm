=================================================
Declarative Ceph Pool and Client Management (CRD)
=================================================

Problem Description
===================

Every OpenStack-Helm chart that stores data in Ceph creates its pool and its
cephx user with a ``<service>-storage-init`` job. Glance, Cinder, Nova and
Gnocchi render one, and Cinder renders a second one for its backup service.
Each job mounts the **Ceph administrative key** into a pod in the OpenStack
namespace and runs ``ceph osd pool create``, ``ceph auth get-or-create`` and
similar commands, then writes the user's key into a secret for the services.

This has several drawbacks.

* The administrative key has to be in the OpenStack namespace. The
  ``ceph-provisioners`` chart copies it there for the legacy Ceph charts, and
  the ``ceph-adapter-rook`` chart for Rook, by running ``ceph auth ls`` in the
  Rook toolbox pod. Most of the reason ``ceph-adapter-rook`` exists is to make
  that copy.
* The jobs run once, as Helm hooks. They have no status and do not repair
  drift.
* Rook already manages pools and cephx users with its ``CephBlockPool`` and
  ``CephClient`` resources. The jobs bypass them.
* Each chart has its own copy of the scripts, and the copies have drifted
  apart.

Proposed Change
===============

Consumer charts can render Rook's ``CephBlockPool`` and ``CephClient``
resources (``ceph.rook.io/v1``) in their own namespace, instead of running
storage-init jobs. The Rook operator reconciles them and writes each user's
key into a secret next to its ``CephClient``. The services mount that secret,
take the monitor addresses from Rook too, and wait for the resources to be
ready. A chart that renders the resources runs **no storage-init job**, no
part of it needs the administrative key, and it needs nothing from
``ceph-adapter-rook`` or ``ceph-provisioners``.

Rook is the only reconciler, both when Rook deploys the Ceph cluster and when
the legacy Ceph charts manage it.

``ceph-adapter-rook`` is planned for removal. Its two jobs are to copy the
administrative key and to write the ``ceph-etc`` configmap into the OpenStack
namespace, and the converted charts need neither.

The external CephCluster
------------------------

Rook reconciles a ``CephBlockPool`` or a ``CephClient`` only in the namespace
of a ``CephCluster``. The services can mount a secret only from their own
namespace. So the OpenStack namespace gets a ``CephCluster`` of its own, in
**external** mode. It deploys no Ceph daemons. It connects Rook to a Ceph
cluster that runs elsewhere, through two objects in the same namespace:

* the ``rook-ceph-mon`` secret, with the cluster's ``fsid`` and the user Rook
  connects as. That user is ``client.admin``, with the administrative key in
  ``ceph-secret`` and ``admin-secret``, because creating pools and users needs
  it. Rook's documentation calls this running the consumer cluster with admin
  privileges;
* the ``rook-ceph-mon-endpoints`` configmap, which lists the monitors as
  ``a=<ip>:<port>,b=<ip>:<port>``. Rook keeps it up to date when monitors are
  added or removed later. The charts read the monitor addresses from it too,
  as described below.

The cluster is deployed with Rook's ``rook-ceph-cluster`` chart with
``cephClusterSpec.external.enable: true`` and no pools, file systems or object
stores of its own. Only the Rook operator has to run in the Kubernetes cluster
of the OpenStack charts; the Ceph cluster can be anywhere they can reach. Each
OpenStack namespace has its own external ``CephCluster``, and several of them
can point at the same Ceph cluster.

The two cases differ only in where the values of the two objects come from:

* **Rook deploys the Ceph cluster.** The namespace of Rook's internal
  ``CephCluster`` already has a ``rook-ceph-mon`` secret and a
  ``rook-ceph-mon-endpoints`` configmap, and their values are copied.
* **The legacy Ceph charts manage the cluster.** Only the Rook operator is
  deployed, with no internal ``CephCluster``. The ``fsid`` comes from
  ``ceph fsid``, the key from the ``ceph-client-admin-keyring`` secret of the
  ``ceph-mon`` chart, and the monitors from ``ceph mon dump``. Rook ``v1.20``
  needs Ceph ``19.2`` or newer, and the legacy charts run ``20.2``. A pool must
  be declared either by the ``ceph-client`` chart's ``rbd-pool`` job or by a
  ``CephBlockPool``, not by both.

The deployment creates the external ``CephCluster`` before the consumer charts,
as it deploys Ceph itself, because it belongs to the namespace, not to one
chart. In the gate a ``deploy-ceph`` role task does it.

Consumer charts declare their own resources
-------------------------------------------

Each chart declares its resources in its own ``templates/ceph-resources.yaml``,
gated by ``manifests.ceph_resources``, as in the MariaDB and Keystone specs.
They are derived from values the chart already has. They are the same pools
and users with the same caps that the storage-init jobs create today, except
that Nova gets a user of its own instead of using Cinder's.

The caps of a cephx user say what it may do on each kind of Ceph daemon. The
``mon`` caps cover the monitors, and every user gets ``profile rbd``: the
minimum an RBD client needs, which is to read the cluster maps and to
blocklist a dead client so that its image lock can be taken over. The ``osd``
caps cover the data. ``profile rbd`` gives read and write access to RBD images
in all pools, and ``profile rbd pool=<pool>`` limits that access to one pool.

.. list-table::
   :header-rows: 1
   :widths: 12 22 20 18 28

   * - Chart
     - ``CephBlockPool`` (default)
     - ``CephClient`` (default)
     - ``osd`` caps
     - Why
   * - Glance
     - ``rbd_store_pool`` (``glance.images``)
     - ``rbd_store_user`` (``glance``)
     - ``profile rbd pool=<pool>``
     - Glance needs only its own image pool.
   * - Cinder
     - ``rbd_pool`` of the internal RBD backend (``cinder.volumes``)
     - ``rbd_user`` of that backend (``cinder``)
     - ``profile rbd``
     - libvirt attaches volumes with this user, because Nova takes the user
       from Cinder's connection info. Cinder clones volumes from Glance
       images. Instances that Nova created with this user keep using it for
       their disks.
   * - Cinder (backup)
     - ``backup_ceph_pool`` (``cinder.backups``)
     - ``backup_ceph_user`` (``cinderbackup``)
     - ``profile rbd pool=<pool>``
     - The backup user only writes backups. It reads the source volume as
       the ``cinder`` user, whose key cinder-backup also mounts.
   * - Nova
     - ``images_rbd_pool`` (``vms``)
     - ``rbd_user`` of ``[libvirt]`` (``nova`` in ``ceph-crd.yaml``)
     - ``profile rbd pool=<pool>, profile rbd pool=<Glance pool>``
     - Nova writes its own pool. It clones Glance images copy-on-write, and
       writes snapshots straight into Glance's pool.

A resource is rendered only when the chart uses Ceph for it, under the same
conditions as today's storage-init jobs.

For example, Cinder renders:

.. code-block:: yaml

    apiVersion: ceph.rook.io/v1
    kind: CephBlockPool
    metadata:
      name: cinder.volumes
      annotations:
        helm.sh/resource-policy: keep
    spec:
      failureDomain: host
      replicated:
        size: 3
      application: rbd
    ---
    apiVersion: ceph.rook.io/v1
    kind: CephClient
    metadata:
      name: cinder
    spec:
      name: cinder
      caps:
        mon: profile rbd
        osd: profile rbd

Some details:

* The pool name is ``metadata.name``, because Rook allows ``spec.name`` only
  for its built-in pools. A pool name that is not a valid Kubernetes name fails
  rendering with a message.
* The application is ``rbd``, not the charts' custom names such as
  ``glance-image``, because Rook runs ``rbd pool init`` only for ``rbd``.
* Rook has no field for a crush rule name, so the ``crush_rule`` values are not
  used. The templates set ``failureDomain: host``, which on the default root
  places data like ``replicated_rule``.
* Rook deletes a pool when its ``CephBlockPool`` is deleted, unless the pool
  still holds images. Pools therefore carry ``helm.sh/resource-policy: keep``.
  Deleting a ``CephClient`` removes the user, which is what an uninstall
  should do.
* Rook adopts pools and users that the storage-init jobs created. It keeps an
  existing user's key and an existing pool's crush rule, and only sets the
  caps, the size and the application.

Nova's own user
---------------

Today Nova uses the ``cinder`` user for its ephemeral disks: the chart sets
``[libvirt] rbd_user`` to ``cinder``. With the switch on, Nova declares a
``CephClient`` for the user in ``[libvirt] rbd_user`` instead, and
``ceph-crd.yaml`` sets that to ``nova``, with a new ``rbd_secret_uuid``.
Rendering fails if ``rbd_user`` is still Cinder's user, because Cinder already
declares that ``CephClient``. The user is declared only when Nova keeps its
disks in Ceph, that is with ``images_type: rbd``.

The caps of this user name Glance's pool, which the Nova chart does not know.
It comes from a new Nova value, ``conf.ceph.glance_pool``, whose default is
Glance's default, ``glance.images``.

Two keys are needed on a compute node, because Nova uses two users:

* For a **volume**, Nova takes the user and the libvirt secret from Cinder's
  connection info, which name the ``cinder`` user. A separate Nova user does
  not change that.
* For an **ephemeral disk**, Nova uses ``[libvirt] rbd_user`` and
  ``rbd_secret_uuid``, which now name the ``nova`` user.

nova-compute writes the keyring of its own user from
``rook-ceph-client-<rbd_user>``. libvirt stores both keys as libvirt secrets,
which is what QEMU reads: Cinder's key from ``rook-ceph-client-<cinder user>``
under ``conf.ceph.cinder.secret_uuid``, as today, and Nova's key from
``rook-ceph-client-<nova user>`` under the UUID that Nova's ``rbd_secret_uuid``
names. For that, the libvirt chart gets the same ``manifests.ceph_resources``
switch and new ``conf.ceph.nova.user`` and ``conf.ceph.nova.secret_uuid``
values. libvirt renders no resources of its own. Neither nova-compute nor
libvirt reads the administrative key any more.

Instances created before the switch keep using the ``cinder`` user for their
disks, because their domain XML names it, until they are hard rebooted or
cold migrated. They keep working: the ``cinder`` user keeps its caps on all
pools, and libvirt keeps its key.

No storage-init job
-------------------

With the switch on, the chart renders no storage-init job. Two things that the
job provided are done differently.

**The key.** Rook writes ``rook-ceph-client-<user>`` with the key ``userKey``.
The secret volume of glance-api, cinder-volume, cinder-backup, nova-compute and
libvirt names that secret and maps ``userKey`` to the file name ``key`` with
``items``, so the mounts and init containers do not change. A pod gets a
rotated key when it restarts.

**The monitor addresses.** Every Ceph client needs a ``ceph.conf`` that names
the monitors in ``mon_host``. Today the charts mount the ``ceph-etc`` configmap
for it, which ``ceph-adapter-rook`` or ``ceph-provisioners`` writes into the
OpenStack namespace. ``ceph-adapter-rook`` writes it once, with a job that
copies the monitor addresses from Rook's configmap in the Ceph namespace, and
puts no other client setting in it.

With the switch on, the workloads mount ``rook-ceph-mon-endpoints`` from their
own namespace instead. The init container that already writes into
``/etc/ceph``, the keyring in glance-api, cinder-volume and cinder-backup and
the copy of ``ceph.conf`` in nova-compute and libvirt, writes ``ceph.conf``
from it, with the monitor names dropped:

.. code-block:: ini

    [global]
    mon_host = 10.0.0.11:6789,10.0.0.12:6789,10.0.0.13:6789

The ``ceph-etc`` mount is not rendered. A pod reads the monitor list when it
starts. A running client learns about monitor changes from the monitors
themselves, so the list only has to be current enough for a pod to connect.
Any other client setting belongs in the cluster's configuration database
(``ceph config set client ...``), which every client reads from the monitors
when it connects.

**The ordering.** Disabling the job removes it from the workloads'
dependencies, because ``helm-toolkit.utils.dependency_jobs_filter`` drops a
disabled job. Each workload instead waits for its resources with an explicit
``custom_resources`` dependency, declared in the chart's ``ceph-crd.yaml``
override in the same way as for the Keystone identity resources. Rook reports
readiness in ``status.phase``, so the dependency matches that field:

.. code-block:: yaml

    dependencies:
      static:
        api:
          custom_resources:
            - apiVersion: ceph.rook.io/v1
              kind: CephBlockPool
              name: glance.images
              fields:
                - key: status.phase
                  value: Ready
            - apiVersion: ceph.rook.io/v1
              kind: CephClient
              name: glance
              fields:
                - key: status.phase
                  value: Ready

The RBAC for the dependency is derived from it, as for the other custom
resources.

Security
--------

Anyone who can create a ``CephClient`` in an OpenStack namespace can get a key
with any caps, so write access to ``cephclients.ceph.rook.io`` there must be
treated like the administrative key itself. The key is stored in the
``rook-ceph-mon`` secret in the OpenStack namespace, which Rook's documentation
calls not generally recommended. Neither is worse than today, where
``pvc-ceph-client-key`` holds the key in that namespace and every storage-init
job mounts it. Now only the Rook operator reads it.

Backward compatibility
----------------------

``manifests.ceph_resources`` chooses the path per chart:

* ``false``, the default: the chart renders the storage-init jobs as today,
  byte for byte, and no custom resources.
* ``true``: the chart renders the resources and no storage-init job, and its
  workloads take the monitor addresses from ``rook-ceph-mon-endpoints``
  instead of ``ceph-etc``. The namespace needs the Rook operator and an
  external ``CephCluster``.

Rendering fails if the switch is on while ``manifests.job_storage_init``, or
``manifests.job_backup_storage_init`` for Cinder's Ceph backup driver, is still
enabled. The ``ceph-crd.yaml`` overrides disable them.

Because Rook adopts existing pools and users, turning the switch on in a
running deployment keeps the keys the services use. The old key secrets, such
as ``images-rbd-keyring``, can then be deleted. Nova's ``rbd_user`` keeps its
default, ``cinder``; only ``ceph-crd.yaml`` changes it, and existing instances
keep working as described above.

Implementation
==============

Assignee(s)
-----------

Primary assignee:
  kozhukalov (Vladimir Kozhukalov <kozhukalov@gmail.com>)

Work Items
----------

* Convert Glance, Cinder and Nova: ``templates/ceph-resources.yaml``, the
  ``manifests.ceph_resources`` switch and a ``ceph-crd.yaml`` override that
  enables it, disables the storage-init jobs and declares the dependencies.
  Nova's override also gives it a user of its own. With the switch on, the
  workloads write ``ceph.conf`` from ``rook-ceph-mon-endpoints``.
* In the libvirt chart, the same switch and the ``conf.ceph.nova`` values,
  so that it stores Cinder's and Nova's keys from their secrets and writes
  ``ceph.conf`` from ``rook-ceph-mon-endpoints``.
* Add a ``deploy-ceph`` role task that creates the external ``CephCluster``
  for a Rook-deployed cluster.
* Use it in the gate's ``crd`` job, with Glance on the ``rbd`` store, and
  verify that every resource is ready, every key secret exists and no
  storage-init job runs. ``ceph-adapter-rook`` is still deployed there for
  the charts that are not converted. No gate job deploys the legacy Ceph
  charts, but for Rook the two cases differ only in the values of the secret
  and the configmap.
* Document both cases in the installation guide.

Follow-ups:

* Gnocchi, and Glance's ``radosgw`` store (Rook's ``CephObjectStoreUser``).
* Narrow the caps of the ``cinder`` user to the pools Cinder needs, once no
  instance uses it for its disks any more.
* Remove ``ceph-adapter-rook`` once every chart that uses Ceph is converted.
* A reusable step, such as a small chart, that creates the external
  ``CephCluster`` for either case, and a gate job with the legacy charts.
* Retire the storage-init jobs once every chart is converted.

Alternatives
------------

**A reconciler of our own**, with the same two kinds in an OpenStack-Helm API
group, as the MariaDB charts do. It could keep the administrative key out of
the OpenStack namespace, but it would reimplement what Rook already does. It
can still be added later; the charts would change only the ``apiVersion``.

**Resources in the Ceph cluster namespace, with the keys copied.** This needs
no external ``CephCluster``, but every chart keeps a job to copy the key, a
rotated key stays stale until the next upgrade, and it does not work for the
legacy charts, which have no ``CephCluster`` namespace.

**Rook's cluster in the OpenStack namespace.** This puts the Ceph daemons next
to the services, lets only one OpenStack namespace use the cluster, and does
not help the legacy charts.

Documentation Impact
====================

The installation guide gains a section on deploying the Rook operator, creating
the external ``CephCluster`` for each case, and enabling the resources in the
charts.
