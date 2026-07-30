#!/usr/bin/env python3

"""
Mariadb database controller

Reconciles the Database, User, Grant and Connection custom resources shipped
by this chart against the MariaDB cluster the chart deploys. Every operation
is idempotent, so a full sweep can run repeatedly without side effects.

Progress is reported the way the upstream mariadb-operator reports it, as a
metav1.Condition of type Ready in status.conditions, so kubectl wait
--for=condition=Ready works. The reason is Reconciled, ReconcileError or
NotOwned. The custom resource definitions declare every field upstream accepts,
including those this controller does not implement; asking for one of those is
refused outright rather than ignored, so the Ready condition never claims
success for something that was quietly dropped.

Env variables:
MARIADB_DB_CONTROLLER_DEBUG: Flag to enable debug when set to 1.
MARIADB_DB_CONTROLLER_NAMESPACE: The namespace to watch for resources in.
MARIADB_DB_CONTROLLER_API_GROUP: The API group of the custom resources.
MARIADB_DB_CONTROLLER_RECONCILE_INTERVAL: Delay between reconcile sweeps.
MARIADB_DB_CONTROLLER_FULL_RESYNC_INTERVAL: How often to re-apply SQL for
    resources whose desired state has not changed, repairing drift caused by
    changes made outside the controller.
MARIADB_DB_CONTROLLER_ERROR_BACKOFF: Fallback retry delay for a failing
    resource that does not set spec.retryInterval.
MARIADB_DB_CONTROLLER_PYKUBE_REQUEST_TIMEOUT: Kubernetes http session timeout.
MARIADB_DB_CONTROLLER_DB_CONNECT_TIMEOUT: MariaDB connect timeout.
MARIADB_DB_CONTROLLER_DEFAULT_CHARACTER_SET: Character set for a Database
    resource that does not specify one.
MARIADB_DB_CONTROLLER_DEFAULT_COLLATE: Collation for a Database resource that
    does not specify one.
MARIADB_DB_CONTROLLER_ONESHOT: Run a single sweep and exit when set to 1.
MARIADB_DB_CONTROLLER_CLUSTER_DOMAIN: The cluster domain suffix used to expand
    a Connection spec.serviceName into a fully qualified host.
MARIADB_HOST: The MariaDB host to reconcile against.
MARIADB_PORT: The MariaDB port.
MARIADB_USER: The MariaDB administrative user.
MARIADB_PASSWORD: The MariaDB administrative password.
MARIADB_X509: When non empty, accounts are created with REQUIRE X509 unless
    the User resource says otherwise.
MARIADB_REF_NAME: The cluster name this controller answers for. A resource
    whose spec.mariaDbRef.name is set and differs is left untouched, so that
    this controller can coexist with the upstream mariadb-operator.

Changelog:
0.1.0: Initial version
"""


import base64
import configparser
import hashlib
import logging
import os
import re
import sys
import time
import urllib.parse

import pykube
import pymysql

MARIADB_DB_CONTROLLER_DEBUG = os.getenv("MARIADB_DB_CONTROLLER_DEBUG")
MARIADB_DB_CONTROLLER_NAMESPACE = os.getenv(
    "MARIADB_DB_CONTROLLER_NAMESPACE", "openstack"
)
MARIADB_DB_CONTROLLER_API_GROUP = os.getenv(
    "MARIADB_DB_CONTROLLER_API_GROUP", "mariadb.osh.openstack.org"
)
MARIADB_DB_CONTROLLER_RECONCILE_INTERVAL = int(
    os.getenv("MARIADB_DB_CONTROLLER_RECONCILE_INTERVAL", 10)
)
MARIADB_DB_CONTROLLER_FULL_RESYNC_INTERVAL = int(
    os.getenv("MARIADB_DB_CONTROLLER_FULL_RESYNC_INTERVAL", 1800)
)
MARIADB_DB_CONTROLLER_ERROR_BACKOFF = int(
    os.getenv("MARIADB_DB_CONTROLLER_ERROR_BACKOFF", 10)
)
MARIADB_DB_CONTROLLER_PYKUBE_REQUEST_TIMEOUT = int(
    os.getenv("MARIADB_DB_CONTROLLER_PYKUBE_REQUEST_TIMEOUT", 60)
)
MARIADB_DB_CONTROLLER_DB_CONNECT_TIMEOUT = int(
    os.getenv("MARIADB_DB_CONTROLLER_DB_CONNECT_TIMEOUT", 10)
)
MARIADB_DB_CONTROLLER_DEFAULT_CHARACTER_SET = os.getenv(
    "MARIADB_DB_CONTROLLER_DEFAULT_CHARACTER_SET", "utf8"
)
MARIADB_DB_CONTROLLER_DEFAULT_COLLATE = os.getenv(
    "MARIADB_DB_CONTROLLER_DEFAULT_COLLATE", "utf8_general_ci"
)
MARIADB_DB_CONTROLLER_ONESHOT = os.getenv("MARIADB_DB_CONTROLLER_ONESHOT")
MARIADB_DB_CONTROLLER_CLUSTER_DOMAIN = os.getenv(
    "MARIADB_DB_CONTROLLER_CLUSTER_DOMAIN", "cluster.local"
)
MARIADB_HOST = os.getenv("MARIADB_HOST", "mariadb")
MARIADB_PORT = int(os.getenv("MARIADB_PORT", 3306))
MARIADB_USER = os.getenv("MARIADB_USER", "root")
MARIADB_PASSWORD = os.getenv("MARIADB_PASSWORD", "")
MARIADB_X509 = os.getenv("MARIADB_X509", "")
MARIADB_REF_NAME = os.getenv("MARIADB_REF_NAME", "mariadb")
MARIADB_ADMIN_CNF = "/etc/mysql/admin_user.cnf"

API_VERSION = f"{MARIADB_DB_CONTROLLER_API_GROUP}/v1alpha1"
FINALIZER = f"{MARIADB_DB_CONTROLLER_API_GROUP}/finalizer"
CONNECTION_LABEL = f"{MARIADB_DB_CONTROLLER_API_GROUP}/connection"
DEFAULT_CREDS_KEY = "password"

READY_CONDITION = "Ready"
REASON_RECONCILED = "Reconciled"
REASON_ERROR = "ReconcileError"
REASON_NOT_OWNED = "NotOwned"

log_level = "DEBUG" if MARIADB_DB_CONTROLLER_DEBUG else "INFO"
logging.basicConfig(
    stream=sys.stdout,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
LOG = logging.getLogger("mariadb-db-controller")
LOG.setLevel(log_level)


class ReconcileError(Exception):
    """A resource could not be reconciled and should be retried."""


# ---------------------------------------------------------------------------
# Identifier and privilege validation
#
# pymysql interpolates client side, so cursor.execute(sql, args) is proper
# escaping for values. Identifiers and privilege keywords cannot be passed as
# parameters, so they are validated against these patterns and then quoted.
# Anything that does not match is rejected before any SQL is issued.
# ---------------------------------------------------------------------------

IDENTIFIER_RE = re.compile(r"^[A-Za-z0-9_$]{1,64}$")
USERNAME_RE = re.compile(r"^[A-Za-z0-9_$.-]{1,80}$")
HOSTNAME_RE = re.compile(r"^[A-Za-z0-9_%.:*-]{1,255}$")

ALLOWED_PRIVILEGES = frozenset(
    [
        "ALL",
        "ALL PRIVILEGES",
        "ALTER",
        "ALTER ROUTINE",
        "CREATE",
        "CREATE ROUTINE",
        "CREATE TEMPORARY TABLES",
        "CREATE VIEW",
        "DELETE",
        "DELETE HISTORY",
        "DROP",
        "EVENT",
        "EXECUTE",
        "INDEX",
        "INSERT",
        "LOCK TABLES",
        "PROCESS",
        "REFERENCES",
        "RELOAD",
        "REPLICATION CLIENT",
        "REPLICATION SLAVE",
        "SELECT",
        "SHOW DATABASES",
        "SHOW VIEW",
        "SLAVE MONITOR",
        "TRIGGER",
        "UPDATE",
        "USAGE",
    ]
)


def quote_identifier(value, what):
    """Validate then backtick-quote a database or table identifier."""
    if value == "*":
        return "*"
    if not value or not IDENTIFIER_RE.match(value):
        raise ReconcileError(f"invalid {what} identifier: {value!r}")
    return f"`{value}`"


def validate_account(username, host):
    """Validate the two halves of a MariaDB account name."""
    if not username or not USERNAME_RE.match(username):
        raise ReconcileError(f"invalid user name: {username!r}")
    if not host or not HOSTNAME_RE.match(host):
        raise ReconcileError(f"invalid user host: {host!r}")


def quote_account(username, host, parameterized=False):
    """Validate and quote a MariaDB account as 'user'@'host'.

    Set parameterized when the statement also carries bound parameters:
    pymysql then applies printf formatting to the whole query, so a literal
    percent -- which is the usual host wildcard -- has to be doubled or it is
    read as a format specifier.
    """
    validate_account(username, host)
    if parameterized:
        host = host.replace("%", "%%")
    return f"'{username}'@'{host}'"


def validate_privileges(privileges):
    """Validate privilege keywords against an explicit allowlist."""
    if not privileges:
        raise ReconcileError("no privileges given")
    result = []
    for privilege in privileges:
        normalized = " ".join(str(privilege).upper().split())
        if normalized not in ALLOWED_PRIVILEGES:
            raise ReconcileError(f"privilege not allowed: {privilege!r}")
        result.append(normalized)
    return result


def normalize_charset(value):
    """Fold MariaDB character set and collation aliases together.

    MariaDB reports the utf8 alias as utf8mb3 in information_schema, so a
    literal comparison against a requested utf8 would report drift on a
    database that was just created exactly as asked, and issue a pointless
    ALTER on every resync.
    """
    if not value:
        return ""
    return value.lower().replace("utf8mb3", "utf8")


def parse_duration(value, default):
    """Parse a Go style duration such as 5s or 1m30s into seconds."""
    if not value:
        return default
    total = 0.0
    matched = False
    units = {
        "ns": 1e-9,
        "us": 1e-6,
        "ms": 1e-3,
        "s": 1,
        "m": 60,
        "h": 3600,
    }
    for amount, unit in re.findall(r"([0-9]+(?:\.[0-9]+)?)(ns|us|ms|s|m|h)", value):
        total += float(amount) * units[unit]
        matched = True
    return total if matched else default


# ---------------------------------------------------------------------------
# Kubernetes access
# ---------------------------------------------------------------------------


def login():
    config = pykube.KubeConfig.from_env()
    client = pykube.HTTPClient(
        config=config, timeout=MARIADB_DB_CONTROLLER_PYKUBE_REQUEST_TIMEOUT
    )
    LOG.info(f"Created k8s api client from context {config.current_context}")
    return client


api = login()


def custom_resource_class(kind, plural):
    """Build a pykube object class for one of our kinds."""
    return type(
        kind,
        (pykube.objects.NamespacedAPIObject,),
        {"version": API_VERSION, "endpoint": plural, "kind": kind},
    )


Database = custom_resource_class("Database", "databases")
User = custom_resource_class("User", "users")
Grant = custom_resource_class("Grant", "grants")
Connection = custom_resource_class("Connection", "connections")


def list_resources(klass):
    """List resources of a kind, tolerating the CRD not being installed."""
    try:
        return list(
            klass.objects(api)
            .filter(namespace=MARIADB_DB_CONTROLLER_NAMESPACE)
            .iterator()
        )
    except pykube.exceptions.HTTPError as error:
        if error.code == 404:
            LOG.warning(f"CRD for {klass.kind} is not installed, skipping")
            return []
        raise


def read_secret_key(name, key):
    """Read and decode one key of a secret in the watched namespace."""
    try:
        secret = (
            pykube.Secret.objects(api)
            .filter(namespace=MARIADB_DB_CONTROLLER_NAMESPACE)
            .get(name=name)
        )
    except pykube.exceptions.ObjectDoesNotExist:
        raise ReconcileError(f"secret {name} does not exist")
    data = secret.obj.get("data") or {}
    if key not in data:
        raise ReconcileError(f"secret {name} has no key {key}")
    return base64.b64decode(data[key]).decode("utf-8")


def patch_status(obj, status):
    """Merge-patch the status subresource, falling back to a plain patch."""
    payload = {"status": status}
    try:
        obj.patch(payload, subresource="status")
    except TypeError:
        # Older pykube-ng has no subresource kwarg.
        obj.patch(payload)


def ready_message(obj):
    """The message on the current Ready condition, or an empty string."""
    for condition in (obj.obj.get("status") or {}).get("conditions") or []:
        if condition.get("type") == READY_CONDITION:
            return condition.get("message", "")
    return ""


def set_ready(obj, status, reason, message=""):
    """Write the Ready condition, but only when something actually changed.

    The status is a conditions list of the same shape the upstream operator
    writes, so kubectl wait --for=condition=Ready works and the printer
    columns select on it. Every field metav1.Condition requires is always
    populated: reason may not be empty, and the API server enforces it.
    """
    conditions = list((obj.obj.get("status") or {}).get("conditions") or [])
    generation = obj.obj["metadata"].get("generation")
    message = message[:512]

    current = None
    for index, condition in enumerate(conditions):
        if condition.get("type") == READY_CONDITION:
            current = (index, condition)
            break

    if current is not None:
        _, existing = current
        if (
            existing.get("status") == status
            and existing.get("reason") == reason
            and existing.get("message", "") == message
            and existing.get("observedGeneration") == generation
        ):
            return
        # lastTransitionTime marks the last change of status, not of the
        # message, so a resync that only refreshes the reason must keep it.
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
    if generation is not None:
        ready["observedGeneration"] = generation

    # Other condition types are not written by this controller, but a resource
    # it took over from another writer may carry some. Leave them alone.
    if current is None:
        conditions.append(ready)
    else:
        conditions[current[0]] = ready
    patch_status(obj, {"conditions": conditions})


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
# MariaDB access
# ---------------------------------------------------------------------------


def client_tls_options():
    """TLS material for a client connection, read from the administrative cnf.

    The cnf gains ssl-ca, ssl-key and ssl-cert when the chart is deployed with
    certificates, and the same files are mounted into this pod, so there is no
    second place to configure mutual TLS.

    A Connection is verified as the service account rather than as the
    administrator, but the certificate presented is this controller's. That is
    what REQUIRE X509 asks for -- a valid certificate, not a particular subject
    or issuer -- and require.subject and require.issuer, which would pin those,
    are refused by this controller.

    Returned as kwargs so that a deployment without certificates passes
    nothing at all rather than an empty ssl argument.
    """
    if not os.path.exists(MARIADB_ADMIN_CNF):
        return {}
    parser = configparser.RawConfigParser()
    try:
        parser.read(MARIADB_ADMIN_CNF)
    except configparser.Error as error:
        LOG.warning(f"Could not parse {MARIADB_ADMIN_CNF}: {error}")
        return {}
    ssl = {}
    for option, key in (("ssl-ca", "ca"), ("ssl-cert", "cert"), ("ssl-key", "key")):
        if parser.has_option("client", option):
            value = parser.get("client", option).strip()
            if value:
                ssl[key] = value
    if not ssl:
        return {}
    # The connection strings this controller writes carry ssl_verify_cert and
    # not ssl_verify_identity, so services verify the chain and not the
    # hostname. pymysql would check the hostname as soon as a CA is given,
    # which would make this check stricter than the connection it certifies:
    # a certificate without a SAN for the endpoint a Connection names would
    # fail here while every service using it worked.
    ssl["check_hostname"] = False
    return {"ssl": ssl}


class Sql:
    """A lazily established administrative connection to MariaDB."""

    def __init__(self):
        self._connection = None

    def _connect(self):
        kwargs = {
            "host": MARIADB_HOST,
            "port": MARIADB_PORT,
            "user": MARIADB_USER,
            "password": MARIADB_PASSWORD,
            "connect_timeout": MARIADB_DB_CONTROLLER_DB_CONNECT_TIMEOUT,
            "autocommit": True,
        }
        if os.path.exists(MARIADB_ADMIN_CNF):
            # The cnf carries the ssl-ca, ssl-key and ssl-cert settings when
            # the chart is deployed with TLS, so mutual TLS needs no extra
            # handling here. Explicit kwargs above still win.
            kwargs["read_default_file"] = MARIADB_ADMIN_CNF
        LOG.info(f"Connecting to MariaDB at {MARIADB_HOST}:{MARIADB_PORT}")
        return pymysql.connect(**kwargs)

    def connection(self):
        if self._connection is not None:
            try:
                # reconnect=False: pymysql deprecated reconnecting from ping,
                # and a fresh connection is established below anyway.
                self._connection.ping(reconnect=False)
                return self._connection
            except Exception as error:
                LOG.warning(f"Dropping unusable MariaDB connection: {error}")
                self._connection = None
        self._connection = self._connect()
        return self._connection

    def execute(self, statement, args=None):
        LOG.debug(f"Executing: {statement}")
        with self.connection().cursor() as cursor:
            cursor.execute(statement, args)

    def query(self, statement, args=None):
        with self.connection().cursor() as cursor:
            cursor.execute(statement, args)
            return cursor.fetchall()

    def close(self):
        if self._connection is not None:
            try:
                self._connection.close()
            except Exception as error:
                LOG.debug(f"Ignoring error while closing connection: {error}")
            self._connection = None


sql = Sql()


# ---------------------------------------------------------------------------
# Reconcilers
# ---------------------------------------------------------------------------


def object_name(obj, spec):
    """The MariaDB object name: spec.name, or metadata.name as a fallback."""
    return spec.get("name") or obj.name


def reconcile_database(obj, spec):
    name = object_name(obj, spec)
    quoted = quote_identifier(name, "database")
    character_set = (
        spec.get("characterSet") or MARIADB_DB_CONTROLLER_DEFAULT_CHARACTER_SET
    )
    collate = spec.get("collate") or MARIADB_DB_CONTROLLER_DEFAULT_COLLATE
    if not IDENTIFIER_RE.match(character_set) or not IDENTIFIER_RE.match(collate):
        raise ReconcileError(
            f"invalid character set or collation: {character_set}/{collate}"
        )
    sql.execute(
        # Identifiers are validated above and cannot be bound as params.
        f"CREATE DATABASE IF NOT EXISTS {quoted} "
        f"CHARACTER SET {character_set} COLLATE {collate}"
    )
    rows = sql.query(
        "SELECT default_character_set_name, default_collation_name "
        "FROM information_schema.SCHEMATA WHERE schema_name = %s",
        (name,),
    )
    drifted = rows and (
        normalize_charset(rows[0][0]) != normalize_charset(character_set)
        or normalize_charset(rows[0][1]) != normalize_charset(collate)
    )
    if drifted:
        LOG.info(
            f"Database {name} is {rows[0][0]}/{rows[0][1]}, altering to "
            f"{character_set}/{collate}"
        )
        sql.execute(
            # Identifiers are validated above and cannot be bound as params.
            f"ALTER DATABASE {quoted} "
            f"CHARACTER SET {character_set} COLLATE {collate}"
        )
    return f"database {name} is present"


def finalize_database(obj, spec):
    name = object_name(obj, spec)
    LOG.info(f"Dropping database {name} per cleanupPolicy Delete")
    # Identifier is validated by quote_identifier.
    sql.execute(f"DROP DATABASE IF EXISTS {quote_identifier(name, 'database')}")


def user_password(spec):
    """Return (password, is_hash) for a User resource."""
    plain_ref = spec.get("passwordSecretKeyRef")
    hash_ref = spec.get("passwordHashSecretKeyRef")
    if plain_ref and hash_ref:
        raise ReconcileError(
            "passwordSecretKeyRef and passwordHashSecretKeyRef "
            "are mutually exclusive"
        )
    if plain_ref:
        key = plain_ref.get("key") or DEFAULT_CREDS_KEY
        return read_secret_key(plain_ref["name"], key), False
    if hash_ref:
        key = hash_ref.get("key") or DEFAULT_CREDS_KEY
        return read_secret_key(hash_ref["name"], key), True
    raise ReconcileError("no password reference given")


def reconcile_user(obj, spec):
    name = object_name(obj, spec)
    host = spec.get("host") or "%"
    password, is_hash = user_password(spec)

    identified = "IDENTIFIED BY PASSWORD %s" if is_hash else "IDENTIFIED BY %s"
    requirements = ""
    require = spec.get("require") or {}
    x509 = require.get("x509")
    if x509 is None:
        x509 = bool(MARIADB_X509)
    if x509:
        requirements = " REQUIRE X509"
    options = ""
    max_connections = spec.get("maxUserConnections")
    if max_connections:
        options = f" WITH MAX_USER_CONNECTIONS {int(max_connections)}"

    # Both statements bind the password, so the account is quoted for a
    # parameterized query and its host wildcard is percent-escaped.
    account = quote_account(name, host, parameterized=True)
    sql.execute(
        # The account is validated by quote_account, the password is bound as
        # a parameter, and the rest are fixed keywords.
        f"CREATE USER IF NOT EXISTS {account} {identified}"
        f"{requirements}{options}",
        (password,),
    )
    # Unconditional: this is the password rotation and privilege-option drift
    # path. Callers only reach it when the desired state hash changed or on a
    # full resync, so it is not issued on every sweep.
    sql.execute(
        # See the CREATE USER above.
        f"ALTER USER {account} {identified}{requirements}{options}",
        (password,),
    )
    return f"user {name}@{host} is present"


def finalize_user(obj, spec):
    name = object_name(obj, spec)
    host = spec.get("host") or "%"
    LOG.info(f"Dropping user {name}@{host} per cleanupPolicy Delete")
    # No bound parameters here, so the host wildcard needs no escaping.
    sql.execute(f"DROP USER IF EXISTS {quote_account(name, host)}")


def grant_target(spec):
    """Return the validated (privileges, target, account) of a Grant."""
    privileges = validate_privileges(spec.get("privileges") or [])
    database = spec.get("database") or "*"
    table = spec.get("table") or "*"
    username = spec.get("username")
    host = spec.get("host") or "%"
    target = (
        f"{quote_identifier(database, 'database')}."
        f"{quote_identifier(table, 'table')}"
    )
    # Neither GRANT nor REVOKE binds parameters, so no percent escaping.
    return privileges, target, quote_account(username, host)


def reconcile_grant(obj, spec):
    privileges, target, account = grant_target(spec)
    option = " WITH GRANT OPTION" if spec.get("grantOption") else ""
    sql.execute(
        # Privileges come from an allowlist, identifiers are validated and
        # quoted, and the account is validated.
        f"GRANT {', '.join(privileges)} ON {target} TO {account}{option}"
    )
    return f"granted {', '.join(privileges)} on {target} to {account}"


def finalize_grant(obj, spec):
    privileges, target, account = grant_target(spec)
    LOG.info(f"Revoking {privileges} on {target} from {account}")
    sql.execute(
        # See reconcile_grant.
        f"REVOKE IF EXISTS {', '.join(privileges)} ON {target} FROM {account}"
    )


# The Go template subset understood in Connection.spec.secretTemplate.format.
# Written with escaped braces so that this file, which is itself rendered as a
# Helm template, contains no bare opening double brace.
TEMPLATE_RE = re.compile(r"\{\{\-?\s*\.([A-Za-z_][A-Za-z0-9_]*)\s*\-?\}\}")


def render_format(template, context):
    """Render the Go template subset used by secretTemplate.format."""

    def substitute(match):
        key = match.group(1)
        if key not in context:
            raise ReconcileError(
                f"unknown secretTemplate.format key .{key}, "
                f"known keys are {', '.join(sorted(context))}"
            )
        return context[key]

    return TEMPLATE_RE.sub(substitute, template)


def connection_context(spec):
    """Build the substitution context for a Connection resource."""
    username = spec.get("username")
    password_ref = spec.get("passwordSecretKeyRef") or {}
    if not password_ref.get("name"):
        raise ReconcileError("passwordSecretKeyRef.name is required")
    password = read_secret_key(
        password_ref["name"], password_ref.get("key") or DEFAULT_CREDS_KEY
    )
    database = spec.get("database") or ""
    host = spec.get("host")
    if not host:
        service_name = spec.get("serviceName")
        if service_name:
            host = (
                f"{service_name}.{MARIADB_DB_CONTROLLER_NAMESPACE}"
                f".svc.{MARIADB_DB_CONTROLLER_CLUSTER_DOMAIN}"
            )
        else:
            host = MARIADB_HOST
    port = spec.get("port") or MARIADB_PORT
    params = spec.get("params") or {}
    if params:
        query = "?" + urllib.parse.urlencode(sorted(params.items()))
    else:
        query = ""
    quote = urllib.parse.quote
    return {
        "Username": username,
        "Password": password,
        "Host": host,
        "Port": str(port),
        "Database": database,
        "Params": query,
        "UsernameEncoded": quote(username, safe=""),
        "PasswordEncoded": quote(password, safe=""),
    }


def connection_secret_data(spec, context):
    """Build the data mapping for the secret a Connection materializes."""
    template = spec.get("secretTemplate") or {}
    data = {}
    key_fields = (
        ("usernameKey", "Username"),
        ("passwordKey", "Password"),
        ("hostKey", "Host"),
        ("portKey", "Port"),
        ("databaseKey", "Database"),
        ("paramsKey", "Params"),
    )
    for field, context_key in key_fields:
        name = template.get(field)
        if name:
            data[name] = context[context_key]
    template_format = template.get("format")
    if template_format:
        key = template.get("key")
        if not key:
            raise ReconcileError("secretTemplate.key is required with format")
        data[key] = render_format(template_format, context)
    if not data:
        raise ReconcileError(
            "secretTemplate must set format or at least one of the "
            "usernameKey/passwordKey/hostKey/portKey/databaseKey/paramsKey "
            "fields"
        )
    return data


def owner_reference(obj):
    return {
        "apiVersion": API_VERSION,
        "kind": obj.kind,
        "name": obj.name,
        "uid": obj.obj["metadata"]["uid"],
        "controller": True,
        "blockOwnerDeletion": False,
    }


def apply_connection_secret(obj, spec, data):
    """Create or update the secret, only writing when the content changed."""
    name = spec.get("secretName") or obj.name
    template = spec.get("secretTemplate") or {}
    metadata = template.get("metadata") or {}
    labels = dict(metadata.get("labels") or {})
    labels.update({"application": "mariadb", "component": "db-connection"})
    labels[CONNECTION_LABEL] = obj.name
    encoded = {
        key: base64.b64encode(value.encode("utf-8")).decode("ascii")
        for key, value in data.items()
    }
    body = {
        "apiVersion": "v1",
        "kind": "Secret",
        "type": "Opaque",
        "metadata": {
            "name": name,
            "namespace": MARIADB_DB_CONTROLLER_NAMESPACE,
            "labels": labels,
            "annotations": dict(metadata.get("annotations") or {}),
            "ownerReferences": [owner_reference(obj)],
        },
        "data": encoded,
    }
    try:
        secret = (
            pykube.Secret.objects(api)
            .filter(namespace=MARIADB_DB_CONTROLLER_NAMESPACE)
            .get(name=name)
        )
    except pykube.exceptions.ObjectDoesNotExist:
        pykube.Secret(api, body).create()
        LOG.info(f"Created connection secret {name}")
        return name
    if (secret.obj.get("data") or {}) == encoded:
        LOG.debug(f"Connection secret {name} is up to date")
        return name
    secret.patch({"metadata": body["metadata"], "data": encoded})
    LOG.info(f"Updated connection secret {name}")
    return name


def reconcile_connection(obj, spec):
    context = connection_context(spec)
    data = connection_secret_data(spec, context)
    name = apply_connection_secret(obj, spec, data)
    # Verify the credentials actually work before reporting Ready, so that a
    # consumer waiting on this resource is not started against a broken
    # connection. The credentials are the service account's, but the TLS
    # material is this controller's: without it an account created REQUIRE
    # X509 -- which is every account when the chart runs with certificates --
    # could never be verified, and no Connection would ever become ready.
    probe = pymysql.connect(
        host=context["Host"],
        port=int(context["Port"]),
        user=context["Username"],
        password=context["Password"],
        database=context["Database"] or None,
        connect_timeout=MARIADB_DB_CONTROLLER_DB_CONNECT_TIMEOUT,
        **client_tls_options(),
    )
    probe.close()
    return f"secret {name} written and verified"


HANDLERS = (
    (Database, reconcile_database, finalize_database),
    (User, reconcile_user, finalize_user),
    (Grant, reconcile_grant, finalize_grant),
    (Connection, reconcile_connection, None),
)


# ---------------------------------------------------------------------------
# Reconcile loop
# ---------------------------------------------------------------------------

# uid -> (desired state hash, timestamp of the last successful apply)
applied = {}
# uid -> timestamp before which the resource is not retried
backoff = {}


def desired_hash(obj, spec, extra=""):
    """A digest of everything that would change the SQL we issue."""
    material = repr(sorted(spec.items())) + extra
    return hashlib.sha256(material.encode("utf-8")).hexdigest()


def owned(spec):
    """Whether this controller answers for the resource."""
    ref = spec.get("mariaDbRef") or {}
    name = ref.get("name")
    return not name or name == MARIADB_REF_NAME


# ---------------------------------------------------------------------------
# Fields this controller does not implement
#
# The custom resource definitions declare every field the upstream operator
# accepts, so that a resource written against upstream documentation is not
# silently stripped by the API server. This controller implements a subset, and
# refuses the rest rather than ignoring it: quietly dropping an authentication
# plugin, a TLS requirement or a proxy reference would leave the deployment
# weaker or differently wired than the resource asked for, with a Ready
# condition claiming success.
#
# A field is only refused when it is present and truthy. optional: false and
# require.ssl: false agree with what this controller already does, so a manifest
# copied from upstream that spells them out still reconciles.
# ---------------------------------------------------------------------------

UNSUPPORTED_FIELDS = (
    # Pin the referent's identity, which this controller never checks.
    ("mariaDbRef", "apiVersion"),
    ("mariaDbRef", "kind"),
    ("mariaDbRef", "uid"),
    ("mariaDbRef", "resourceVersion"),
    ("mariaDbRef", "fieldPath"),
    # A missing credential is always an error here, never something to
    # continue without.
    ("passwordSecretKeyRef", "optional"),
    ("passwordHashSecretKeyRef", "optional"),
    # Authentication plugins are not implemented.
    ("passwordPlugin",),
    # Only REQUIRE X509 is emitted.
    ("require", "ssl"),
    ("require", "issuer"),
    ("require", "subject"),
    # No MaxScale support: a connection would silently bypass the proxy.
    ("maxScaleRef",),
    # Connection TLS parameters come from secretTemplate.format.
    ("tlsClientCertSecretRef",),
)


def unsupported_field(spec):
    """The first unsupported field the spec sets, as a dotted path, or None."""
    for path in UNSUPPORTED_FIELDS:
        node = spec
        for key in path:
            if not isinstance(node, dict):
                node = None
                break
            node = node.get(key)
        if node:
            return ".".join(path)
    return None


def reject_unsupported(spec):
    """Refuse a resource that asks for something not implemented here."""
    field = unsupported_field(spec)
    if field:
        raise ReconcileError(
            f"spec.{field} is not supported by this controller. It is declared "
            f"so that the field is not silently discarded, but honoring it "
            f"would require the upstream mariadb-operator."
        )


def reconcile(obj, handler, finalizer):
    spec = obj.obj.get("spec") or {}
    uid = obj.obj["metadata"]["uid"]
    now = time.monotonic()

    # Ownership is settled before anything else, so a resource belonging to the
    # upstream operator -- which legitimately uses the fields refused below --
    # is left alone rather than reported as failing.
    if not owned(spec):
        LOG.debug(f"{obj.kind} {obj.name} targets another cluster, ignoring")
        set_ready(
            obj,
            "Unknown",
            REASON_NOT_OWNED,
            f"mariaDbRef.name is not {MARIADB_REF_NAME}",
        )
        remove_finalizer(obj)
        return

    if backoff.get(uid, 0) > now:
        return

    reject_unsupported(spec)

    if backoff.get(uid, 0) > now:
        return

    delete = (spec.get("cleanupPolicy") or "Skip") == "Delete"

    if "deletionTimestamp" in obj.obj["metadata"]:
        if finalizer and delete:
            finalizer(obj, spec)
        remove_finalizer(obj)
        applied.pop(uid, None)
        return

    if finalizer and delete:
        add_finalizer(obj)
    else:
        # Flipping cleanupPolicy from Delete back to Skip must not leave a
        # finalizer behind that would wedge a later deletion.
        remove_finalizer(obj)

    # For a User the password lives in a secret, so the secret's content is
    # part of the desired state even when the spec has not changed.
    extra = ""
    if obj.kind == "User":
        password, _ = user_password(spec)
        extra = hashlib.sha256(password.encode("utf-8")).hexdigest()

    digest = desired_hash(obj, spec, extra)
    previous = applied.get(uid)
    stale = (
        previous is None
        or previous[0] != digest
        or now - previous[1] >= MARIADB_DB_CONTROLLER_FULL_RESYNC_INTERVAL
    )
    if not stale:
        set_ready(obj, "True", REASON_RECONCILED, ready_message(obj))
        return

    message = handler(obj, spec)
    applied[uid] = (digest, now)
    LOG.info(f"{obj.kind} {obj.name}: {message}")
    set_ready(obj, "True", REASON_RECONCILED, message)


def sweep():
    live = set()
    for klass, handler, finalizer in HANDLERS:
        for obj in list_resources(klass):
            uid = obj.obj["metadata"]["uid"]
            live.add(uid)
            try:
                reconcile(obj, handler, finalizer)
                backoff.pop(uid, None)
            except Exception as error:
                spec = obj.obj.get("spec") or {}
                delay = parse_duration(
                    spec.get("retryInterval"),
                    MARIADB_DB_CONTROLLER_ERROR_BACKOFF,
                )
                backoff[uid] = time.monotonic() + delay
                LOG.warning(
                    f"{obj.kind} {obj.name} failed, retrying in {delay:.0f}s: "
                    f"{error}"
                )
                LOG.debug("Reconcile traceback", exc_info=True)
                try:
                    set_ready(obj, "False", REASON_ERROR, str(error))
                except Exception:
                    LOG.exception(f"Could not set status on {obj.name}")

    # Resources deleted while the controller was not looking would otherwise
    # leak an entry in each cache for the lifetime of the process.
    for cache in (applied, backoff):
        for uid in set(cache) - live:
            cache.pop(uid, None)


def main():
    while True:
        try:
            sweep()
        except Exception:
            # A sweep must never take the controller down: the most likely
            # cause is the galera cluster being briefly unavailable.
            LOG.exception("Reconcile sweep failed")
            sql.close()
        if MARIADB_DB_CONTROLLER_ONESHOT:
            LOG.info("Oneshot mode, exiting after a single sweep")
            return
        LOG.debug(f"Sleeping for {MARIADB_DB_CONTROLLER_RECONCILE_INTERVAL}")
        time.sleep(MARIADB_DB_CONTROLLER_RECONCILE_INTERVAL)


main()
