==============================================
Declarative RabbitMQ Topology Management (CRD)
==============================================

Problem Description
===================

Twenty-two OpenStack-Helm charts provision their messaging account with a
``<service>-rabbit-init`` job rendered by the `rabbit-init manifest`_. The job
mounts the **RabbitMQ administrative connection URI** into a pod in the
OpenStack namespace, pulls the host, port, user and password out of it with
``awk``, and calls ``rabbitmqadmin`` to declare a user, a vhost and a
permission, delete the ``guest`` account, and import whatever
``conf.rabbitmq`` carries.

Drawbacks:

* Twenty-two copies of the administrative secret, each mounted into a pod that
  declares one account.
* The job is a one-shot Helm hook: no reconciliation loop, no ``status``, no
  drift repair. A vhost removed or a permission narrowed out of band goes
  unnoticed, and rotating a password means re-running the job by hand.
* One piece of drift is guaranteed. The chart writes ``guest`` into
  ``definitions.json``, which ``management.load_definitions`` imports on every
  node boot, and sets ``loopback_users.guest`` to ``false`` so that account can
  log in from anywhere. Each rabbit-init job deletes it; a node restart brings
  it back until the next ``helm upgrade``.
* Credentials are recovered by text processing: the password is percent-decoded
  with ``sed 's/%/\\x/g'`` piped into ``xargs -0 printf "%b"``, a hand-rolled
  URL decoder in shell.
* Anything beyond one user, vhost and permission -- a policy, queue, exchange
  or binding -- goes through ``conf.rabbitmq``, handed to ``rabbitmqadmin`` as
  one opaque definitions document. Entries are not addressable, have no status,
  and the import applies or fails whole.

Proposed Change
===============

The RabbitMQ chart gains seven custom resource definitions and a minimal
reconciler. Consumer charts render resources describing the topology they need,
derived from values they already declare, and the reconciler declares them
against the RabbitMQ HTTP management API.

The resources are compatible with the upstream `messaging-topology-operator`_,
which is the point: a deployer chooses between that operator and this chart's
reconciler, and the deployment is otherwise the same. The only difference is the
API group, ``rabbitmq.osh.openstack.org/v1alpha1`` instead of
``rabbitmq.com/v1beta1``.

RabbitMQ chart: custom resource definitions
-------------------------------------------

Seven namespaced definitions in the ``rabbitmq.osh.openstack.org/v1alpha1``
group, rendered by ``rabbitmq/templates/crds.yaml`` and gated on
``.Values.manifests.crds``: ``Vhost``, ``User``, ``Permission`` (a user's
configure, write and read patterns on a vhost), ``Queue``, ``Exchange``,
``Binding`` and ``Policy``. A per-service subgroup is deliberate, matching the
`MariaDB spec`_: both groups need a ``User`` kind, and a flat
``osh.openstack.org`` could not hold both.

``spec.rabbitmqClusterReference`` and coexistence
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Every kind carries a ``rabbitmqClusterReference``, and the promise of "either
implementation" stands on it. Upstream needs it to *find a broker*: its operator
is one cluster-wide deployment serving many, so it resolves the reference into
an address and credentials, from either a ``name`` naming a ``RabbitmqCluster``
or a ``connectionSecret`` carrying ``username``, ``password`` and ``uri``.

This reconciler resolves nothing. It is deployed *by* the chart that deploys the
broker, one per release, and takes host, port and credentials from its own
environment -- the endpoint lookups and the ``<release>-admin-user`` secret. So
the field answers one question instead: *is this resource mine?* Three spellings
answer no -- a ``name`` that is not this cluster, a ``connectionSecret``, or a
``namespace`` other than its own -- and the reconciler then does **nothing at
all** with the resource: it neither declares it nor reports it as failing.

Leaving ``status`` alone is the part that matters. Status belongs to whichever
controller serves the resource; stamping a condition on every declined one would
put two controllers on one object, overwriting each other every sweep, with
``kubectl wait`` returning whichever landed last. The cost is that a resource
nobody serves has only an absence to show, so the reconciler logs what it
skipped and why, once per resource rather than per sweep. One exception to not
touching it: a resource served here and then repointed elsewhere still carries
this reconciler's finalizer, which is removed -- taking off its own mark is
cleanup, not a claim, and leaving it would make the resource undeletable.

Consequently nothing outside upstream's vocabulary is written. Upstream defines
two condition reasons, ``SuccessfulCreateOrUpdate`` and
``FailedCreateOrUpdate``; this group adds none, and a declined resource is
recognisable by having no condition at all.

Retargeting the consumer templates at the upstream operator therefore takes one
step more than changing the ``apiVersion``: they name the broker with
``rabbitmqClusterReference.name``, which upstream resolves to a
``RabbitmqCluster`` this chart does not create, so that deployment must use a
``connectionSecret``. That is a real cost, not a formality -- the secret holds
administrative credentials and must live in the consumer's namespace for the
operator to read, which is the distribution this change otherwise removes.

Upstream requires exactly one of ``name`` and ``connectionSecret``, enforced by
an admission webhook. The definitions here get the same effect from an
``x-kubernetes-validations`` expression evaluated by the API server, so this
chart needs no webhook. ``has()`` tests presence rather than emptiness, so
``minLength: 1`` on ``name`` covers what upstream's comparison against the empty
string does.

Status, readiness and the two missing webhooks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Each kind exposes a ``status`` subresource structurally identical to upstream's:
``observedGeneration`` at the root plus a ``conditions`` list of
``metav1.Condition``. Readiness is the condition of type ``Ready``, which is what
``kubectl wait --for=condition=Ready`` reads and what the printer columns select
on with ``.status.conditions[?(@.type=="Ready")].status``, exactly as upstream
does. ``lastTransitionTime`` marks the last change of ``status``, so a resync
that only refreshes the message leaves it alone.

That shape costs nothing on the consuming side, because ``kubernetes-entrypoint``
matches a condition by type: a ``custom_resources`` dependency takes a
``conditions`` list alongside ``fields``, selected the way ``kubectl wait
--for=condition=<type>`` selects, with ``status`` defaulting to ``True``. An
unreconciled resource carries no conditions, which counts as unresolved rather
than failed, so an init container keeps waiting -- what a dependency on a freshly
created resource needs.

``spec.deletionPolicy`` keeps upstream's ``delete`` default, so a resource copied
from upstream documentation behaves identically, but the consumer templates set
``retain`` explicitly. Deleting a ``Vhost`` deletes every message in it, and
``helm uninstall`` of a service chart should not. Putting the safe value in the
templates rather than the schema keeps compatibility and safety together.

Immutability is the one genuinely missing webhook. Upstream enforces it on
``Queue.spec.name``, ``spec.vhost``, ``spec.type``, ``spec.durable`` and
``spec.autoDelete``. Here an edit is accepted, the reconciler re-declares, and
RabbitMQ refuses an incompatible redeclaration with a ``406`` that surfaces as
``Ready`` ``False`` carrying the broker's message -- a later error, not a missing
one.

``User`` and its credentials
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``User.spec`` carries no password, which is upstream's design. Either
``spec.importCredentialsSecret`` names a secret with ``username`` and
``password`` keys -- the path the consumer charts take, since a chart already
knows the password from
``endpoints.oslo_messaging.auth.<userClass>.password`` -- or, without it, the
reconciler generates one, writes it to ``<resource>-user-credentials`` and
reports it in ``status.credentials`` and ``status.username``. The second path is
what a bare upstream ``User`` does; leaving it unimplemented would make the
commonest upstream example a no-op. The generated secret is written only when
absent, so the password is not rotated every sweep, and it carries an owner
reference so it is collected with the ``User``.

RabbitMQ chart: the reconciler
------------------------------

``rabbitmq/templates/bin/_rabbitmq_topology_controller.py.tpl`` is a single-file
Python reconciler deployed by
``rabbitmq/templates/deployment-topology-controller.yaml``, gated on
``.Values.manifests.deployment_topology_controller``. It is modelled on the
`MariaDB controller`_: the same namespaced RBAC role, the same
environment-variable convention, the same poll-and-reconcile shape.

It reaches both systems with a plain HTTP client rather than inventing one.
Kubernetes objects use the official ``kubernetes`` client; RabbitMQ uses
``requests``, which that client depends on anyway, so the broker half adds
nothing to the image. Both need to be on the ``openstack-client`` image this
chart already pulls as ``images.tags.rabbitmq_init`` for the
``rabbitmq-password`` init container.

Neither RabbitMQ CLI is used. ``rabbitmqadmin`` is the closest alternative and is
weighed below. ``rabbitmqctl`` is excluded more firmly: it speaks the Erlang
distribution protocol, so it needs the cluster's Erlang cookie --
membership-level credentials, where the management API needs an HTTP user -- it
must match the broker's OTP version, it addresses a named node rather than the
service, and it cannot declare queues, exchanges or bindings at all, so it could
implement four of the seven kinds.

Every kind maps to one idempotent request:

==============  ======================================================
Kind            Request
==============  ======================================================
``Vhost``       ``PUT /api/vhosts/{vhost}``
``User``        ``PUT /api/users/{user}``
``Permission``  ``PUT /api/permissions/{vhost}/{user}``
``Queue``       ``PUT /api/queues/{vhost}/{name}``
``Exchange``    ``PUT /api/exchanges/{vhost}/{name}``
``Policy``      ``PUT /api/policies/{vhost}/{name}``
``Binding``     ``POST /api/bindings/{vhost}/e/{source}/{q|e}/{dest}``
==============  ======================================================

Deletion, where ``deletionPolicy`` is ``delete``, is the matching ``DELETE`` with
a ``404`` treated as success; only ``delete`` installs a finalizer, and
``retain`` leaves the broker object alone. ``Binding`` is the one kind whose
creation is not a ``PUT``: the API gives a binding no addressable name, so the
reconciler lists the bindings between source and destination and posts only when
none matches the routing key and arguments, and deleting one needs the broker's
``properties_key`` from the same listing. ``Queue.spec.type`` is sent as the
``x-queue-type`` argument rather than a body field, because ``PUT /api/queues``
has no ``type`` of its own -- which is how ``rabbitmqadmin`` and the upstream
operator's client express it too.

The reconciler polls rather than watches: a full sweep of all seven kinds every
``RECONCILE_INTERVAL`` seconds. Watching seven kinds from a single-threaded
script needs seven concurrent streams plus ``resourceVersion`` and ``410 Gone``
handling, a large share of the complexity for a few seconds of latency on a
handful of objects. Within a sweep the order is ``Vhost``, ``User``,
``Permission``, ``Exchange``, ``Queue``, ``Binding``, ``Policy``, because a
permission on a missing vhost fails and so does a binding to an undeclared
queue. Cross-resource dependencies are handled by that ordering plus retry
rather than by reading other resources' status: the broker is the source of
truth, and a resource that fails because its dependency is not ready succeeds on
a later sweep.

A per-resource hash of the desired state suppresses no-op requests, and a
periodic forced resync repairs out-of-band drift. That resync is what fixes the
recreated ``guest`` account: ``RABBITMQ_TOPOLOGY_CONTROLLER_DELETE_GUEST_USER``
deletes the default account every sweep, so an imported ``definitions.json``
bringing it back after a node restart is corrected in seconds rather than
surviving to the next ``helm upgrade``.

The reconciler authenticates with the administrative account from the chart's own
``<release>-admin-user`` secret. With TLS it talks HTTPS to the management port
and verifies the broker against the CA in the server certificate secret it
already mounts; the management listener demands no client certificate, so mutual
TLS needs no extra wiring.

Consumer charts declare their own resources
-------------------------------------------

Each chart spells out its messaging account in its own
``templates/rabbitmq-topology.yaml``, gated by ``manifests.rabbitmq_topology``.
There is deliberately no Helm-toolkit manifest generating them, for the reason
the MariaDB spec gives: a chart's messaging topology is part of its contract, and
a reader should see what it declares without an indirection into shared code.

What the templates do *not* hardcode is identity.
``endpoints.oslo_messaging.auth.<userClass>`` carries the username and password,
``path`` is the vhost, and ``hosts.default`` names the cluster for
``rabbitmqClusterReference``, so the only new value in a consumer chart is one
``manifests`` boolean. A chart renders four objects -- a secret holding the
account's username and password, a ``User`` importing it, a ``Vhost``, and a
``Permission`` granting ``.*`` on all three patterns, exactly what rabbit-init
declares today -- and fails rendering if ``manifests.job_rabbit_init`` is still
enabled, since both paths would write the same password.

Plus one ``Policy`` per entry in ``conf.rabbitmq.policies``, which is not
optional: every chart being converted ships an ``ha_ttl_<service>`` policy
setting a 70 second ``message-ttl`` on everything but the ``amq.`` and
``reply_`` queues, which rabbit-init imports with its definitions document.
Turning the job off without translating them would quietly drop message expiry
from every notification queue -- a regression that surfaces under load months
later. The name is a leftover: these policies also carried ``ha-mode`` and
``ha-sync-mode`` until RabbitMQ 4.x removed classic queue mirroring, and only
the TTL half survives. The values are unchanged, so the same policies keep being
applied, declared one resource at a time so a failing entry is attributable
instead of one line in a document that applies or fails whole. ``policies`` is
the only ``conf.rabbitmq`` key translated, because it is the only one any chart
here uses; rendering **fails** on any other rather than discarding it, naming
the ``Queue``, ``Exchange`` and ``Binding`` kinds to declare instead.

No Connection kind, and how the endpoint is found
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Unlike the MariaDB case there is no ``Connection`` kind, and that is a
compatibility decision rather than an omission: upstream has none either. Nothing
in ``rabbitmq.com/v1beta1`` carries a broker address, and the credentials secret
its ``User`` controller writes holds ``username`` and ``password`` -- or
``passwordHash`` when imported -- and deliberately nothing else. Upstream
deployments discover the endpoint out of band, from the service and the
``<cluster>-default-user`` secret the RabbitMQ *cluster* operator generates. An
OpenStack-Helm chart needs none of that: ``endpoints.oslo_messaging`` carries
host, port, scheme, vhost and credentials, and the chart renders them into
``transport_url`` today. These resources provision the broker; the chart stays
the source of truth for reaching it, and adding a ``Connection`` kind would be
the divergence.

That is also why the consumer templates use ``importCredentialsSecret`` rather
than a generated password: the two halves must agree and only the chart can make
them, since a generated password would live in a secret carrying no endpoint
while ``transport_url`` is rendered from values, leaving the service to reach the
right broker with the wrong credentials.

Enabling this path removes a job and adds nothing to any pod, so no
projected-volume ordering trick is available -- and none is needed.
``oslo.messaging`` retries indefinitely, so a service starting before its account
exists logs for a few seconds and proceeds; unlike ``db-sync``, no service does
one-shot work against RabbitMQ that fails if the broker is not ready, so the
job's value as a barrier was incidental. A ``custom_resources`` dependency on
``Permission`` readiness would restore an explicit one, which
``kubernetes-entrypoint`` can express; the missing piece is RBAC to read a custom
resource, so it is a follow-up.

Backward compatibility
----------------------

``manifests.rabbitmq_topology`` defaults to ``false`` in every consumer chart and
``manifests.deployment_topology_controller`` to ``false`` in the RabbitMQ chart.
With those defaults every chart renders byte for byte as it does today, and no
deployment gains a pod, an RBAC rule or a restart; the definitions are inert
without resources to reconcile. The bin configmap is the one place needing care:
its hash annotates the server statefulset's pod template, so an unconditional new
key would roll every existing cluster on upgrade. The reconciler's key is gated
on the same switch, so leaving it off keeps the configmap byte-identical.

The two paths are mutually exclusive -- rendering fails if
``manifests.rabbitmq_topology`` and ``manifests.job_rabbit_init`` are both
enabled, since both write the same password. In the other direction nothing is
needed: ``helm-toolkit.utils.dependency_jobs_filter`` already drops the
rabbit-init job from other jobs' dependencies when disabled. The
``<service>-rabbitmq-admin`` secrets keep being rendered, since turning them off
is a deployer's values change; once every chart is converted they can go, with
the ``<service>-rabbitmq`` user secret whose only reader is rabbit-init.

Implementation
==============

Assignee(s)
-----------

Primary assignee:
  kozhukalov (Vladimir Kozhukalov <kozhukalov@gmail.com>)

Work Items
----------

* Install the official ``kubernetes`` client on the ``openstack-client`` image
  in ``openstack-helm-images``, which already carries ``requests``.
* Add the seven definitions, the reconciler, its deployment and RBAC, and the
  supporting values to the RabbitMQ chart.
* Convert all charts that use messaging. Each gains a
  ``templates/rabbitmq-topology.yaml``, a ``manifests.rabbitmq_topology``
  switch and an override enabling the path.
* Add a check pipeline job deploying the compute kit over the new path.

Follow-ups, deliberately out of scope:

* Declare a ``custom_resources`` dependency on ``Permission`` readiness. Missing
  first: ``helm-toolkit.snippets.kubernetes_pod_rbac_roles`` emits rules only for
  the core, ``extensions``, ``batch``, ``apps`` and ``discovery.k8s.io`` groups,
  so an init container asking for a ``Permission`` would be refused. Teaching it
  to emit a rule for the group and resource a ``custom_resources`` dependency
  names is shared with the MariaDB spec.
* The remaining kinds upstream defines: ``TopicPermission``,
  ``OperatorPolicy``, ``Federation``, ``Shovel``, ``SuperStream`` and
  ``SchemaReplication``. Nothing here uses them.
* Retire the rabbit-init job, its manifest and script once every chart is
  converted, and the per-chart administrative secrets with them.
* Replace the chart's own ``definitions.json`` -- its users, vhosts, permissions
  and ``aux_conf`` entries -- with resources of these kinds, removing the
  boot-time import that recreates ``guest``.

Alternatives
------------

**Keep hand-written extraObjects and require the upstream operator.** No new
code, but no access to the chart's ``endpoints`` values either, so every account
is hand-written YAML repeating credentials the chart already holds. It also
removes the choice this spec preserves: a deployment that does not want a second
operator has nowhere to go.

**Make the rabbit-init job idempotent and re-runnable.** It already is, more or
less, which is the point: re-running it is not the problem. It still distributes
administrative credentials to twenty-two namespaced pods, still offers no status,
and still cannot notice a node restart bringing ``guest`` back.

**Drive the broker with rabbitmqadmin instead of requests.** The RabbitMQ project
ships ``rabbitmqadmin`` for this job, it covers all seven kinds, and it is the
more discoverable choice -- an operator debugging by hand reaches for the CLI,
and ``--idempotently`` and property-addressed ``bindings delete`` would remove
some bookkeeping. Rejected on three counts. It *is* an HTTP client for the
management API, so using it wraps the interface the reconciler already speaks in
a subprocess, a fork per resource per sweep, reaching nothing the API cannot. It
loses error fidelity: the handlers branch on status codes, tolerating a ``404``
on a delete and surfacing a ``406`` verbatim because that is how the broker
refuses an incompatible redeclaration, and through a CLI both become an exit code
and a line of text to pattern-match. And it would have to be added to the image
as a pinned, checksummed per-architecture binary, where ``requests`` costs
nothing because the ``kubernetes`` client already depends on it -- plus a
version to track, since v2 renamed every command and TLS flag relative to the
python v1 tool, which rabbit-init must already cope with. None of this makes
the CLI wrong for people; it makes it wrong for a control loop, which needs a
stable contract with machine-readable errors.

Documentation Impact
====================

The installation documentation gains a section on declarative messaging topology
management, how to enable it, and how to point the same consumer templates at the
upstream operator. Chart value references are generated from ``values.yaml``
comments, so the new keys are documented there.

.. _rabbit-init manifest: https://opendev.org/openstack/openstack-helm/src/branch/master/helm-toolkit/templates/manifests/_job-rabbit-init.yaml.tpl
.. _MariaDB controller: https://opendev.org/openstack/openstack-helm/src/branch/master/mariadb/templates/bin/_mariadb_controller.py.tpl
.. _messaging-topology-operator: https://github.com/rabbitmq/messaging-topology-operator
.. _MariaDB spec: https://opendev.org/openstack/openstack-helm/src/branch/master/doc/source/specs/2026.1/mariadb_crd.rst
