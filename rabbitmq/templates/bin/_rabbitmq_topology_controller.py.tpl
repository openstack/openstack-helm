#!/usr/bin/env python3

"""
RabbitMQ topology controller

Reconciles the Vhost, User, Permission, Queue, Exchange, Binding and Policy
custom resources shipped by this chart against the RabbitMQ cluster the chart
deploys, using the HTTP management API. Every operation is idempotent, so a
full sweep can run repeatedly without side effects.

Progress is reported the way the upstream messaging-topology-operator reports
it: observedGeneration plus a condition of type Ready in status.conditions, so
kubectl wait --for=condition=Ready works. The reason is SuccessfulCreateOrUpdate
or FailedCreateOrUpdate, which are the only two upstream defines.

The custom resource definitions declare every field upstream accepts, and every
field is implemented, so nothing is refused. A reference naming a broker this
controller does not serve -- by name, by connectionSecret or by namespace -- is
not an error but somebody else's resource, and is left untouched entirely. See
not_serving().

The Kubernetes side uses the official kubernetes client. The mariadb chart's
controllers still use pykube, whose last release is 23.6.0 from June 2023; new
code should not take that dependency, and migrating those controllers is
separate work. The broker side uses requests, which the official client depends
on anyway, against the HTTP management API: rabbitmqadmin is itself a client of
that API, so shelling out to it would only add a fork and lose the status codes
the handlers branch on.

Env variables:
RABBITMQ_TOPOLOGY_CONTROLLER_DEBUG: Flag to enable debug when set to 1.
RABBITMQ_TOPOLOGY_CONTROLLER_NAMESPACE: The namespace to watch resources in.
RABBITMQ_TOPOLOGY_CONTROLLER_API_GROUP: The API group of the custom resources.
RABBITMQ_TOPOLOGY_CONTROLLER_RECONCILE_INTERVAL: Delay between sweeps.
RABBITMQ_TOPOLOGY_CONTROLLER_FULL_RESYNC_INTERVAL: How often to re-declare
    resources whose desired state has not changed, repairing drift caused by
    changes made outside the controller. This is what corrects a definitions.json
    import that recreated the guest account after a node restart.
RABBITMQ_TOPOLOGY_CONTROLLER_ERROR_BACKOFF: Retry delay for a failing resource.
RABBITMQ_TOPOLOGY_CONTROLLER_KUBERNETES_REQUEST_TIMEOUT: Kubernetes API request
    timeout.
RABBITMQ_TOPOLOGY_CONTROLLER_REQUEST_TIMEOUT: RabbitMQ management API timeout.
RABBITMQ_TOPOLOGY_CONTROLLER_ONESHOT: Run a single sweep and exit when set to 1.
RABBITMQ_TOPOLOGY_CONTROLLER_DELETE_GUEST_USER: Delete the default guest
    account on every sweep when set to 1. The chart's definitions.json declares
    it and management.load_definitions imports that on every node boot, so a
    one-shot deletion does not hold.
RABBITMQ_TOPOLOGY_CONTROLLER_TLS_CA_FILE: CA bundle used to verify the
    management API when RABBITMQ_SCHEME is https.
RABBITMQ_SCHEME: http or https.
RABBITMQ_HOST: The RabbitMQ management API host.
RABBITMQ_PORT: The RabbitMQ management API port.
RABBITMQ_USER: The RabbitMQ administrative user.
RABBITMQ_PASSWORD: The RabbitMQ administrative password.
RABBITMQ_REF_NAME: The cluster name this controller answers for. A resource
    whose spec.rabbitmqClusterReference names anything else is left untouched,
    so that this controller and the upstream messaging-topology-operator can
    coexist in one namespace.

Changelog:
0.1.0: Initial version
"""


import base64
import hashlib
import json
import logging
import os
import re
import secrets
import sys
import time
import urllib.parse

import kubernetes
import requests

RABBITMQ_TOPOLOGY_CONTROLLER_DEBUG = os.getenv("RABBITMQ_TOPOLOGY_CONTROLLER_DEBUG")
RABBITMQ_TOPOLOGY_CONTROLLER_NAMESPACE = os.getenv(
    "RABBITMQ_TOPOLOGY_CONTROLLER_NAMESPACE", "openstack"
)
RABBITMQ_TOPOLOGY_CONTROLLER_API_GROUP = os.getenv(
    "RABBITMQ_TOPOLOGY_CONTROLLER_API_GROUP", "rabbitmq.osh.openstack.org"
)
RABBITMQ_TOPOLOGY_CONTROLLER_RECONCILE_INTERVAL = int(
    os.getenv("RABBITMQ_TOPOLOGY_CONTROLLER_RECONCILE_INTERVAL", 10)
)
RABBITMQ_TOPOLOGY_CONTROLLER_FULL_RESYNC_INTERVAL = int(
    os.getenv("RABBITMQ_TOPOLOGY_CONTROLLER_FULL_RESYNC_INTERVAL", 1800)
)
RABBITMQ_TOPOLOGY_CONTROLLER_ERROR_BACKOFF = int(
    os.getenv("RABBITMQ_TOPOLOGY_CONTROLLER_ERROR_BACKOFF", 10)
)
RABBITMQ_TOPOLOGY_CONTROLLER_REQUEST_TIMEOUT = int(
    os.getenv("RABBITMQ_TOPOLOGY_CONTROLLER_REQUEST_TIMEOUT", 60)
)
RABBITMQ_TOPOLOGY_CONTROLLER_KUBERNETES_REQUEST_TIMEOUT = int(
    os.getenv("RABBITMQ_TOPOLOGY_CONTROLLER_KUBERNETES_REQUEST_TIMEOUT", 60)
)
RABBITMQ_TOPOLOGY_CONTROLLER_ONESHOT = os.getenv(
    "RABBITMQ_TOPOLOGY_CONTROLLER_ONESHOT"
)
RABBITMQ_TOPOLOGY_CONTROLLER_DELETE_GUEST_USER = os.getenv(
    "RABBITMQ_TOPOLOGY_CONTROLLER_DELETE_GUEST_USER"
)
RABBITMQ_TOPOLOGY_CONTROLLER_TLS_CA_FILE = os.getenv(
    "RABBITMQ_TOPOLOGY_CONTROLLER_TLS_CA_FILE", "/etc/rabbitmq/certs/ca.crt"
)
RABBITMQ_SCHEME = os.getenv("RABBITMQ_SCHEME", "http")
RABBITMQ_HOST = os.getenv("RABBITMQ_HOST", "rabbitmq")
RABBITMQ_PORT = int(os.getenv("RABBITMQ_PORT", 15672))
RABBITMQ_USER = os.getenv("RABBITMQ_USER", "rabbitmq")
RABBITMQ_PASSWORD = os.getenv("RABBITMQ_PASSWORD", "")
RABBITMQ_REF_NAME = os.getenv("RABBITMQ_REF_NAME", "rabbitmq")

VERSION = "v1alpha1"
API_VERSION = f"{RABBITMQ_TOPOLOGY_CONTROLLER_API_GROUP}/{VERSION}"
FINALIZER = RABBITMQ_TOPOLOGY_CONTROLLER_API_GROUP + "/finalizer"
GENERATED_SECRET_SUFFIX = "-user-credentials"
GUEST_USER = "guest"

READY_CONDITION = "Ready"
REASON_SUCCESS = "SuccessfulCreateOrUpdate"
REASON_FAILURE = "FailedCreateOrUpdate"

log_level = "DEBUG" if RABBITMQ_TOPOLOGY_CONTROLLER_DEBUG else "INFO"
logging.basicConfig(
    stream=sys.stdout,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
LOG = logging.getLogger("rabbitmq-topology-controller")
LOG.setLevel(log_level)


class ReconcileError(Exception):
    """A resource could not be reconciled and should be retried."""


class ApiError(Exception):
    """A non-success HTTP status from one of the two APIs."""

    def __init__(self, code, detail):
        super().__init__(f"HTTP {code}: {detail}")
        self.code = code
        self.detail = detail


# ---------------------------------------------------------------------------
# The RabbitMQ management API
#
# One session for the whole process, so the connection is kept alive across
# sweeps and the credentials and CA bundle are configured once.
# ---------------------------------------------------------------------------


class Rabbit:
    """The RabbitMQ HTTP management API."""

    def __init__(self):
        self.base = f"{RABBITMQ_SCHEME}://{RABBITMQ_HOST}:{RABBITMQ_PORT}"
        self.session = requests.Session()
        self.session.auth = (RABBITMQ_USER, RABBITMQ_PASSWORD)
        self.session.headers["Accept"] = "application/json"
        if RABBITMQ_SCHEME == "https":
            # The management listener's certificate has to name the host the
            # endpoint lookup produced, which the chart's host_fqdn_override
            # arranges. This is the same verification the rabbit-init job does.
            ca_file = RABBITMQ_TOPOLOGY_CONTROLLER_TLS_CA_FILE
            self.session.verify = ca_file if os.path.exists(ca_file) else True
        LOG.info(f"RabbitMQ management API at {self.base}")

    def request(self, method, path, body=None, tolerate=()):
        """Issue one request, returning the decoded body or raising."""
        try:
            response = self.session.request(
                method,
                self.base + path,
                json=body,
                timeout=RABBITMQ_TOPOLOGY_CONTROLLER_REQUEST_TIMEOUT,
            )
        except requests.RequestException as error:
            raise ReconcileError(f"{method} {path} failed: {error}")
        if response.status_code in tolerate:
            return None
        if not response.ok:
            raise ApiError(response.status_code, response.text.strip())
        if not response.content:
            return None
        try:
            return response.json()
        except ValueError:
            return None



rabbit = Rabbit()


# ---------------------------------------------------------------------------
# Kubernetes access
# ---------------------------------------------------------------------------


def login():
    """Build the API clients, in cluster or from a kubeconfig.

    Two clients for the custom resources rather than one: the patching client
    pins its content type to a JSON merge patch with a default header, because
    the generated methods choose the first type the API offers and older
    releases of this library offer application/json-patch+json first, which
    would reject every dict payload below.
    """
    try:
        kubernetes.config.load_incluster_config()
        LOG.info("Created k8s api client from the in-cluster service account")
    except kubernetes.config.ConfigException:
        kubernetes.config.load_kube_config()
        LOG.info("Created k8s api client from a kubeconfig")
    patching = kubernetes.client.ApiClient()
    patching.set_default_header("Content-Type", "application/merge-patch+json")
    return (
        kubernetes.client.CustomObjectsApi(),
        kubernetes.client.CustomObjectsApi(patching),
        kubernetes.client.CoreV1Api(),
    )


custom_objects, custom_objects_patch, core = login()


class Kind:
    """One of our kinds: the name it reports and the endpoint serving it."""

    def __init__(self, kind, plural):
        self.kind = kind
        self.plural = plural


Vhost = Kind("Vhost", "vhosts")
User = Kind("User", "users")
Permission = Kind("Permission", "permissions")
Queue = Kind("Queue", "queues")
Exchange = Kind("Exchange", "exchanges")
Binding = Kind("Binding", "bindings")
Policy = Kind("Policy", "policies")


class Resource:
    """One custom resource, as the reconcilers below address it.

    The official client's custom object methods take the group, version, plural
    and name apart and hand back plain dicts, so the identity of a fetched
    object is kept here instead of being threaded through every call.
    """

    def __init__(self, kind, obj):
        self.kind = kind.kind
        self.plural = kind.plural
        self.obj = obj

    @property
    def name(self):
        return self.obj["metadata"]["name"]

    def patch(self, payload, status=False):
        """Merge-patch the object, or its status subresource."""
        method = (
            custom_objects_patch.patch_namespaced_custom_object_status
            if status
            else custom_objects_patch.patch_namespaced_custom_object
        )
        self.obj = method(
            group=RABBITMQ_TOPOLOGY_CONTROLLER_API_GROUP,
            version=VERSION,
            namespace=RABBITMQ_TOPOLOGY_CONTROLLER_NAMESPACE,
            plural=self.plural,
            name=self.name,
            body=payload,
            _request_timeout=(
                RABBITMQ_TOPOLOGY_CONTROLLER_KUBERNETES_REQUEST_TIMEOUT
            ),
        )


def list_resources(kind):
    """List resources of a kind, tolerating the CRD not being installed."""
    try:
        response = custom_objects.list_namespaced_custom_object(
            group=RABBITMQ_TOPOLOGY_CONTROLLER_API_GROUP,
            version=VERSION,
            namespace=RABBITMQ_TOPOLOGY_CONTROLLER_NAMESPACE,
            plural=kind.plural,
            _request_timeout=(
                RABBITMQ_TOPOLOGY_CONTROLLER_KUBERNETES_REQUEST_TIMEOUT
            ),
        )
    except kubernetes.client.ApiException as error:
        if error.status == 404:
            LOG.warning(f"CRD for {kind.kind} is not installed, skipping")
            return []
        raise
    return [Resource(kind, item) for item in response.get("items") or []]


def get_resource(kind, name):
    try:
        return Resource(
            kind,
            custom_objects.get_namespaced_custom_object(
                group=RABBITMQ_TOPOLOGY_CONTROLLER_API_GROUP,
                version=VERSION,
                namespace=RABBITMQ_TOPOLOGY_CONTROLLER_NAMESPACE,
                plural=kind.plural,
                name=name,
                _request_timeout=(
                    RABBITMQ_TOPOLOGY_CONTROLLER_KUBERNETES_REQUEST_TIMEOUT
                ),
            ),
        )
    except kubernetes.client.ApiException as error:
        if error.status == 404:
            return None
        raise


def read_secret(name):
    try:
        return core.read_namespaced_secret(
            name=name,
            namespace=RABBITMQ_TOPOLOGY_CONTROLLER_NAMESPACE,
            _request_timeout=(
                RABBITMQ_TOPOLOGY_CONTROLLER_KUBERNETES_REQUEST_TIMEOUT
            ),
        )
    except kubernetes.client.ApiException as error:
        if error.status == 404:
            return None
        raise


def secret_value(secret, key):
    data = (secret.data if secret else None) or {}
    if key not in data:
        return None
    return base64.b64decode(data[key]).decode("utf-8")


def patch_status(obj, status):
    """Merge-patch the status subresource."""
    obj.patch({"status": status}, status=True)


def ready_condition(obj):
    for condition in ((obj.obj.get("status") or {}).get("conditions") or []):
        if condition.get("type") == READY_CONDITION:
            return condition
    return None


def set_ready(obj, status, reason, message="", extra=None):
    """Write observedGeneration and the Ready condition, if either changed.

    The shape is the upstream one: observedGeneration at the root of status and
    a conditions list, so kubectl wait --for=condition=Ready works and the
    printer columns select on it.
    """
    generation = obj.obj["metadata"].get("generation")
    message = message[:512]
    extra = extra or {}

    conditions = list(((obj.obj.get("status") or {}).get("conditions") or []))
    current = None
    for index, condition in enumerate(conditions):
        if condition.get("type") == READY_CONDITION:
            current = (index, condition)
            break

    observed = (obj.obj.get("status") or {}).get("observedGeneration")
    if current is not None:
        _, existing = current
        unchanged = (
            existing.get("status") == status
            and existing.get("reason") == reason
            and existing.get("message", "") == message
            and observed == generation
            and all(
                (obj.obj.get("status") or {}).get(key) == value
                for key, value in extra.items()
            )
        )
        if unchanged:
            return
        # lastTransitionTime marks the last change of status, not of the
        # message, so a resync that only refreshes the message must keep it.
        transitioned = existing.get("status") != status
        last_transition = existing.get("lastTransitionTime")
    else:
        transitioned = True
        last_transition = None

    if transitioned or not last_transition:
        last_transition = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())

    ready = {
        "type": READY_CONDITION,
        "status": status,
        "reason": reason,
        "message": message,
        "lastTransitionTime": last_transition,
    }

    # Other condition types are not written by this controller, but a resource
    # it took over from another writer may carry some. Leave them alone.
    if current is None:
        conditions.append(ready)
    else:
        conditions[current[0]] = ready

    payload = dict(extra)
    payload["conditions"] = conditions
    if generation is not None:
        payload["observedGeneration"] = generation
    patch_status(obj, payload)


def add_finalizer(obj):
    finalizers = obj.obj["metadata"].get("finalizers") or []
    if FINALIZER in finalizers:
        return
    obj.patch({"metadata": {"finalizers": finalizers + [FINALIZER]}})


def remove_finalizer(obj):
    finalizers = obj.obj["metadata"].get("finalizers") or []
    if FINALIZER not in finalizers:
        return
    remaining = [item for item in finalizers if item != FINALIZER]
    obj.patch({"metadata": {"finalizers": remaining}})


# ---------------------------------------------------------------------------
# RabbitMQ management API helpers
# ---------------------------------------------------------------------------

# The management API addresses vhosts, users and objects inside a vhost by
# path segment, and the default vhost is literally "/", so every segment is
# percent-encoded with nothing left safe.
NAME_RE = re.compile(r"^[^\x00-\x1f\x7f]{1,255}$")


def segment(value, what):
    """Validate then percent-encode one path segment."""
    if not value or not NAME_RE.match(str(value)):
        raise ReconcileError(f"invalid {what}: {value!r}")
    return urllib.parse.quote(str(value), safe="")


def tag_list(tags):
    """Render a tag list the way every supported broker version accepts it.

    RabbitMQ has accepted a JSON list for user and vhost tags only since 3.11;
    a comma separated string is understood by every version this chart can be
    pointed at, including the 3.10 default.
    """
    return ",".join(str(tag) for tag in tags or [])


def declared_vhost(spec):
    return spec.get("vhost") or "/"


# ---------------------------------------------------------------------------
# Reconcilers
#
# Each returns a message for the Ready condition, or a (message, extra status
# fields) pair.
# ---------------------------------------------------------------------------


def reconcile_vhost(obj, spec):
    name = spec.get("name") or obj.name
    body = {"tracing": bool(spec.get("tracing"))}
    if spec.get("tags"):
        body["tags"] = tag_list(spec["tags"])
    if spec.get("defaultQueueType"):
        body["default_queue_type"] = spec["defaultQueueType"]
    rabbit.request("PUT", f"/api/vhosts/{segment(name, 'vhost')}", body)
    return f"declared vhost {name}"


def finalize_vhost(obj, spec):
    name = spec.get("name") or obj.name
    LOG.info(f"Deleting vhost {name} per deletionPolicy delete")
    rabbit.request(
        "DELETE", f"/api/vhosts/{segment(name, 'vhost')}", tolerate=(404,)
    )


def owner_reference(kind, obj):
    metadata = obj.obj["metadata"]
    return {
        "apiVersion": (
            API_VERSION
        ),
        "kind": kind,
        "name": metadata["name"],
        "uid": metadata["uid"],
        "controller": True,
        "blockOwnerDeletion": False,
    }


def generated_credentials(obj):
    """Read, or create once, the credentials secret for a bare User resource.

    This is what upstream does for a User with no importCredentialsSecret: a
    password is generated and published in a secret named after the resource.
    It is only written when absent, so the password is not rotated on every
    sweep.
    """
    name = obj.name + GENERATED_SECRET_SUFFIX
    existing = read_secret(name)
    if existing:
        username = secret_value(existing, "username")
        password = secret_value(existing, "password")
        if username and password:
            return name, username, password
        raise ReconcileError(f"secret {name} has no username or password key")

    username = obj.name
    password = secrets.token_urlsafe(24)
    body = {
        "apiVersion": "v1",
        "kind": "Secret",
        "type": "Opaque",
        "metadata": {
            "name": name,
            "namespace": RABBITMQ_TOPOLOGY_CONTROLLER_NAMESPACE,
            "labels": {"application": "rabbitmq", "component": "user-credentials"},
            "ownerReferences": [owner_reference("User", obj)],
        },
        "data": {
            "username": base64.b64encode(username.encode("utf-8")).decode("ascii"),
            "password": base64.b64encode(password.encode("utf-8")).decode("ascii"),
        },
    }
    try:
        core.create_namespaced_secret(
            namespace=RABBITMQ_TOPOLOGY_CONTROLLER_NAMESPACE,
            body=body,
            _request_timeout=(
                RABBITMQ_TOPOLOGY_CONTROLLER_KUBERNETES_REQUEST_TIMEOUT
            ),
        )
    except kubernetes.client.ApiException as error:
        if error.status != 409:
            raise
        # Lost a race with another writer; the existing secret wins.
        return generated_credentials(obj)
    LOG.info(f"Generated credentials secret {name}")
    return name, username, password


def user_credentials(obj):
    """Return (secret name, username, password) for a User resource."""
    spec = obj.obj.get("spec") or {}
    imported = spec.get("importCredentialsSecret") or {}
    if not imported.get("name"):
        return generated_credentials(obj)
    name = imported["name"]
    secret = read_secret(name)
    if secret is None:
        raise ReconcileError(f"secret {name} does not exist")
    password = secret_value(secret, "password")
    if password is None:
        raise ReconcileError(f"secret {name} has no password key")
    username = secret_value(secret, "username") or obj.name
    return name, username, password


def reconcile_user(obj, spec):
    secret_name, username, password = user_credentials(obj)
    body = {"password": password, "tags": tag_list(spec.get("tags"))}
    rabbit.request("PUT", f"/api/users/{segment(username, 'user')}", body)
    return (
        f"declared user {username}",
        {"username": username, "credentials": {"name": secret_name}},
    )


def finalize_user(obj, spec):
    _, username, _ = user_credentials(obj)
    LOG.info(f"Deleting user {username} per deletionPolicy delete")
    rabbit.request(
        "DELETE", f"/api/users/{segment(username, 'user')}", tolerate=(404,)
    )


def permission_username(spec):
    """Resolve spec.user, or spec.userReference to the User it names."""
    if spec.get("user"):
        return spec["user"]
    reference = spec.get("userReference") or {}
    if not reference.get("name"):
        raise ReconcileError("one of user or userReference is required")
    user = get_resource(User, reference["name"])
    if user is None:
        raise ReconcileError(f"User {reference['name']} does not exist")
    # status.username is authoritative once the User has reconciled; before
    # that, derive the same name the User reconciler would use, so that a
    # Permission does not have to wait a whole sweep for it to appear.
    username = (user.obj.get("status") or {}).get("username")
    if username:
        return username
    return user_credentials(user)[1]


def reconcile_permission(obj, spec):
    vhost = spec.get("vhost")
    if not vhost:
        raise ReconcileError("spec.vhost is required")
    username = permission_username(spec)
    permissions = spec.get("permissions") or {}
    body = {
        "configure": permissions.get("configure", ""),
        "write": permissions.get("write", ""),
        "read": permissions.get("read", ""),
    }
    rabbit.request(
        "PUT",
        f"/api/permissions/{segment(vhost, 'vhost')}/{segment(username, 'user')}",
        body,
    )
    return f"declared permissions for {username} on {vhost}"


def finalize_permission(obj, spec):
    vhost = spec.get("vhost")
    username = permission_username(spec)
    LOG.info(f"Deleting permissions for {username} on {vhost}")
    rabbit.request(
        "DELETE",
        f"/api/permissions/{segment(vhost, 'vhost')}/{segment(username, 'user')}",
        tolerate=(404,),
    )


def queue_arguments(spec):
    """The queue arguments, with spec.type folded in as x-queue-type.

    PUT /api/queues has no type field of its own: the queue type is an
    argument, which is how rabbitmqadmin and the upstream operator's client
    express it too. An explicit x-queue-type in spec.arguments wins.
    """
    arguments = dict(spec.get("arguments") or {})
    if spec.get("type") and "x-queue-type" not in arguments:
        arguments["x-queue-type"] = spec["type"]
    return arguments


def reconcile_queue(obj, spec):
    vhost = declared_vhost(spec)
    name = spec.get("name") or obj.name
    body = {
        "durable": bool(spec.get("durable")),
        "auto_delete": bool(spec.get("autoDelete")),
        "arguments": queue_arguments(spec),
    }
    rabbit.request(
        "PUT",
        f"/api/queues/{segment(vhost, 'vhost')}/{segment(name, 'queue')}",
        body,
    )
    return f"declared queue {name} on {vhost}"


def finalize_queue(obj, spec):
    vhost = declared_vhost(spec)
    name = spec.get("name") or obj.name
    LOG.info(f"Deleting queue {name} on {vhost} per deletionPolicy delete")
    rabbit.request(
        "DELETE",
        f"/api/queues/{segment(vhost, 'vhost')}/{segment(name, 'queue')}",
        tolerate=(404,),
    )


def reconcile_exchange(obj, spec):
    vhost = declared_vhost(spec)
    name = spec.get("name") or obj.name
    body = {
        "type": spec.get("type") or "direct",
        "durable": bool(spec.get("durable")),
        "auto_delete": bool(spec.get("autoDelete")),
        "arguments": dict(spec.get("arguments") or {}),
    }
    rabbit.request(
        "PUT",
        f"/api/exchanges/{segment(vhost, 'vhost')}/{segment(name, 'exchange')}",
        body,
    )
    return f"declared exchange {name} on {vhost}"


def finalize_exchange(obj, spec):
    vhost = declared_vhost(spec)
    name = spec.get("name") or obj.name
    LOG.info(f"Deleting exchange {name} on {vhost} per deletionPolicy delete")
    rabbit.request(
        "DELETE",
        f"/api/exchanges/{segment(vhost, 'vhost')}/{segment(name, 'exchange')}",
        tolerate=(404,),
    )


def binding_path(spec):
    """The management API path listing the bindings this resource describes."""
    vhost = declared_vhost(spec)
    source = spec.get("source")
    destination = spec.get("destination")
    if not source or not destination:
        raise ReconcileError("spec.source and spec.destination are required")
    kind = "q" if (spec.get("destinationType") or "queue") == "queue" else "e"
    return (
        f"/api/bindings/{segment(vhost, 'vhost')}"
        f"/e/{segment(source, 'source')}"
        f"/{kind}/{segment(destination, 'destination')}"
    )


def existing_binding(spec):
    """The broker's view of this binding, or None.

    A binding has no name in the management API, so it is identified by its
    routing key and arguments among the bindings between the same source and
    destination. The properties_key the broker returns is what a later delete
    needs.
    """
    routing_key = spec.get("routingKey") or ""
    arguments = dict(spec.get("arguments") or {})
    listed = rabbit.request("GET", binding_path(spec), tolerate=(404,)) or []
    for binding in listed:
        if binding.get("routing_key", "") != routing_key:
            continue
        if (binding.get("arguments") or {}) == arguments:
            return binding
    return None


def reconcile_binding(obj, spec):
    destination = spec.get("destination")
    if existing_binding(spec) is not None:
        return f"binding to {destination} is present"
    body = {
        "routing_key": spec.get("routingKey") or "",
        "arguments": dict(spec.get("arguments") or {}),
    }
    rabbit.request("POST", binding_path(spec), body)
    return f"declared binding to {destination}"


def finalize_binding(obj, spec):
    binding = existing_binding(spec)
    if binding is None:
        return
    properties_key = binding.get("properties_key")
    if not properties_key:
        raise ReconcileError("the broker returned a binding with no properties_key")
    LOG.info(f"Deleting binding to {spec.get('destination')}")
    rabbit.request(
        "DELETE",
        f"{binding_path(spec)}/{segment(properties_key, 'properties key')}",
        tolerate=(404,),
    )


def reconcile_policy(obj, spec):
    vhost = declared_vhost(spec)
    name = spec.get("name") or obj.name
    if not spec.get("pattern"):
        raise ReconcileError("spec.pattern is required")
    body = {
        "pattern": spec["pattern"],
        "definition": dict(spec.get("definition") or {}),
        "priority": int(spec.get("priority") or 0),
        "apply-to": spec.get("applyTo") or "all",
    }
    if not body["definition"]:
        raise ReconcileError("spec.definition is required")
    rabbit.request(
        "PUT",
        f"/api/policies/{segment(vhost, 'vhost')}/{segment(name, 'policy')}",
        body,
    )
    return f"declared policy {name} on {vhost}"


def finalize_policy(obj, spec):
    vhost = declared_vhost(spec)
    name = spec.get("name") or obj.name
    LOG.info(f"Deleting policy {name} on {vhost} per deletionPolicy delete")
    rabbit.request(
        "DELETE",
        f"/api/policies/{segment(vhost, 'vhost')}/{segment(name, 'policy')}",
        tolerate=(404,),
    )


# Reconciled in this order within a sweep: a permission on a vhost that does
# not exist fails, and so does a binding to a queue that has not been declared.
HANDLERS = (
    (Vhost, reconcile_vhost, finalize_vhost),
    (User, reconcile_user, finalize_user),
    (Permission, reconcile_permission, finalize_permission),
    (Exchange, reconcile_exchange, finalize_exchange),
    (Queue, reconcile_queue, finalize_queue),
    (Binding, reconcile_binding, finalize_binding),
    (Policy, reconcile_policy, finalize_policy),
)


# ---------------------------------------------------------------------------
# Reconcile loop
# ---------------------------------------------------------------------------

# uid -> (desired state hash, timestamp of the last successful apply)
applied = {}
# uid -> timestamp before which the resource is not retried
backoff = {}
# uid -> why the resource is not served, so it is logged once rather than every
# sweep. Nothing is written to the object itself, so the log is the only record.
unserved = {}


def desired_hash(spec, extra=""):
    """A digest of everything that would change the requests we issue."""
    material = json.dumps(spec, sort_keys=True, default=str) + extra
    return hashlib.sha256(material.encode("utf-8")).hexdigest()


def cluster_reference(spec):
    return spec.get("rabbitmqClusterReference") or {}


def not_serving(spec):
    """Why this controller does not answer for the resource, or None.

    Every reading of rabbitmqClusterReference happens here. This controller is
    deployed alongside exactly one broker and takes that broker's address and
    credentials from its own environment, so it never resolves the reference to
    find a cluster -- it only asks whether the reference names the cluster it
    already serves. Three spellings say it does not:

      * a name that is not this cluster,
      * a connectionSecret, which names a broker reached by a URI in a secret,
      * a namespace other than this controller's own.

    In all three cases the resource belongs to something else -- the upstream
    messaging-topology-operator, or another release of this chart -- and the
    only correct action is none at all. Not even a status write: status belongs
    to whichever controller serves the resource, and two controllers writing
    conditions to one object would flap against each other forever.
    """
    reference = cluster_reference(spec)
    connection_secret = (reference.get("connectionSecret") or {}).get("name")
    if connection_secret:
        return (
            f"rabbitmqClusterReference.connectionSecret names "
            f"{connection_secret}, and this controller serves only the cluster "
            f"it is deployed with"
        )
    namespace = reference.get("namespace")
    if namespace and namespace != RABBITMQ_TOPOLOGY_CONTROLLER_NAMESPACE:
        return (
            f"rabbitmqClusterReference.namespace is {namespace}, and this "
            f"controller serves only {RABBITMQ_TOPOLOGY_CONTROLLER_NAMESPACE}"
        )
    name = reference.get("name")
    if name and name != RABBITMQ_REF_NAME:
        return (
            f"rabbitmqClusterReference.name is {name}, and this controller "
            f"serves {RABBITMQ_REF_NAME}"
        )
    return None


def delete_guest_user():
    """Remove the default account, which definitions.json keeps recreating.

    The chart declares guest in definitions.json and
    management.load_definitions imports that on every node boot, while
    loopback_users.guest is false, so the account can log in from anywhere.
    Deleting it once, as the rabbit-init job does, does not hold across a node
    restart. Doing it every sweep does.
    """
    try:
        deleted = rabbit.request(
            "DELETE", f"/api/users/{GUEST_USER}", tolerate=(404,)
        )
    except (ApiError, ReconcileError) as error:
        LOG.warning(f"Could not delete the {GUEST_USER} user: {error}")
        return
    if deleted is not None:
        LOG.info(f"Deleted the {GUEST_USER} user")


def reconcile(obj, handler, finalizer):
    spec = obj.obj.get("spec") or {}
    uid = obj.obj["metadata"]["uid"]
    now = time.monotonic()

    # Settled before anything else: a resource served by another controller must
    # be left entirely alone, so that this one and the upstream operator can
    # share a namespace without contending over the same objects.
    reason = not_serving(spec)
    if reason:
        # Reported once rather than on every sweep, and only to the log, since
        # the object itself is not ours to write to.
        if unserved.get(uid) != reason:
            LOG.info(f"Not serving {obj.kind} {obj.name}: {reason}")
            unserved[uid] = reason
        # A resource repointed at another cluster while carrying this
        # controller's finalizer would otherwise never be deletable. Removing
        # our own mark is cleanup, not a claim, and is a no-op when absent.
        remove_finalizer(obj)
        # Forget what was applied: whatever serves it now may change the object
        # in the broker, so a resource handed back later has to be declared
        # again rather than skipped as unchanged.
        applied.pop(uid, None)
        return
    unserved.pop(uid, None)

    if backoff.get(uid, 0) > now:
        return

    delete = (spec.get("deletionPolicy") or "delete") == "delete"

    if "deletionTimestamp" in obj.obj["metadata"]:
        if finalizer and delete:
            finalizer(obj, spec)
        remove_finalizer(obj)
        applied.pop(uid, None)
        return

    if finalizer and delete:
        add_finalizer(obj)
    else:
        # Flipping deletionPolicy from delete back to retain must not leave a
        # finalizer behind that would wedge a later deletion.
        remove_finalizer(obj)

    # For a User the password lives in a secret, so the secret's content is
    # part of the desired state even when the spec has not changed.
    extra_material = ""
    if obj.kind == "User":
        extra_material = hashlib.sha256(
            user_credentials(obj)[2].encode("utf-8")
        ).hexdigest()

    digest = desired_hash(spec, extra_material)
    previous = applied.get(uid)
    stale = (
        previous is None
        or previous[0] != digest
        or now - previous[1] >= RABBITMQ_TOPOLOGY_CONTROLLER_FULL_RESYNC_INTERVAL
    )
    if not stale:
        condition = ready_condition(obj) or {}
        set_ready(
            obj, "True", REASON_SUCCESS, condition.get("message", "")
        )
        return

    result = handler(obj, spec)
    if isinstance(result, tuple):
        message, extra_status = result
    else:
        message, extra_status = result, None
    applied[uid] = (digest, now)
    LOG.info(f"{obj.kind} {obj.name}: {message}")
    set_ready(obj, "True", REASON_SUCCESS, message, extra_status)


def sweep():
    if RABBITMQ_TOPOLOGY_CONTROLLER_DELETE_GUEST_USER:
        delete_guest_user()

    live = set()
    for kind, handler, finalizer in HANDLERS:
        for obj in list_resources(kind):
            uid = obj.obj["metadata"]["uid"]
            live.add(uid)
            try:
                reconcile(obj, handler, finalizer)
                backoff.pop(uid, None)
            except Exception as error:
                delay = RABBITMQ_TOPOLOGY_CONTROLLER_ERROR_BACKOFF
                backoff[uid] = time.monotonic() + delay
                LOG.warning(
                    f"{obj.kind} {obj.name} failed, retrying in {delay}s: "
                    f"{error}"
                )
                LOG.debug("Reconcile traceback", exc_info=True)
                try:
                    set_ready(obj, "False", REASON_FAILURE, str(error))
                except Exception:
                    LOG.exception(f"Could not set status on {obj.name}")

    # Resources deleted while the controller was not looking would otherwise
    # leak an entry in each cache for the lifetime of the process.
    for cache in (applied, backoff, unserved):
        for uid in set(cache) - live:
            cache.pop(uid, None)


def main():
    while True:
        try:
            sweep()
        except Exception:
            # A sweep must never take the controller down: the most likely
            # cause is the broker being briefly unavailable.
            LOG.exception("Reconcile sweep failed")
        if RABBITMQ_TOPOLOGY_CONTROLLER_ONESHOT:
            LOG.info("Oneshot mode, exiting after a single sweep")
            return
        LOG.debug(f"Sleeping for {RABBITMQ_TOPOLOGY_CONTROLLER_RECONCILE_INTERVAL}")
        time.sleep(RABBITMQ_TOPOLOGY_CONTROLLER_RECONCILE_INTERVAL)


main()
