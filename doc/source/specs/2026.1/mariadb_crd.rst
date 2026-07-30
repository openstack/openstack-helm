=============================================
Declarative MariaDB Database Management (CRD)
=============================================

Problem Description
===================

Every OpenStack-Helm chart that owns a MariaDB database provisions it with a
``<service>-db-init`` job rendered by the `db-init manifest`_. The job mounts
the **MariaDB administrative connection URI** into a pod running in the
OpenStack namespace, parses it, and issues ``CREATE DATABASE``,
``CREATE USER`` and ``GRANT``.

This approach has a number of drawbacks:

* The MariaDB root credentials are distributed to every chart that owns a
  database. Thirty charts do, which means thirty copies of the same
  administrative secret, each mounted into a pod that only needs to create a
  single database.
* The job is a one-shot Helm hook. It has no reconciliation loop, no
  ``status``, and no way to repair drift. If the database is dropped or the
  user's grants are changed out of band, nothing notices.
* Rotating a service database password requires re-running the job manually,
  because the job only runs on ``post-install`` and ``post-upgrade``.
* The service database password is duplicated: it is declared in the
  ``endpoints.<type>.auth.<userClass>.password`` value and rendered again into
  the ``<service>-etc`` secret as part of the connection URI, so rotating it
  touches both. Nova additionally keeps it in the ``nova-db-cell0-user``
  secret, which its database synchronization job reads to build the cell
  mappings.

Proposed Change
===============

The MariaDB chart gains four custom resource definitions and a minimal
reconciler. Consumer charts render custom resources describing the databases
they need, derived entirely from values they already declare. The reconciler
creates the database, user and grants, and materializes the connection into a
secret which the service consumes as an ``oslo.config`` snippet.

MariaDB chart: custom resource definitions
------------------------------------------

Four namespaced custom resource definitions in the
``mariadb.osh.openstack.org/v1alpha1`` API group, rendered by
``mariadb/templates/crds.yaml`` and gated on ``.Values.manifests.crds``:

* ``Database`` -- a MariaDB schema.
* ``User`` -- a MariaDB user account.
* ``Grant`` -- privileges granted to a user on a database.
* ``Connection`` -- a request to materialize a connection string for a given
  user and database into a Kubernetes secret.

A per-service API subgroup is used deliberately. When the RabbitMQ chart gains
its own custom resources it will need a ``User`` kind too, and a flat
``osh.openstack.org`` group could not hold both.

The resources stay as close to their upstream `mariadb-operator`_
``k8s.mariadb.com/v1alpha1`` counterparts as a partial implementation can.
*Every* field the upstream resources accept is declared, including the ones this
reconciler does not implement, because a custom resource definition that omits a
field does not reject it -- the API server strips it silently. Declaring
everything keeps the door open to retargeting the same chart templates at the
full upstream operator by changing a single ``apiVersion`` argument, and it means
a resource written against upstream documentation applies unchanged.

Some of those fields are accepted and ignored, because ignoring them changes
nothing: ``mariaDbRef.waitForIt``, ``requeueInterval``, ``healthCheck``. The rest
are **rejected**, with a ``Ready`` condition of ``False`` naming the field:
``passwordPlugin``, ``require.ssl``, ``require.issuer``, ``require.subject``,
``maxScaleRef``, ``tlsClientCertSecretRef``, the object reference fields that pin
a referent's identity, and ``optional`` on a secret key reference. Quietly
dropping an authentication plugin or a TLS requirement would leave a deployment
weaker than the resource asked for while reporting success. A field is only
refused when it is set to something the reconciler would fail to honour, so
``optional: false``, which agrees with what it already does, is accepted.
Ownership is settled first, so a resource belonging to the upstream operator --
which legitimately uses those fields -- is left alone.

Two intentional divergences from upstream:

* ``spec.name`` on ``Database`` and ``User`` carries the MariaDB object name,
  independently of ``metadata.name``. This is required, not cosmetic: Nova's
  cell databases are called ``nova_cell0`` and ``nova_cell1``, and an
  underscore is not valid in a Kubernetes object name.
* ``spec.maxUserConnections`` defaults to ``0`` (unlimited) rather than
  upstream's ``10``. A limit of ten connections would throttle every OpenStack
  service.

Each kind exposes a ``status`` subresource, structurally identical to
upstream's: a single ``conditions`` list of ``metav1.Condition``, with the same
types, formats, enumerations, patterns and required fields.

.. code-block:: yaml

    status:
      conditions:
        - type: Ready
          status: "True"          # True | False | Unknown
          reason: Reconciled      # Reconciled | ReconcileError | NotOwned
          message: created database cinder
          lastTransitionTime: "2026-08-03T19:20:00Z"
          observedGeneration: 3

Readiness is therefore the condition of type ``Ready``, which is what ``kubectl
wait --for=condition=Ready`` reads and what the printer columns select on with
``.status.conditions[?(@.type=="Ready")].status``, exactly as upstream does.
``lastTransitionTime`` marks the last change of ``status``, so a resync that only
refreshes the message leaves it alone.

A single string field would be easier for ``kubernetes-entrypoint`` to wait on,
since it compares one nested field against a string value and cannot index into
a list. That is deliberately not what this spec proposes: diverging from
upstream on the one part of the API that every piece of generic tooling reads
would make these resources subtly incompatible with anything written for the
real operator, to work around a limitation in one client.
``kubernetes-entrypoint`` should instead be taught to match a condition by type,
which is a prerequisite for a chart declaring a ``custom_resources`` dependency
on a ``Connection`` becoming ready.

MariaDB chart: the reconciler
-----------------------------

``mariadb/templates/bin/_mariadb_db_controller.py.tpl`` is a single-file
Python reconciler deployed by
``mariadb/templates/deployment-db-controller.yaml`` and gated on
``.Values.manifests.deployment_db_controller``. It is modelled
directly on the `MariaDB controller`_ that the chart already ships for Galera
primary election: the same ``pykube`` client, the same container image, the
same namespaced RBAC role, the same environment-variable configuration
convention.

It is a separate deployment from the existing controller rather than an
extension of it. Primary election has to keep working when the database is
unreachable, which is precisely the condition under which the database
reconciler is retrying; the election controller must not be given
administrative database credentials or a client certificate; and neither should
be restarted when the other changes.

The reconciler polls rather than watches. A full sweep of all four kinds runs
every ``RECONCILE_INTERVAL`` seconds. Watching four kinds from a
single-threaded script requires four concurrent HTTP streams plus
``resourceVersion`` and ``410 Gone`` handling, which is a large share of the
total complexity in exchange for a few seconds of latency on a handful of
objects.

Within a sweep the kinds are reconciled in the order ``Database``, ``User``,
``Grant``, ``Connection``. The order matters: a ``GRANT`` to a user that does
not exist fails. Cross-resource dependencies are handled by this ordering plus
retry, not by reading other resources' status -- the database itself is the
source of truth, and a resource that fails because its dependency is not ready
yet simply succeeds on a later sweep.

All SQL is idempotent: ``CREATE DATABASE IF NOT EXISTS`` followed by
``ALTER DATABASE`` if the character set or collation drifted;
``CREATE USER IF NOT EXISTS`` followed by ``ALTER USER ... IDENTIFIED BY``
when the desired password changed, which is also the password rotation path;
and ``GRANT``, which is inherently idempotent. A per-resource hash of the
desired state suppresses no-op statements, and a periodic forced resync
repairs out-of-band drift.

Grants are additive in this iteration. Removing a privilege from
``spec.privileges`` does not issue a ``REVOKE``; the drift is reported in the
``Ready`` condition's message instead. Automatically revoking privileges from a user
shared by several services is a good way to take down a control plane, so it
is left to a later iteration with an explicit opt-in.

The reconciler authenticates to MariaDB the same way the chart's existing
``mariadb-cluster-wait`` job does: the administrative password comes from the
``mariadb-dbadmin-password`` secret, and ``admin_user.cnf`` is mounted and
passed to ``pymysql`` as ``read_default_file``. When the chart is deployed
with TLS that file already carries the ``ssl-ca``, ``ssl-key`` and
``ssl-cert`` settings, so mutual TLS requires no additional code, and
``REQUIRE X509`` is appended to user creation exactly as the existing db-init
script does.

Deleting a custom resource does not drop data by default.
``spec.cleanupPolicy`` defaults to ``Skip``; only ``Delete`` installs a
finalizer and issues ``DROP DATABASE`` or ``DROP USER``. The secret written by
a ``Connection`` carries an owner reference to the resource, so it is garbage
collected without a finalizer.

Consumer charts declare their own resources
-------------------------------------------

Each chart spells out the resources for the database it owns in its own
``templates/mariadb-db.yaml``, gated by ``manifests.mariadb_db``. There is
deliberately no Helm-toolkit manifest generating them: a chart's databases,
their config sections and their accounts are part of that chart's contract, and
a reader should be able to see exactly what it declares without following an
indirection into shared code. It also keeps each chart free to deviate --
Placement writes a ``[placement_database]`` section, Nova owns three databases
behind one account -- without growing arguments on a shared macro.

What the templates do *not* hardcode is identity. Every name and credential is
read from the values the chart already declares, so nothing is duplicated:

.. code-block::

    {{- $cinderAuth := .Values.endpoints.oslo_db.auth.cinder }}
    {{- $cinderName := .Values.endpoints.oslo_db.path | trimPrefix "/" }}

``endpoints.<type>.path`` is the database name,
``endpoints.<type>.auth.<userClass>`` carries the username and password, and
``endpoints.oslo_db.hosts.default`` names the MariaDB cluster for
``mariaDbRef``. The only new value in a consumer chart is a single ``manifests``
boolean.

Each chart also renders the password secret its ``User`` and ``Connection``
resources reference, and fails rendering if ``manifests.job_db_init`` is still
enabled, since both provisioning paths would write the same account's password.

Nova is the interesting case: its three endpoint trees (``oslo_db``,
``oslo_db_cell0``, ``oslo_db_cell1``) all use the username ``nova``, so its
template declares one password secret and one ``User`` alongside three
``Database``, ``Grant`` and ``Connection`` resources. Declaring three ``User``
resources for the same account would have them fight over the password.

Because ``metadata.name`` may not contain an underscore, the schema name is
carried in ``spec.name``: the resource for ``nova_cell0`` is named
``nova-cell0``.

Connection secret consumption
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A ``Connection`` resource materializes a secret whose key is an
``oslo.config`` snippet:

.. code-block:: ini

    [database]
    connection = mysql+pymysql://cinder:password@mariadb.openstack.svc.cluster.local:3306/cinder?charset=utf8

Charts already support mounting such snippets. ``pod.etcSources.<component>``
is a list of projected volume sources mounted at
``/etc/<service>/<service>.conf.d/``, and ``oslo.config`` reads every
``*.conf`` file in that directory. Setting
``conf.<service>.database.connection`` to ``null`` suppresses the chart's own
generation of the connection string, leaving the projected snippet as the only
source.

No chart template change is needed to consume it: ``pod.etcSources`` is already
a values-driven list, so the per-chart override lists the connection secret
under every workload that reads the database, including the database
synchronization job.

This provides ordering for free. A projected volume source is not optional by
default, so kubelet holds a pod in ``ContainerCreating`` until the connection
secret exists, then starts it. The database synchronization job waits for the
reconciler rather than failing.

The snippet is a convention, not a constraint: ``secretTemplate`` names both the
key to write and the format to render, so a ``Connection`` can equally
materialize a bare URI for a consumer that reads one from an environment
variable. Nova's ``nova_cell0`` is the one database that needs this. Nothing in
``nova.conf`` points at cell0 -- nova reads that connection from the cell mapping
in the api database, which the synchronization job writes with
``nova-manage cell_v2 update_cell --database_connection`` -- so its
``Connection`` writes a bare URI under the key the job's existing
``secretKeyRef`` already expects. Consuming it needs no chart template change
either, for the same reason ``pod.etcSources`` needs none: the secret name comes
from ``secrets.oslo_db_cell0.nova``, which the override repoints.

Two workload groups are deliberately left out: ``nova-compute`` and the neutron
agents do not use the database, so they are not handed its credentials.

Backward compatibility
----------------------

``manifests.mariadb_db`` defaults to ``false`` in every consumer chart and
``manifests.deployment_db_controller`` defaults to ``false`` in the MariaDB
chart. With those defaults the rendered output of every chart is byte for byte
identical to what it is today, and no existing deployment gains a pod, an RBAC
rule or a restart. The custom resource definitions themselves are inert
without any resources to reconcile.

The two provisioning paths are mutually exclusive: the manifest fails
rendering with an explicit message if ``manifests.mariadb_db`` and
``manifests.job_db_init`` are both enabled, because both would write the same
user's password. In the other direction no change is needed --
``helm-toolkit.utils.dependency_jobs_filter`` already drops the db-init job
from the database synchronization job's dependencies when it is disabled.

The ``<service>-db-admin`` secrets continue to be rendered, because the TLS
verification tooling reads them; removing them is a separate follow-up. The
non-admin ``<service>-db-user`` secrets are already gone, dropped from the
charts independently of this change. Nova's cell0 user secret is the one that
outlived them, and its ``Connection`` supersedes it: the override turns
``manifests.secret_db_cell0`` off and the chart stops generating a connection
URI for it. That default, like every other, is unchanged.

Implementation
==============

Assignee(s)
-----------

Primary assignee:
  kozhukalov (Vladimir Kozhukalov <kozhukalov@gmail.com>)

Work Items
----------

* Add the four custom resource definitions, the reconciler, its deployment and
  RBAC, and the supporting values to the MariaDB chart.
* Convert the charts deployed by the compute kit job that own a database:
  Keystone, Cinder, Glance, Heat, Placement, Nova and Neutron. Each gains a
  ``templates/mariadb-db.yaml`` declaring its own resources, a
  ``manifests.mariadb_db`` switch and an override enabling the path.
* Add a check pipeline job deploying the compute kit plus Ceph and Cinder with
  the new provisioning path enabled.

Follow-ups, deliberately out of scope here:

* Declare a ``custom_resources`` dependency on ``Connection`` readiness in the
  database synchronization jobs. Two things are missing first: Helm-toolkit's
  RBAC snippets emit no rules for custom resources, so the init container would
  be refused by the API server, and ``kubernetes-entrypoint`` cannot express
  "the condition of type ``Ready`` is ``True``". Nova's cell0 mapping is where
  this would help most, since it reads its connection from an environment
  variable and so does not get the ordering a projected volume provides.
* Horizon, which reads a bare URI through ``inputType: secret`` rather than an
  ``oslo.config`` snippet. The ``Connection`` side of this already works --
  Nova's cell0 mapping uses it -- but Horizon is not part of the job this change
  adds.
* The remaining charts that own a database.
* Retire the db-init job once every chart is converted.
* Opt-in privilege revocation in the ``Grant`` reconciler.

Alternatives
------------

**Keep hand-written extraObjects and require the upstream operator.** This
needs no new code, but it gives the deployer no access to the chart's
``endpoints`` values, so every database is described by hand-written YAML that
repeats credentials the chart already holds. It is also easy to get wrong:
``extraObjects`` is rendered through ``tpl``, so the Go template placeholders
in the upstream operator's own ``secretTemplate.format`` field are evaluated
and discarded unless every one of them is escaped.

**Make the db-init job idempotent and re-runnable.** Smaller in scope, but it
still distributes root credentials to every namespace and still offers no
reconciliation, no status and no drift repair.

**Depend on the upstream mariadb-operator as a chart dependency.** This pulls
in a large operator with its own custom resource definitions and admission
webhooks to do what a few hundred lines of Python can, and its own Galera
reconciliation would compete with the controller this chart already ships.

Documentation Impact
====================

The installation documentation gains a section describing declarative database
management and how to enable it. The MariaDB and consumer chart value
references are generated from the ``values.yaml`` comments, so the new keys are
documented there.

.. _db-init manifest: https://opendev.org/openstack/openstack-helm/src/branch/master/helm-toolkit/templates/manifests/_job-db-init-mysql.tpl
.. _MariaDB controller: https://opendev.org/openstack/openstack-helm/src/branch/master/mariadb/templates/bin/_mariadb_controller.py.tpl
.. _mariadb-operator: https://github.com/mariadb-operator/mariadb-operator
