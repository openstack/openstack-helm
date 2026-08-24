#!/usr/bin/env python3

"""
Keystone identity controller

Reconciles the Domain, Project, Role, Group, User, RoleAssignment, Service
and Endpoint custom resources shipped by this chart against the Keystone this
chart deploys. It replaces the per-chart ks-service, ks-user and ks-endpoints
jobs, so the administrative credentials stay in the chart that owns Keystone
instead of being copied into every chart that owns a catalog entry.

Every operation is idempotent -- find it, patch it if a field drifted, create
it if absent -- so a full sweep can run repeatedly without side effects.

Progress is reported the way the mariadb and rabbitmq controllers report it,
as a metav1.Condition of type Ready in status.conditions, so kubectl wait
--for=condition=Ready works. The reason is Reconciled or ReconcileError. A
resource whose spec.keystoneRef.name names another deployment is left entirely
alone, status included: status belongs to whichever controller serves a
resource.

Kubernetes is reached with the official kubernetes client and Keystone with
openstacksdk. Both are installed on the openstack-client image this runs on.
openstacksdk builds its auth plugin from the environment, so the credentials
the deployment passes work whether they are a password or another plugin, and
its identity proxy returns typed resources instead of raw responses.

Env variables:
IDENTITY_CONTROLLER_DEBUG: Flag to enable debug when set to 1.
IDENTITY_CONTROLLER_NAMESPACE: The namespace to watch for resources in.
IDENTITY_CONTROLLER_API_GROUP: The API group of the custom resources.
IDENTITY_CONTROLLER_RECONCILE_INTERVAL: Delay between reconcile sweeps.
IDENTITY_CONTROLLER_FULL_RESYNC_INTERVAL: How often to re-apply resources whose
    desired state has not changed, repairing drift caused by changes made
    outside the controller.
IDENTITY_CONTROLLER_ERROR_BACKOFF: Fallback retry delay for a failing resource
    that does not set spec.retryInterval.
IDENTITY_CONTROLLER_REQUEST_TIMEOUT: Http timeout, for both APIs.
IDENTITY_CONTROLLER_ONESHOT: Run a single sweep and exit when set to 1.
IDENTITY_CONTROLLER_KEYSTONE_REF_NAME: The Keystone this controller answers
    for. A resource whose spec.keystoneRef.name is set and differs is left
    untouched, so this controller can coexist with another one.
OS_*: the administrative credentials, from this chart's own
    keystone-keystone-admin secret. openstacksdk reads them from the
    environment, including OS_AUTH_TYPE and OS_CACERT, so an alternative
    keystoneauth plugin configured through identity.openrc is honoured.

Changelog:
0.1.0: Initial version
"""


import base64
import hashlib
import json
import logging
import os
import re
import sys
import time

import openstack
from keystoneauth1 import exceptions as ks_exceptions
from kubernetes import client as k8s_client
from kubernetes import config as k8s_config
from kubernetes.client.rest import ApiException

IDENTITY_CONTROLLER_DEBUG = os.getenv("IDENTITY_CONTROLLER_DEBUG")
IDENTITY_CONTROLLER_NAMESPACE = os.getenv(
    "IDENTITY_CONTROLLER_NAMESPACE", "openstack"
)
IDENTITY_CONTROLLER_API_GROUP = os.getenv(
    "IDENTITY_CONTROLLER_API_GROUP", "keystone.osh.openstack.org"
)
IDENTITY_CONTROLLER_RECONCILE_INTERVAL = int(
    os.getenv("IDENTITY_CONTROLLER_RECONCILE_INTERVAL", 10)
)
IDENTITY_CONTROLLER_FULL_RESYNC_INTERVAL = int(
    os.getenv("IDENTITY_CONTROLLER_FULL_RESYNC_INTERVAL", 1800)
)
IDENTITY_CONTROLLER_ERROR_BACKOFF = int(
    os.getenv("IDENTITY_CONTROLLER_ERROR_BACKOFF", 10)
)
IDENTITY_CONTROLLER_REQUEST_TIMEOUT = int(
    os.getenv("IDENTITY_CONTROLLER_REQUEST_TIMEOUT", 60)
)
IDENTITY_CONTROLLER_ONESHOT = os.getenv("IDENTITY_CONTROLLER_ONESHOT")
IDENTITY_CONTROLLER_KEYSTONE_REF_NAME = os.getenv(
    "IDENTITY_CONTROLLER_KEYSTONE_REF_NAME", "keystone"
)

API_VERSION = f"{IDENTITY_CONTROLLER_API_GROUP}/v1alpha1"
FINALIZER = f"{IDENTITY_CONTROLLER_API_GROUP}/finalizer"

# The API server needs a merge patch. Recent kubernetes clients select that
# by default for a custom object, but the content type is named explicitly so
# a client whose default changes fails loudly rather than sending the wrong
# document.
MERGE_PATCH = "application/merge-patch+json"

READY_CONDITION = "Ready"
REASON_RECONCILED = "Reconciled"
REASON_ERROR = "ReconcileError"

log_level = "DEBUG" if IDENTITY_CONTROLLER_DEBUG else "INFO"
logging.basicConfig(
    stream=sys.stdout,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
LOG = logging.getLogger("identity-controller")
LOG.setLevel(log_level)

# Every error either API can raise, so that one resource failing is reported
# in its own status instead of ending the sweep.
API_ERRORS = (openstack.exceptions.SDKException, ApiException)


class ReconcileError(Exception):
    """A resource could not be reconciled and should be retried."""


def utcnow():
    return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())


# ---------------------------------------------------------------------------
# Kubernetes access
# ---------------------------------------------------------------------------


class Kubernetes(object):
    def __init__(self):
        # Reads the pod's service account token and CA, and refreshes the
        # token from disk as kubelet rotates it.
        k8s_config.load_incluster_config()
        self.namespace = IDENTITY_CONTROLLER_NAMESPACE
        self.group, self.version = API_VERSION.split("/")
        self.custom = k8s_client.CustomObjectsApi()
        self.core = k8s_client.CoreV1Api()
        # A patch has to be sent as a merge patch, or the API server reads the
        # body as a JSON patch and rejects it. The keyword that forces the
        # content type cannot be used: kubernetes 35 rejects _content_type on
        # these calls and 36 accepts it, and the image carries whichever one
        # upper-constraints pins. A default header works on both, because the
        # client applies its defaults over the content type it chose for
        # itself, so patching gets a client of its own that carries nothing
        # else.
        patch_client = k8s_client.ApiClient()
        patch_client.set_default_header("Content-Type", MERGE_PATCH)
        self.custom_patch = k8s_client.CustomObjectsApi(patch_client)
        LOG.info(f"Created k8s api client for namespace {self.namespace}")

    def list(self, plural):
        """List resources of a kind, tolerating the definition being absent."""
        try:
            listing = self.custom.list_namespaced_custom_object(
                self.group,
                self.version,
                self.namespace,
                plural,
                _request_timeout=IDENTITY_CONTROLLER_REQUEST_TIMEOUT,
            )
        except ApiException as error:
            if error.status == 404:
                LOG.warning(f"Definition for {plural} is not installed")
                return []
            raise
        return listing.get("items", [])

    def patch_status(self, plural, name, status):
        return self._patch(
            plural,
            name,
            dict(status=status),
            self.custom_patch.patch_namespaced_custom_object_status,
        )

    def patch_metadata(self, plural, name, metadata):
        return self._patch(
            plural,
            name,
            dict(metadata=metadata),
            self.custom_patch.patch_namespaced_custom_object,
        )

    def _patch(self, plural, name, body, call):
        try:
            return call(
                self.group,
                self.version,
                self.namespace,
                plural,
                name,
                body,
                _request_timeout=IDENTITY_CONTROLLER_REQUEST_TIMEOUT,
            )
        except ApiException as error:
            # The resource went away between the listing and the patch, which
            # is not an error: the next sweep will not see it either.
            if error.status == 404:
                LOG.debug(f"{plural}/{name} is gone, skipping patch")
                return None
            raise

    def secret_key(self, name, key):
        """Read one key out of a secret in the watched namespace."""
        try:
            secret = self.core.read_namespaced_secret(
                name,
                self.namespace,
                _request_timeout=IDENTITY_CONTROLLER_REQUEST_TIMEOUT,
            )
        except ApiException as error:
            if error.status == 404:
                raise ReconcileError(f"secret {name} does not exist")
            raise
        data = secret.data or {}
        if key not in data:
            raise ReconcileError(f"secret {name} has no key {key}")
        return base64.b64decode(data[key]).decode()


# ---------------------------------------------------------------------------
# Keystone access
# ---------------------------------------------------------------------------


class Keystone(object):
    def __init__(self):
        # openstacksdk builds its auth plugin from the OS_* environment, so an
        # alternative keystoneauth plugin configured through identity.openrc
        # is honoured without this controller naming a plugin.
        self.conn = openstack.connect()
        self.identity = self.conn.identity
        LOG.info(f"Created keystone client for {self.conn.config.name}")
        # Name to id cache, dropped at the start of every sweep so that an
        # object deleted out of band is looked up again.
        self.domain_ids = {}

    def domain_id(self, name):
        """Resolve a domain name to its id, caching within a sweep."""
        if name in self.domain_ids:
            return self.domain_ids[name]
        domain = find_one(self.identity.domains(name=name), f"domain {name}")
        if domain is None:
            raise ReconcileError(f"domain {name} does not exist")
        self.domain_ids[name] = domain.id
        return domain.id

    def ensure_region(self, region):
        """Create the region if it is absent.

        Done explicitly rather than relying on the Identity API creating a
        region implicitly when an endpoint names an unknown one, so the
        behaviour does not depend on the Keystone version underneath.
        """
        if self.identity.find_region(region, ignore_missing=True) is not None:
            return
        LOG.info(f"Creating region {region}")
        try:
            self.identity.create_region(id=region)
        except openstack.exceptions.ConflictException:
            # A concurrent creation is a success, not a conflict to report.
            pass

    def password_accepted(self, username, domain_id, password):
        """Whether the user can already authenticate with this password.

        Keystone invalidates every token a user holds on any password write,
        even a write of the same value, so the password is only set when this
        returns False. Note that a failed probe counts against
        [security_compliance] lockout_failure_attempts, which therefore has to
        tolerate one failure per password change.

        The token is requested through the session rather than through
        Connection.authorize, which flattens the status code into a message:
        this has to tell a rejected password from an unreachable Keystone,
        because writing the password on a network failure would invalidate
        every token the user holds for no reason.
        """
        probe = openstack.connect(
            load_yaml_config=False,
            load_envvars=False,
            auth_type="password",
            auth=dict(
                auth_url=os.environ["OS_AUTH_URL"],
                username=username,
                password=password,
                user_domain_id=domain_id,
            ),
            cacert=os.getenv("OS_CACERT"),
        )
        try:
            probe.session.get_token()
            return True
        except ks_exceptions.Unauthorized:
            return False
        except ks_exceptions.ClientException as error:
            raise ReconcileError(f"password probe failed: {error}")
        finally:
            probe.close()


def find_one(resources, what):
    """Consume a resource generator that must yield at most one object."""
    found = list(resources)
    if not found:
        return None
    if len(found) > 1:
        raise ReconcileError(
            f"{len(found)} objects match {what}, expected one"
        )
    return found[0]


def drift(existing, desired):
    """The part of desired that the existing resource does not already have."""
    return dict(
        (key, value)
        for key, value in desired.items()
        if getattr(existing, key, None) != value
    )


def described(spec, desired):
    """Copy the optional descriptive fields a spec carries into desired."""
    for field in ("description", "email"):
        if field in spec:
            desired[field] = spec[field]
    return desired


# ---------------------------------------------------------------------------
# Handlers
#
# One per kind. reconcile() returns a message for the Ready condition and the
# extra status fields to record; remove() deletes the Keystone object, and is
# only ever called for a resource whose deletionPolicy is delete.
# ---------------------------------------------------------------------------


class Handler(object):
    kind = None
    plural = None

    def __init__(self, k8s, keystone):
        self.k8s = k8s
        self.keystone = keystone

    @property
    def identity(self):
        return self.keystone.identity

    def hash_extras(self, spec):
        """State outside the spec that the desired-state hash must cover."""
        return []

    def reconcile(self, spec):
        raise NotImplementedError

    def remove(self, spec, status):
        raise NotImplementedError


class DomainHandler(Handler):
    kind = "Domain"
    plural = "domains"

    def _find(self, spec):
        name = spec["name"]
        return find_one(self.identity.domains(name=name), f"domain {name}")

    def reconcile(self, spec):
        name = spec["name"]
        desired = described(
            spec, dict(name=name, is_enabled=spec.get("enabled", True))
        )
        existing = self._find(spec)
        if existing is None:
            created = self.identity.create_domain(**desired)
            return f"created domain {name}", dict(domainID=created.id)
        changed = drift(existing, desired)
        if changed:
            self.identity.update_domain(existing.id, **changed)
            message = f"updated domain {name}: {', '.join(sorted(changed))}"
        else:
            message = f"domain {name} is up to date"
        return message, dict(domainID=existing.id)

    def remove(self, spec, status):
        domain = self._find(spec)
        if domain is None:
            return
        # Keystone refuses to delete an enabled domain.
        self.identity.update_domain(domain.id, is_enabled=False)
        self.identity.delete_domain(domain.id, ignore_missing=True)


class ProjectHandler(Handler):
    kind = "Project"
    plural = "projects"

    def _find(self, spec, domain_id):
        name = spec["name"]
        return find_one(
            self.identity.projects(name=name, domain_id=domain_id),
            f"project {name}",
        )

    def reconcile(self, spec):
        name = spec["name"]
        domain_name = spec.get("domain", "Default")
        domain_id = self.keystone.domain_id(domain_name)
        desired = described(
            spec,
            dict(
                name=name,
                domain_id=domain_id,
                is_enabled=spec.get("enabled", True),
            ),
        )
        existing = self._find(spec, domain_id)
        if existing is None:
            created = self.identity.create_project(**desired)
            return (
                f"created project {name} in domain {domain_name}",
                dict(projectID=created.id),
            )
        changed = drift(existing, desired)
        # domain_id identifies the project rather than describing it, so a
        # move is not something to patch.
        changed.pop("domain_id", None)
        if changed:
            self.identity.update_project(existing.id, **changed)
            message = f"updated project {name}: {', '.join(sorted(changed))}"
        else:
            message = f"project {name} in domain {domain_name} is up to date"
        return message, dict(projectID=existing.id)

    def remove(self, spec, status):
        domain_id = self.keystone.domain_id(spec.get("domain", "Default"))
        project = self._find(spec, domain_id)
        if project is not None:
            self.identity.delete_project(project.id, ignore_missing=True)


class RoleHandler(Handler):
    kind = "Role"
    plural = "roles"

    def _query(self, spec):
        query = dict(name=spec["name"])
        if spec.get("domain"):
            query["domain_id"] = self.keystone.domain_id(spec["domain"])
        return query

    def reconcile(self, spec):
        name = spec["name"]
        query = self._query(spec)
        existing = find_one(self.identity.roles(**query), f"role {name}")
        if existing is None:
            created = self.identity.create_role(**query)
            return f"created role {name}", dict(roleID=created.id)
        # A role is its name and its domain; there is nothing else to patch.
        return f"role {name} is up to date", dict(roleID=existing.id)

    def remove(self, spec, status):
        query = self._query(spec)
        role = find_one(self.identity.roles(**query), f"role {spec['name']}")
        if role is not None:
            self.identity.delete_role(role.id, ignore_missing=True)


class GroupHandler(Handler):
    kind = "Group"
    plural = "groups"

    def _find(self, spec, domain_id):
        name = spec["name"]
        return find_one(
            self.identity.groups(name=name, domain_id=domain_id),
            f"group {name}",
        )

    def reconcile(self, spec):
        name = spec["name"]
        domain_name = spec.get("domain", "Default")
        domain_id = self.keystone.domain_id(domain_name)
        desired = described(spec, dict(name=name, domain_id=domain_id))
        existing = self._find(spec, domain_id)
        if existing is None:
            created = self.identity.create_group(**desired)
            return (
                f"created group {name} in domain {domain_name}",
                dict(groupID=created.id),
            )
        changed = drift(existing, desired)
        changed.pop("domain_id", None)
        if changed:
            self.identity.update_group(existing.id, **changed)
            message = f"updated group {name}: {', '.join(sorted(changed))}"
        else:
            message = f"group {name} in domain {domain_name} is up to date"
        return message, dict(groupID=existing.id)

    def remove(self, spec, status):
        domain_id = self.keystone.domain_id(spec.get("domain", "Default"))
        group = self._find(spec, domain_id)
        if group is not None:
            self.identity.delete_group(group.id, ignore_missing=True)


class UserHandler(Handler):
    kind = "User"
    plural = "users"

    def _password(self, spec):
        secret = spec["passwordSecret"]
        return self.k8s.secret_key(
            secret["name"], secret.get("key", "OS_PASSWORD")
        )

    def _find(self, spec, domain_id):
        name = spec["name"]
        return find_one(
            self.identity.users(name=name, domain_id=domain_id),
            f"user {name}",
        )

    def hash_extras(self, spec):
        # The password lives in a secret, so rotating it changes nothing in
        # the spec. Hashing it here is what makes the rotation reconcile.
        return [self._password(spec)]

    def reconcile(self, spec):
        name = spec["name"]
        domain_name = spec.get("domain", "Default")
        domain_id = self.keystone.domain_id(domain_name)
        password = self._password(spec)
        desired = described(
            spec,
            dict(
                name=name,
                domain_id=domain_id,
                is_enabled=spec.get("enabled", True),
            ),
        )
        if spec.get("defaultProject"):
            project = spec["defaultProject"]
            project_domain_id = self.keystone.domain_id(
                project.get("domain", "Default")
            )
            found = find_one(
                self.identity.projects(
                    name=project["name"], domain_id=project_domain_id
                ),
                f"project {project['name']}",
            )
            if found is None:
                raise ReconcileError(
                    f"default project {project['name']} does not exist"
                )
            desired["default_project_id"] = found.id

        existing = self._find(spec, domain_id)
        if existing is None:
            created = self.identity.create_user(password=password, **desired)
            return (
                f"created user {name} in domain {domain_name}",
                dict(userID=created.id),
            )

        notes = []
        changed = drift(existing, desired)
        changed.pop("domain_id", None)
        if changed:
            self.identity.update_user(existing.id, **changed)
            notes.append(f"updated {', '.join(sorted(changed))}")
        if self.keystone.password_accepted(name, domain_id, password):
            notes.append("password unchanged")
        else:
            self.identity.update_user(existing.id, password=password)
            notes.append("password set")
        return (
            f"user {name} in domain {domain_name}: {', '.join(notes)}",
            dict(userID=existing.id),
        )

    def remove(self, spec, status):
        domain_id = self.keystone.domain_id(spec.get("domain", "Default"))
        user = self._find(spec, domain_id)
        if user is not None:
            self.identity.delete_user(user.id, ignore_missing=True)


class RoleAssignmentHandler(Handler):
    kind = "RoleAssignment"
    plural = "roleassignments"

    # The proxy has one method per scope and subject combination, which is
    # what the four entries here select between.
    ASSIGN = {
        ("project", "user"): "assign_project_role_to_user",
        ("project", "group"): "assign_project_role_to_group",
        ("domain", "user"): "assign_domain_role_to_user",
        ("domain", "group"): "assign_domain_role_to_group",
    }
    UNASSIGN = {
        ("project", "user"): "unassign_project_role_from_user",
        ("project", "group"): "unassign_project_role_from_group",
        ("domain", "user"): "unassign_domain_role_from_user",
        ("domain", "group"): "unassign_domain_role_from_group",
    }

    def _resolve(self, spec):
        role_spec = spec["role"]
        query = dict(name=role_spec["name"])
        if role_spec.get("domain"):
            query["domain_id"] = self.keystone.domain_id(role_spec["domain"])
        role = find_one(
            self.identity.roles(**query), f"role {role_spec['name']}"
        )
        if role is None:
            raise ReconcileError(f"role {role_spec['name']} does not exist")

        # Exactly one of user and group, enforced by the definition. A group
        # is what a federated deployment grants to: identities arrive as
        # shadow users and are mapped into groups, so there is no user to name.
        subject_kind = "user" if spec.get("user") else "group"
        subject_spec = spec[subject_kind]
        subject_domain_id = self.keystone.domain_id(
            subject_spec.get("domain", "Default")
        )
        lister = getattr(self.identity, f"{subject_kind}s")
        subject = find_one(
            lister(name=subject_spec["name"], domain_id=subject_domain_id),
            f"{subject_kind} {subject_spec['name']}",
        )
        if subject is None:
            raise ReconcileError(
                f"{subject_kind} {subject_spec['name']} does not exist"
            )

        if spec.get("project"):
            project_spec = spec["project"]
            project_domain_id = self.keystone.domain_id(
                project_spec.get("domain", "Default")
            )
            target = find_one(
                self.identity.projects(
                    name=project_spec["name"], domain_id=project_domain_id
                ),
                f"project {project_spec['name']}",
            )
            if target is None:
                raise ReconcileError(
                    f"project {project_spec['name']} does not exist"
                )
            scope_kind, scope_name = "project", project_spec["name"]
        else:
            domain_spec = spec["domain"]
            target = self.keystone.domain_id(domain_spec["name"])
            scope_kind, scope_name = "domain", domain_spec["name"]

        subject_name = f"{subject_kind} {subject_spec['name']}"
        scope = f"{scope_kind} {scope_name}"
        key = (scope_kind, subject_kind)
        return key, target, subject, role, subject_name, scope

    def reconcile(self, spec):
        key, target, subject, role, subject_name, scope = self._resolve(spec)
        # The assignment call is a PUT, so it is idempotent by construction:
        # granting a role that is already granted is the same request.
        getattr(self.identity, self.ASSIGN[key])(target, subject, role)
        return (
            f"granted {spec['role']['name']} to {subject_name} on {scope}",
            {},
        )

    def remove(self, spec, status):
        try:
            key, target, subject, role, _name, _scope = self._resolve(spec)
        except ReconcileError:
            # Whatever the assignment referred to is already gone.
            return
        getattr(self.identity, self.UNASSIGN[key])(target, subject, role)


def find_service(identity, name, service_type):
    """Find a catalog service by the pair that identifies it.

    The list call filters on type server side. The name is compared exactly on
    the parsed result rather than passed as a query parameter, because the
    Identity API documents no name filter for services.
    """
    matched = [
        service
        for service in identity.services(type=service_type)
        if service.name == name
    ]
    return find_one(matched, f"service {name} of type {service_type}")


class ServiceHandler(Handler):
    kind = "Service"
    plural = "services"

    def reconcile(self, spec):
        name = spec["name"]
        service_type = spec["type"]
        desired = described(
            spec,
            dict(
                name=name,
                type=service_type,
                is_enabled=spec.get("enabled", True),
            ),
        )
        existing = find_service(self.identity, name, service_type)
        if existing is None:
            created = self.identity.create_service(**desired)
            return (
                f"created service {name} of type {service_type}",
                dict(serviceID=created.id),
            )
        changed = drift(existing, desired)
        if changed:
            self.identity.update_service(existing.id, **changed)
            message = f"updated service {name}: {', '.join(sorted(changed))}"
        else:
            message = f"service {name} of type {service_type} is up to date"
        return message, dict(serviceID=existing.id)

    def remove(self, spec, status):
        service = find_service(self.identity, spec["name"], spec["type"])
        if service is not None:
            self.identity.delete_service(service.id, ignore_missing=True)


class EndpointHandler(Handler):
    kind = "Endpoint"
    plural = "endpoints"

    def reconcile(self, spec):
        service_spec = spec["service"]
        service = find_service(
            self.identity, service_spec["name"], service_spec["type"]
        )
        if service is None:
            raise ReconcileError(
                f"service {service_spec['name']} of type "
                f"{service_spec['type']} does not exist"
            )
        region = spec["region"]
        self.keystone.ensure_region(region)
        enabled = spec.get("enabled", True)

        endpoint_ids = {}
        notes = []
        for interface in ("admin", "internal", "public"):
            url = spec["urls"].get(interface)
            if not url:
                continue
            desired = dict(
                service_id=service.id,
                interface=interface,
                region_id=region,
                url=url,
                is_enabled=enabled,
            )
            existing = list(
                self.identity.endpoints(
                    service_id=service.id,
                    interface=interface,
                    region_id=region,
                )
            )
            if not existing:
                created = self.identity.create_endpoint(**desired)
                endpoint_ids[interface] = created.id
                notes.append(f"created {interface}")
                continue
            if len(existing) > 1:
                # Reported rather than corrected: deleting objects it did not
                # create is not something a controller should do quietly.
                extra = ", ".join(sorted(item.id for item in existing)[1:])
                notes.append(f"{interface} has duplicates ({extra})")
            adopted = sorted(existing, key=lambda item: item.id)[0]
            endpoint_ids[interface] = adopted.id
            changed = drift(adopted, desired)
            for identifying in ("service_id", "interface", "region_id"):
                changed.pop(identifying, None)
            if changed:
                # Patched rather than deleted and recreated, which is what the
                # ks-endpoints script does: the endpoint keeps its id.
                self.identity.update_endpoint(adopted.id, **changed)
                notes.append(f"updated {interface}")
            else:
                notes.append(f"{interface} is up to date")
        return (
            f"{service_spec['name']} in {region}: {', '.join(notes)}",
            dict(endpointIDs=endpoint_ids),
        )

    def remove(self, spec, status):
        for endpoint_id in (status.get("endpointIDs") or {}).values():
            self.identity.delete_endpoint(endpoint_id, ignore_missing=True)


# The sweep order. A project needs its domain, a role assignment needs the
# role, its subject -- a user or a group -- and the project, and an endpoint
# needs its service. Nothing reads another resource's status: Keystone is the
# source of truth, and a resource that fails because its dependency is not
# ready yet succeeds on a later sweep.
HANDLER_CLASSES = (
    DomainHandler,
    ProjectHandler,
    RoleHandler,
    GroupHandler,
    UserHandler,
    RoleAssignmentHandler,
    ServiceHandler,
    EndpointHandler,
)


# ---------------------------------------------------------------------------
# The reconcile loop
# ---------------------------------------------------------------------------


class Controller(object):
    def __init__(self):
        self.k8s = Kubernetes()
        self.keystone = Keystone()
        self.handlers = [
            klass(self.k8s, self.keystone) for klass in HANDLER_CLASSES
        ]
        # (kind, name) -> (generation, desired hash, when it was applied)
        self.applied = {}
        # (kind, name) -> when to try again after a failure
        self.retry_after = {}
        # Resources declined because they belong to another controller, logged
        # once each rather than once per sweep.
        self.declined = set()

    def desired_hash(self, handler, spec):
        payload = [json.dumps(spec, sort_keys=True)]
        payload.extend(handler.hash_extras(spec))
        digest = hashlib.sha256()
        for part in payload:
            digest.update(part.encode())
        return digest.hexdigest()

    def condition(self, obj, ready, reason, message):
        """Build the Ready condition, preserving lastTransitionTime.

        lastTransitionTime marks the last change of status, so a resync that
        only refreshes the message leaves it alone.
        """
        status = "True" if ready else "False"
        transitioned = utcnow()
        for existing in (obj.get("status") or {}).get("conditions") or []:
            if existing.get("type") != READY_CONDITION:
                continue
            if existing.get("status") == status:
                transitioned = existing.get("lastTransitionTime", transitioned)
            break
        return dict(
            type=READY_CONDITION,
            status=status,
            reason=reason,
            message=message[:32768],
            lastTransitionTime=transitioned,
            observedGeneration=obj["metadata"].get("generation", 0),
        )

    def report(self, handler, obj, ready, reason, message, extra=None):
        generation = obj["metadata"].get("generation", 0)
        status = dict(
            observedGeneration=generation,
            conditions=[self.condition(obj, ready, reason, message)],
        )
        if extra:
            status.update(extra)
        self.k8s.patch_status(handler.plural, obj["metadata"]["name"], status)

    def set_finalizer(self, handler, obj, present):
        finalizers = list(obj["metadata"].get("finalizers") or [])
        if present == (FINALIZER in finalizers):
            return
        if present:
            finalizers.append(FINALIZER)
        else:
            finalizers.remove(FINALIZER)
        self.k8s.patch_metadata(
            handler.plural,
            obj["metadata"]["name"],
            dict(finalizers=finalizers),
        )

    def owned(self, handler, obj):
        """Whether this controller serves the resource.

        A resource pointing at another Keystone is left entirely alone, status
        included: two controllers writing one object's status would overwrite
        each other every sweep. Its finalizer is the exception -- taking off
        this controller's own mark is cleanup, not a claim, and leaving it
        would make the resource undeletable.
        """
        ref = (obj["spec"].get("keystoneRef") or {}).get("name")
        if not ref or ref == IDENTITY_CONTROLLER_KEYSTONE_REF_NAME:
            return True
        key = (handler.kind, obj["metadata"]["name"])
        if key not in self.declined:
            self.declined.add(key)
            LOG.info(
                f"{handler.kind}/{obj['metadata']['name']} points at "
                f"keystone {ref}, not {IDENTITY_CONTROLLER_KEYSTONE_REF_NAME}"
                ": leaving it alone"
            )
        self.set_finalizer(handler, obj, False)
        return False

    def retry_interval(self, spec):
        return parse_duration(
            spec.get("retryInterval"), IDENTITY_CONTROLLER_ERROR_BACKOFF
        )

    def process(self, handler, obj):
        name = obj["metadata"]["name"]
        spec = obj.get("spec") or {}
        obj["spec"] = spec
        key = (handler.kind, name)
        if not self.owned(handler, obj):
            return
        self.declined.discard(key)
        delete_wanted = spec.get("deletionPolicy", "retain") == "delete"

        if obj["metadata"].get("deletionTimestamp"):
            if FINALIZER not in (obj["metadata"].get("finalizers") or []):
                return
            if delete_wanted:
                LOG.info(
                    f"Removing the keystone object for {handler.kind}/{name}"
                )
                handler.remove(spec, obj.get("status") or {})
            self.set_finalizer(handler, obj, False)
            self.applied.pop(key, None)
            self.retry_after.pop(key, None)
            return

        self.set_finalizer(handler, obj, delete_wanted)

        now = time.monotonic()
        deadline = self.retry_after.get(key)
        if deadline is not None and now < deadline:
            return

        generation = obj["metadata"].get("generation", 0)
        desired = self.desired_hash(handler, spec)
        previous = self.applied.get(key)
        if previous is not None:
            applied_generation, applied_hash, applied_at = previous
            unchanged = (
                applied_generation == generation and applied_hash == desired
            )
            fresh = (
                now - applied_at < IDENTITY_CONTROLLER_FULL_RESYNC_INTERVAL
            )
            if unchanged and fresh:
                return

        try:
            message, extra = handler.reconcile(spec)
        except (ReconcileError,) + API_ERRORS as error:
            LOG.warning(f"{handler.kind}/{name}: {error}")
            self.applied.pop(key, None)
            self.retry_after[key] = now + self.retry_interval(spec)
            self.report(handler, obj, False, REASON_ERROR, str(error))
            return
        LOG.info(f"{handler.kind}/{name}: {message}")
        self.applied[key] = (generation, desired, now)
        self.retry_after.pop(key, None)
        self.report(handler, obj, True, REASON_RECONCILED, message, extra)

    def sweep(self):
        # Dropped every sweep so that an object deleted out of band is looked
        # up again rather than served from a stale id.
        self.keystone.domain_ids = {}
        for handler in self.handlers:
            for obj in self.k8s.list(handler.plural):
                name = obj.get("metadata", {}).get("name", "?")
                try:
                    self.process(handler, obj)
                except (ReconcileError,) + API_ERRORS as error:
                    LOG.warning(f"{handler.kind}/{name}: {error}")
                except Exception as error:
                    LOG.exception(f"{handler.kind}/{name}: {error}")

    def run(self):
        while True:
            try:
                self.sweep()
            except Exception as error:
                LOG.exception(f"Reconcile sweep failed: {error}")
            if IDENTITY_CONTROLLER_ONESHOT:
                return
            time.sleep(IDENTITY_CONTROLLER_RECONCILE_INTERVAL)


def parse_duration(value, default):
    """Parse a Go style duration such as 5s or 1m30s into seconds."""
    if not value:
        return default
    units = dict(ns=1e-9, us=1e-6, ms=1e-3, s=1, m=60, h=3600)
    total = 0.0
    matched = False
    for amount, unit in re.findall(
        r"([0-9]+(?:\.[0-9]+)?)(ns|us|ms|s|m|h)", value
    ):
        total += float(amount) * units[unit]
        matched = True
    return total if matched else default


def main():
    while True:
        try:
            controller = Controller()
            break
        except Exception as error:
            # Keystone is normally not up yet on the first attempt.
            LOG.warning(f"Waiting to start: {error}")
            time.sleep(IDENTITY_CONTROLLER_RECONCILE_INTERVAL)
    controller.run()


if __name__ == "__main__":
    main()
