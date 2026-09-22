==============================================
Declarative Keystone Identity Management (CRD)
==============================================

Problem Description
===================

Every OpenStack-Helm chart that owns a service catalog entry creates it with
three one-shot jobs from Helm-toolkit: ``<service>-ks-service`` from the
`ks-service manifest`_, ``<service>-ks-user`` from the `ks-user manifest`_ and
``<service>-ks-endpoints`` from the `ks-endpoints manifest`_. Thirty-four
charts render a ks-user job, twenty-seven a ks-service job and twenty-seven a
ks-endpoints job. Each of those eighty-eight jobs runs a pod in the OpenStack
namespace that takes the **Keystone administrative credentials** from a secret
as environment variables and runs ``openstack`` CLI commands with them.

This has several drawbacks.

* The administrative credentials are copied into every chart that owns a
  catalog entry. Thirty-four charts render their own
  ``<service>-keystone-admin`` secret, and each secret is read by up to three
  of these pods.
* The jobs run once. Most are Helm hooks that run on install and on every
  upgrade. They have no reconciliation loop, no ``status`` and no way to repair
  drift. If a user is deleted, a role assignment removed or an endpoint changed
  outside the chart, nothing notices until the next ``helm upgrade``.
* Provisioning is written as shell scripts around the CLI. ``ks-endpoints.sh``
  finds a service by searching the output of ``openstack service list -f csv``
  for a line that ends in ``,<name>,<type>``, and finds its endpoint with a
  regular expression over ``openstack endpoint list``. A service name or type
  that contains a comma, or a regular expression character such as a dot,
  changes what the pattern matches. The endpoint pattern also requires the
  literal field ``,True,``, so a disabled endpoint is not found and a second
  one is created.
* ``ks-service.sh`` stops as soon as a service with that name and type exists,
  so a changed description or ``enabled`` flag is never applied.
* ``ks-endpoints.sh`` **deletes and recreates** an endpoint when its URL
  changes. This throws away the endpoint ID, although the Identity API can
  update a URL in place. It also deletes every duplicate it finds and then
  creates a new endpoint, so all of the old IDs are lost.
* Each ks-endpoints job runs three containers per service type, one per
  interface, and every container pays the full client startup cost.
* Keystone invalidates every token a user holds whenever the password is
  written, even when the new value is the same. ``ks-user.sh`` therefore first
  tries to authenticate with the new password, looks for ``HTTP 401`` in the
  error output, and writes the password only if that attempt failed. Every
  failed attempt counts against ``[security_compliance]
  lockout_failure_attempts``, and the job makes the attempt on every ``helm
  upgrade``, whether the password changed or not.

Proposed Change
===============

The Keystone chart gains eight custom resource definitions and the **identity
controller**, a small program that reconciles them. A consumer chart renders
custom resources that describe the identity objects it needs, using values it
already declares. The identity controller creates those objects in Keystone.
The administrative credentials stay in the chart that owns Keystone.

The MariaDB and RabbitMQ charts already offer this pattern. The `MariaDB spec`_
replaces the per-chart ``db-init`` job with ``Database``, ``User``, ``Grant``
and ``Connection`` resources. The `RabbitMQ spec`_ replaces ``rabbit-init``
with a group of topology resources.

Keystone chart: custom resource definitions
-------------------------------------------

Eight custom resource definitions in the
``keystone.osh.openstack.org/v1alpha1`` API group. The resources they define
are namespaced. They are rendered by ``keystone/templates/crds.yaml`` and gated
on ``.Values.manifests.crds``:

============================  =================================================
Kind                          Describes
============================  =================================================
``Domain``                    A Keystone domain.
``Project``                   A project within a domain.
``Role``                      A role, global or domain-specific.
``Group``                     A group of users.
``User``                      A user account, with its password in a secret.
``RoleAssignment``            A role granted to a user or a group, on a
                              project or a domain.
``Service``                   A service catalog entry.
``Endpoint``                  The admin, internal and public URLs of a service
                              in one region.
============================  =================================================

The API group is per service, like the MariaDB and RabbitMQ groups, and for the
same reason: all three groups need a ``User`` kind, so a single flat
``osh.openstack.org`` group could not hold them. Every kind belongs to the
``keystone`` category, so ``kubectl get keystone`` lists the identity objects
in a namespace.

Each kind identifies a Keystone object by name, because a name is what a chart
knows when it renders. Keystone generates the IDs.

``services``, ``endpoints`` and ``roles`` are already resource names in other
API groups: the first two in core v1 and the third in
``rbac.authorization.k8s.io``. Those three kinds therefore have to be addressed
by their full names, such as ``services.keystone.osh.openstack.org``.

``metadata.name`` is the Kubernetes name, chosen by the chart that renders the
resource. ``spec.name`` is the Keystone name. The two are independent for two
reasons. First, several charts need the same Keystone objects: the ``service``
domain, the ``service`` project, and the ``admin``, ``service`` and ``member``
roles. Each chart declares its own resource for them, such as
``cinder-service`` and ``glance-service``. Because reconciliation looks an
object up and creates it only if it is missing, all of those resources converge
on one Keystone object. Second, a Keystone name does not have to be a valid
Kubernetes name. Cinder's ``cinder_nova`` user and Heat's ``heat_trustee`` user
contain an underscore, so each template lower-cases the Keystone name and
replaces every underscore with a hyphen.

Every kind has three common spec fields.

``keystoneRef.name`` names the Keystone deployment that the resource belongs
to. When it is unset or empty, the resource belongs to this controller. When it
names a different deployment, the resource belongs to another controller, and
this controller ignores it completely and does not write its status. Status
belongs to the controller that serves a resource, and two controllers would
keep overwriting each other's status, so a resource this controller ignores has
no condition at all. There is one exception: the controller removes its own
finalizer from such a resource, because leaving it would make the resource
impossible to delete.

``deletionPolicy`` is either ``retain`` or ``delete``, and defaults to
``retain``. Only ``delete`` adds a finalizer and removes the Keystone object.

The default is ``retain`` for two reasons. Deleting a ``Project`` orphans every
resource that belongs to it in every service, and ``helm uninstall`` of one
chart must not do that. And a shared object has several declarations: if Cinder
and Octavia both declare the ``service`` domain and Cinder is then uninstalled,
``delete`` would remove the domain that Octavia is still using. The controller
cannot prevent that, because each resource records only what its own chart
asked for. Counting the resources that name the same Keystone object would
still be wrong, since it would count only the ones in this namespace and miss
every object created outside the charts.

The consumer chart templates therefore never set ``deletionPolicy``, and
everything they render keeps the ``retain`` default. ``delete`` is meaningful
only for an object that exactly one resource declares, such as a service user
or an endpoint, and setting it is a deliberate choice in an override.

``retryInterval`` is the shortest delay before a failed resource is tried
again. It is written as a Go duration, such as ``30s``. When it is unset, the
controller uses its own configured backoff.

Every kind has a ``status`` subresource. It holds ``observedGeneration`` and a
``conditions`` list of ``metav1.Condition``. Each condition has the same fields
as in the MariaDB and RabbitMQ groups, so readiness is read the same way in all
three. Six kinds also record the ID that Keystone assigned, in a field named
after the kind: ``domainID``, ``projectID``, ``roleID``, ``groupID``,
``userID`` and ``serviceID``. ``Endpoint`` records ``endpointIDs``, one ID per
interface. ``RoleAssignment`` records no ID, because a grant has none.

.. code-block:: yaml

    status:
      observedGeneration: 3
      userID: 9a0e0f2c1b7d4e5f8a3c2b1d0e9f8a7b
      conditions:
        - type: Ready
          status: "True"          # True | False | Unknown
          reason: Reconciled      # Reconciled | ReconcileError
          message: created user cinder in domain service
          lastTransitionTime: "2026-08-24T19:20:00Z"
          observedGeneration: 3

Readiness is the condition with type ``Ready``. This is what ``kubectl wait
--for=condition=Ready`` reads and what the printer columns show.
``lastTransitionTime`` records when ``status`` last changed. The Keystone ID is
stored so that a deployer can match a resource against the output of a command
such as ``openstack user show``.

Example
~~~~~~~

These are the resources the Cinder chart renders for one of its service users
and for its catalog entry, in the order the controller handles them. That user
holds the ``admin``, ``service`` and ``member`` roles. The shared domain,
project and roles are declared by every chart that needs them:

.. code-block:: yaml

    apiVersion: keystone.osh.openstack.org/v1alpha1
    kind: Domain
    metadata:
      name: cinder-service
    spec:
      keystoneRef:
        name: keystone
      name: service
      description: Domain for service
    ---
    apiVersion: keystone.osh.openstack.org/v1alpha1
    kind: Project
    metadata:
      name: cinder-service
    spec:
      keystoneRef:
        name: keystone
      name: service
      domain: service
      description: Service Project for service
    ---
    apiVersion: keystone.osh.openstack.org/v1alpha1
    kind: Role
    metadata:
      name: cinder-admin
    spec:
      keystoneRef:
        name: keystone
      name: admin
    ---
    apiVersion: keystone.osh.openstack.org/v1alpha1
    kind: Role
    metadata:
      name: cinder-service
    spec:
      keystoneRef:
        name: keystone
      name: service
    ---
    apiVersion: keystone.osh.openstack.org/v1alpha1
    kind: Role
    metadata:
      name: cinder-member
    spec:
      keystoneRef:
        name: keystone
      name: member
    ---
    apiVersion: keystone.osh.openstack.org/v1alpha1
    kind: User
    metadata:
      name: cinder-cinder
    spec:
      keystoneRef:
        name: keystone
      name: cinder
      domain: service
      description: Service User for RegionOne/service/cinder
      defaultProject:
        name: service
        domain: service
      passwordSecret:
        name: cinder-keystone-user
        key: OS_PASSWORD
    ---
    apiVersion: keystone.osh.openstack.org/v1alpha1
    kind: RoleAssignment
    metadata:
      name: cinder-cinder-admin
    spec:
      keystoneRef:
        name: keystone
      role:
        name: admin
      user:
        name: cinder
        domain: service
      project:
        name: service
        domain: service
    ---
    apiVersion: keystone.osh.openstack.org/v1alpha1
    kind: RoleAssignment
    metadata:
      name: cinder-cinder-service
    spec:
      keystoneRef:
        name: keystone
      role:
        name: service
      user:
        name: cinder
        domain: service
      project:
        name: service
        domain: service
    ---
    apiVersion: keystone.osh.openstack.org/v1alpha1
    kind: RoleAssignment
    metadata:
      name: cinder-cinder-member
    spec:
      keystoneRef:
        name: keystone
      role:
        name: member
      user:
        name: cinder
        domain: service
      project:
        name: service
        domain: service
    ---
    apiVersion: keystone.osh.openstack.org/v1alpha1
    kind: Service
    metadata:
      name: cinder-volumev3
    spec:
      keystoneRef:
        name: keystone
      name: cinderv3
      type: volumev3
      description: "RegionOne: cinderv3 (volumev3) service"
    ---
    apiVersion: keystone.osh.openstack.org/v1alpha1
    kind: Endpoint
    metadata:
      name: cinder-volumev3
    spec:
      keystoneRef:
        name: keystone
      service:
        name: cinderv3
        type: volumev3
      region: RegionOne
      urls:
        admin: http://cinder-api.openstack.svc.cluster.local:8776/v3
        internal: http://cinder-api.openstack.svc.cluster.local:8776/v3
        public: http://cinder.openstack.svc.cluster.local/v3

``User`` and its password
~~~~~~~~~~~~~~~~~~~~~~~~~

``User.spec`` does not hold a password. ``spec.passwordSecret`` names a secret
and a key instead. The key defaults to ``OS_PASSWORD``, which is the key of the
``<service>-keystone-<userClass>`` openrc secrets that every consumer chart
already renders. A chart that adopts this path therefore needs no new secret.
The ``User`` points at the secret its service already reads, so the two cannot
end up with different passwords.

The controller writes the password the same way ``ks-user.sh`` does, and for
the same reason. It first tries to authenticate as the user with the wanted
password, and it writes the password only if that attempt returns ``401``. What
changes is how often that probe runs. The controller folds the value of the
secret into its hash of the desired state, so the probe runs only when the
password has changed or during a periodic resync, not on every sweep.

``Group`` and the group subject
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A role is granted to a **subject**, which in Keystone is either a user or a
group. ``RoleAssignment.spec`` therefore sets exactly one of ``spec.user`` and
``spec.group``, and an ``x-kubernetes-validations`` expression enforces that in
the same way as the project or domain scope. None of the charts converted here
sets ``spec.group``, because a service account is a user. ``Group`` is
therefore the one kind that no chart renders.

``Group`` exists for federated deployments, where there is no user to name.
There, identities come from an identity provider as shadow users that Keystone
creates on first login. Nothing can be declared in advance, and this chart
holds no password for them.

What a federated deployment declares instead is the group, and the roles that
group holds. Which users end up in that group is decided by a Keystone
**mapping**: a set of rules that translates the assertion an identity provider
sends into local attributes, including the groups a user is placed in. The
mapping is itself a Keystone object, declared by one of the federation kinds
listed as a follow-up below:

.. code-block:: yaml

    apiVersion: keystone.osh.openstack.org/v1alpha1
    kind: Group
    metadata:
      name: federated-admins
    spec:
      keystoneRef:
        name: keystone
      name: federated-admins
      domain: service
      description: Administrators mapped in from the identity provider
    ---
    apiVersion: keystone.osh.openstack.org/v1alpha1
    kind: RoleAssignment
    metadata:
      name: federated-admins-admin
    spec:
      keystoneRef:
        name: keystone
      role:
        name: admin
      group:
        name: federated-admins
        domain: service
      domain:
        name: service

``spec.group`` is defined here rather than with the rest of the federation
kinds, because it is the only part of federation that changes a kind this
change already defines. Adding it later would not break anything: ``spec.user``
is not a required field, and the constraint lives entirely in one validation
rule, so only that rule would change.

Group membership is not a field. In a federated deployment the members are
whatever the mapping produces, and a list of users would be a second place to
describe a relationship the mapping already owns. Local group membership does
need such a list, and nothing declared here uses local groups.

``Endpoint`` and its region
~~~~~~~~~~~~~~~~~~~~~~~~~~~

``Endpoint`` holds all three interfaces of one service in one region, as the
example above shows. One resource is used instead of three because the three
interfaces belong together. They change together and they are read together,
and the job being replaced already handles them as one unit, split over three
containers. An interface that is left out is not published.

The service is identified by both its name and its type. This is the same pair
that ``ks-endpoints.sh`` searches for, and neither part alone is unique. An
``Endpoint`` deliberately does not reference a ``Service`` resource. The
controller looks the pair up in Keystone, so an ``Endpoint`` also works for a
service that this chart did not declare.

Regions are created automatically. Nothing here needs more of a region than its
name, so a ninth kind would exist only as a prerequisite for ``Endpoint``. The
controller creates the region when it is missing, instead of relying on the
Identity API to create it, so the behaviour is the same on every Keystone
version.

Keystone chart: the identity controller
---------------------------------------

``keystone/templates/bin/_identity_controller.py.tpl`` is a single-file Python
program. It is deployed by
``keystone/templates/deployment-identity-controller.yaml`` and gated on
``.Values.manifests.deployment_identity_controller``. It follows the `MariaDB
database controller`_ that the MariaDB chart already ships: the same namespaced
RBAC role, the same environment variable convention, and the same
poll-and-reconcile structure.

It runs on the ``openstack-client`` image that the chart already pulls for its
bootstrap job, and nothing has to be added to that image. Kubernetes is reached
with the official ``kubernetes`` client, and Keystone with ``openstacksdk``.
Both libraries are already installed there. ``openstacksdk`` is the library the
``openstack`` CLI itself uses, and it has two advantages over sending HTTP
requests directly. It loads its authentication plugin from the environment, so
whatever ``identity.openrc`` configures works without the controller knowing
which plugin is in use. Its identity proxy also returns typed objects and typed
exceptions, instead of status codes that the caller has to interpret.

The password probe described above is the one place where a status code still
matters. It has to tell a rejected password from an unreachable Keystone, so it
asks the underlying ``keystoneauth1`` session for a token and catches
``Unauthorized`` directly. Writing the password after a network failure would
invalidate every token the user holds for no reason.

The ``openstack`` CLI is not used, because running it means starting a new
process for every object, every time the controller runs, and it reduces API
errors to an exit code and a line of text.

The controller polls instead of watching. One sweep covers all eight kinds and
runs every ``RECONCILE_INTERVAL`` seconds. Watching eight kinds from a
single-threaded script would need eight parallel streams, plus handling of
``resourceVersion`` and ``410 Gone``. That is a large part of the program, and
it would only save a few seconds of latency on a small number of objects.

Within one sweep the kinds are reconciled in this order: ``Domain``,
``Project``, ``Role``, ``Group``, ``User``, ``RoleAssignment``, ``Service``,
``Endpoint``. The order matters, because a project needs its domain, a role
assignment needs its role, its subject and its project, and an endpoint needs
its service. Dependencies between resources are handled by this order and by
retrying, not by reading the status of other resources. Keystone is the source
of truth, and a resource that fails because its dependency does not exist yet
succeeds in a later sweep.

Six of the eight kinds are handled as a lookup, followed by a create or a
patch. ``RoleAssignment`` needs no lookup, because the grant itself is a
``PUT``. ``Endpoint`` is looked up by service, interface and region rather than
by a name:

==================  ===============================================
Kind                Calls the controller makes
==================  ===============================================
``Domain``          ``GET|POST /v3/domains``, ``PATCH /v3/domains/{id}``
``Project``         ``GET|POST /v3/projects``, ``PATCH /v3/projects/{id}``
``Role``            ``GET|POST /v3/roles``
``Group``           ``GET|POST /v3/groups``, ``PATCH /v3/groups/{id}``
``User``            ``GET|POST /v3/users``, ``PATCH /v3/users/{id}``
``RoleAssignment``  ``PUT /v3/projects/{p}/users/{u}/roles/{r}``; the subject
                    collection is ``groups`` for a group, and the scope is
                    ``/v3/domains/{d}/...`` for a domain-scoped grant
``Service``         ``GET|POST /v3/services``, ``PATCH /v3/services/{id}``
``Endpoint``        ``GET|POST /v3/endpoints``, ``PATCH /v3/endpoints/{id}``
==================  ===============================================

Lookups are filtered queries, for example ``?name=cinder&domain_id=...``, and
the API is asked to do the filtering. Nothing is matched with a pattern over
text output, which removes the fragility of the current ``grep`` calls. A role
assignment is a ``PUT``, so it is idempotent by definition, and the other kinds
are idempotent because they look an object up before updating it. The
controller stores a hash of the desired state to skip requests that would
change nothing, and a periodic forced resync repairs changes made outside the
controller. The jobs can only repair drift when a
deployer runs ``helm upgrade``.

Two behaviours of the current scripts are deliberately not kept. First, an
``Endpoint`` whose URL changed is updated with a patch, so it keeps its ID.
Second, duplicate endpoints for the same service, region and interface are
reported in the ``Ready`` message instead of being deleted. The controller
adopts one of them, chosen by lowest ID, and names the others in the message. A
controller should not silently delete objects that it did not create.

The controller authenticates with the administrative credentials in the
Keystone chart's own ``keystone-keystone-admin`` secret, over the internal
identity endpoint. When ``secrets.tls.ca`` names a CA bundle, that bundle is
mounted and passed to the connection for verification.

The deployment runs one replica and replaces its pod rather than rolling it,
because the controller does no leader election. Two controllers probing the
same user's password would double the failed-login count that
``lockout_failure_attempts`` sees.

Consumer charts declare their own resources
-------------------------------------------

Each chart declares its identity objects in its own
``templates/identity-entities.yaml``, gated by ``manifests.identity_entities``.
There is deliberately no Helm-toolkit manifest that generates them. The users,
roles and catalog entries of a chart are part of that chart's contract, and a
reader should be able to see them without following an indirection into shared
code. This also lets each chart differ from the others. Cinder publishes one,
two or three service types, and Heat owns a second user for its trustee,
without adding arguments to a shared macro.

The templates do not hardcode any name or credential:

.. code-block::

    {{- range $userClass := $serviceUsers }}
    {{- $auth := index $envAll.Values.endpoints.identity.auth $userClass }}
    ...
      name: {{ $auth.username }}
      domain: {{ $auth.user_domain_name }}
      passwordSecret:
        name: {{ index $envAll.Values.secrets.identity $userClass }}
    {{- end }}

``endpoints.identity.auth.<userClass>`` holds the username, the domains, the
project and the roles. ``secrets.identity.<userClass>`` names the password
secret. ``endpoints.identity.hosts.default`` names the Keystone used for
``keystoneRef``. The URLs come from
``helm-toolkit.endpoints.keystone_endpoint_uri_lookup``, the helper that the
ks-endpoints job already uses, so the catalog entry of a chart does not change.
The only new value in a consumer chart is one ``manifests`` boolean.

For every service user, a converted chart renders a ``User`` and the
``Project`` that user needs. It also renders a ``Domain`` for the user domain
and for the project domain, unless that domain is ``Default``, which always
exists. It adds a ``Role`` and a ``RoleAssignment`` for each role in
``endpoints.identity.auth.<userClass>.role``, and for the ``member`` role that
``ks-user.sh`` always adds. It renders a ``Service`` for every service type the
chart owns, and an ``Endpoint`` for each type that the ks-endpoints job
publishes, which is not always all of them. These are the same objects the
three jobs create, but each one is now a separate resource that can be
inspected.

Ordering and readiness
~~~~~~~~~~~~~~~~~~~~~~

In a consumer chart, enabling ``manifests.identity_entities`` removes three
jobs and adds nothing to any pod. Those jobs were also
``kubernetes-entrypoint`` dependencies: every component that reaches the
Keystone catalog waited for the ks_user and ks_endpoints jobs of its own
chart, and ``helm-toolkit.utils.dependency_jobs_filter`` drops a disabled job
from those lists. Nothing would then make a component wait.

The custom resources take that role instead. Each override adds a
``custom_resources`` dependency for the same components, on the ``User`` and
the ``Endpoint`` the chart declares:

.. code-block:: yaml

    dependencies:
      static:
        api:
          custom_resources:
            - apiVersion: keystone.osh.openstack.org/v1alpha1
              kind: User
              name: cinder-cinder
              conditions:
                - type: Ready

This waits for the work itself rather than for a job that did the work, which
is the more direct statement of the same requirement. ``kubernetes-entrypoint``
selects a condition by type, so ``conditions`` names the ``Ready`` condition
this group reports. The MariaDB group already depends on readiness this way.

The RBAC follows automatically.
``helm-toolkit.snippets.kubernetes_pod_rbac_roles`` emits one rule per
dependency, taking the API group from the entry's ``apiVersion`` and the
resource from its ``kind``. This group needs nothing added, because all eight
kinds are pluralised as the lowercase kind plus an ``s``. The rule is derived
per dependency, rather than granted for a whole group, on purpose:
``apiGroups`` accepts either an exact group or ``*``, and ``*`` also covers the
core group, which would give every init container ``get`` access to Secrets.

Who may create a ``RoleAssignment``
-----------------------------------

A ``RoleAssignment`` is a request to grant a role, and the controller carries
it out with the Keystone administrative credentials. Anyone who can create one
in the controller's namespace can therefore grant any role, including
``admin``, to any user. It has to be treated like the administrative secret
itself, and Kubernetes RBAC on ``roleassignments.keystone.osh.openstack.org``
is where that is done. Write access to it must be granted no more widely than
access to the secret.

Kubernetes cannot help here. Its own RBAC refuses to let a subject create a
``Role`` granting permissions the subject does not already hold, unless that
subject has the ``escalate`` verb. No such check exists for a custom resource,
because nothing tells the API server that this kind is privileged.

Three properties limit the reach of a resource that is created anyway.

The controller reads only its own namespace, so a ``RoleAssignment`` in any
other namespace is never reconciled. It also honours ``keystoneRef``, so a
resource naming a different Keystone deployment is ignored.

The controller's own RBAC role grants ``get``, ``list``, ``watch``, ``update``
and ``patch`` on the eight kinds, and ``create`` and ``delete`` on none of
them. It can only act on resources that something else created, and cannot
invent an assignment of its own.

The boundary is not new. Every one of the eighty-eight jobs this change
replaces mounts the same administrative secret into a pod in the same
namespace, so being able to create objects in the OpenStack namespace already
means being able to grant any role in Keystone. What changes is the shape of
the request: a small declarative object that a reviewer can read, in place of a
pod running a shell script.

Backward compatibility
----------------------

``manifests.identity_entities`` defaults to ``false`` in every consumer chart,
and ``manifests.deployment_identity_controller`` defaults to ``false`` in the
Keystone chart. With these defaults every consumer chart renders exactly as it
does today, and no existing deployment gains a pod, an RBAC rule or a restart.
The Keystone chart does render the eight definitions, because
``manifests.crds`` defaults to ``true`` as in the MariaDB and RabbitMQ charts,
but they do nothing while no resources exist. They also carry
``helm.sh/resource-policy: keep``, so uninstalling the Keystone release does
not cascade-delete the identity resources in the cluster. The hash of the bin
configmap is used in pod template annotations, so the controller's entry in
that configmap is gated on ``manifests.deployment_identity_controller`` too.

The two provisioning paths cannot be used together. Rendering fails with an
explicit message if ``manifests.identity_entities`` is enabled together with
``manifests.job_ks_user``, ``manifests.job_ks_service`` or
``manifests.job_ks_endpoints``, because both paths would write the same
password and compete over the same catalog entry. Nothing is needed in the
other direction, because ``helm-toolkit.utils.dependency_jobs_filter`` already
removes a disabled job from the dependencies of other jobs.

Keystone's own catalog entry does not change. ``keystone-manage bootstrap``
creates it in the chart's db-sync job, and that same command creates the admin
account the controller authenticates with.

The ``<service>-keystone-admin`` secrets are still rendered. This change
removes their largest group of readers, which is the three ks jobs in every
chart. But twenty-three charts also read them elsewhere, for example in Nova's
cell setup, Cinder's internal tenant job and every ``rally-test`` pod. Removing
these secrets is therefore a follow-up.

Implementation
==============

Assignee(s)
-----------

Primary assignee:
  kozhukalov (Vladimir Kozhukalov <kozhukalov@gmail.com>)

Work Items
----------

* Add the eight custom resource definitions, the identity controller, its
  deployment and RBAC, and the supporting values to the Keystone chart.
* Convert the six charts that own a catalog entry and are deployed by the
  check job below: Glance, Cinder, Placement, Nova, Neutron and Heat. Each
  chart gains a ``templates/identity-entities.yaml``, a
  ``manifests.identity_entities`` switch and an override that enables the path.
* Add a check pipeline job that deploys the compute kit and Cinder with the new
  provisioning path enabled.

Follow-ups, deliberately out of scope here:

* Heat's ``ks-user-domain`` job, which creates a domain, a domain-scoped user
  and a domain-scoped role assignment with `ks-domain-user.sh`_. ``Domain`` and
  a domain-scoped ``RoleAssignment`` can express it, but converting that job is
  separate from the three jobs every chart renders.
* The remaining charts that own a catalog entry.
* Retire the three jobs, their manifests and their scripts once every chart is
  converted, and remove the per-chart administrative openrc secrets with them.
* The federation kinds: ``IdentityProvider``, ``Mapping``, ``Protocol`` and
  ``ServiceProvider``. They are a separate change. All four are created with
  ``PUT`` and an ID chosen by the caller, so they need no lookup before create,
  no ID in ``status`` and no comparison for drift. The rules of a ``Mapping``
  are Keystone's own JSON dialect, so ``spec.rules`` should carry
  ``x-kubernetes-preserve-unknown-fields: true`` instead of repeating a schema
  that would fall behind. Deleting an ``IdentityProvider`` also leaves every
  shadow user created through it without a provider, so the ``retain`` default
  matters even more there.
* System-scoped role assignments, ``PUT
  /v3/system/(users|groups)/{id}/roles/{role}``. The scope is currently exactly
  one of a project or a domain.

Alternatives
------------

**Make the three jobs idempotent and re-runnable.** Re-running them is not the
problem, because they can already be re-run. They would still copy
administrative credentials into eighty-eight namespaced pods, still report no
status, and still notice drift only during ``helm upgrade``.

**Build the controller on an operator framework such as kopf.** kopf turns
handlers into decorated Python functions, watches the resources for the
caller, manages finalizers, and retries with backoff. It would remove the
sweep loop, the desired-state bookkeeping and the finalizer handling from this
controller: about 260 of its roughly 1000 lines. The eight handlers that do
the Keystone work would be the same either way, because that is where the work
is.

What counts against it is that watching resources makes the password harder to
follow, not easier. A rotation changes the secret and not the ``User``, so an
event-driven handler would have to watch secrets as well and map each one back
to the resources that name it, or fall back to a timer, which is the loop
again. Reading the secret while computing the desired state needs neither.

**Keep these custom resources, but reconcile them with ``shell-operator``.**
The charts would render exactly the resources described above, and
``shell-operator`` would run a hook on each change instead of the controller
running a loop. A hook is any executable, so the hooks could be written in
Python and use ``openstacksdk`` in the same way this controller does.

That is what makes the alternative weak: the hooks would be the reconcile
logic. The same code still has to be written, maintained and shipped in an
image, so the framework replaces the loop and nothing else.
``shell-operator`` runs a hook as a new process for each invocation, so every
invocation authenticates to Keystone again, where one long-running controller
holds a single session.

**Reconcile the Keystone objects with Crossplane and its OpenStack provider.**
``crossplane-contrib/provider-openstack`` is generated with Upjet from the
OpenStack Terraform provider, and it covers every object this spec needs:
``ProjectV3``, where a domain is a project with ``isDomain: true``, plus
``RoleV3``, ``GroupV3``, ``UserV3``, ``RoleAssignmentV3``, ``ServiceV3`` and
``EndpointV3``. It reads the user password from a secret, reconciles on its own
schedule and writes the result into each resource's status. The deployment
environment would install Crossplane and the provider, the Keystone chart would
render a ``ProviderConfig``, and the consumer charts would render managed
resources instead of the kinds defined here. No controller would have to be
written at all.

Three things count against it.

A managed resource always creates its object, and it cannot take over an object
that already exists. The external name of every identity resource in the
provider is the ID that Keystone returns after the create, so adopting an
existing object means writing that ID into the ``crossplane.io/external-name``
annotation, and a chart does not know it. The design above depends on the
opposite behaviour. Several charts declare the ``service`` domain, the
``service`` project and the ``admin``, ``service`` and ``member`` roles, and
they converge on one Keystone object because reconciliation looks the object up
before creating it. With managed resources the first chart would create the
domain and every later one would fail, because Keystone requires domain names
to be unique and answers the second create with a conflict.

The provider names a domain only by ID, which a chart cannot know for the same
reason. A ``domainIdRef`` field that resolves a domain through the name of
another managed resource is open for review upstream and is in no release yet.
See the `domain reference PR`_.

A password changed outside Kubernetes is not repaired. The provider cannot read
a password back out of Keystone, so ``UserV3`` carries no password in its
observed state and has nothing to compare against. The controller in this spec
learns it by authenticating as the user.

Documentation Impact
====================

The installation documentation gains a section about declarative identity
management and how to enable it. Chart value references are generated from the
``values.yaml`` comments, so the new keys are documented there.

.. _domain reference PR: https://github.com/crossplane-contrib/provider-openstack/pull/176
.. _ks-service manifest: https://opendev.org/openstack/openstack-helm/src/branch/master/helm-toolkit/templates/manifests/_job-ks-service.tpl
.. _ks-user manifest: https://opendev.org/openstack/openstack-helm/src/branch/master/helm-toolkit/templates/manifests/_job-ks-user.yaml.tpl
.. _ks-endpoints manifest: https://opendev.org/openstack/openstack-helm/src/branch/master/helm-toolkit/templates/manifests/_job-ks-endpoints.tpl
.. _ks-domain-user.sh: https://opendev.org/openstack/openstack-helm/src/branch/master/helm-toolkit/templates/scripts/_ks-domain-user.sh.tpl
.. _MariaDB database controller: https://opendev.org/openstack/openstack-helm/src/branch/master/mariadb/templates/bin/_mariadb_db_controller.py.tpl
.. _MariaDB spec: https://opendev.org/openstack/openstack-helm/src/branch/master/doc/source/specs/2026.1/mariadb_crd.rst
.. _RabbitMQ spec: https://opendev.org/openstack/openstack-helm/src/branch/master/doc/source/specs/2026.1/rabbitmq_crd.rst
