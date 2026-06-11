#!/usr/bin/env bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Verify that an OpenStack service actually talks to MariaDB over TLS using a
# dedicated client certificate (not the MariaDB server certificate).
#
# Usage:
#   tools/deployment/common/verify-mariadb-tls.sh [SERVICE] [NAMESPACE]
#
#   SERVICE    OpenStack service / db user name (default: keystone)
#   NAMESPACE  Kubernetes namespace (default: osh)
#
# The client certificate is the single per-chart client certificate shared by
# the MariaDB and RabbitMQ connections (<service>-client). Override the
# auto-derived names with env vars if a chart deviates from the
# <service>-db-user / <service>-db-admin / <service>-client convention
# (e.g. nova-db-api-user):
#   USER_SECRET, ADMIN_SECRET, CLIENT_SECRET, MARIADB_SELECTOR
#
# Examples:
#   tools/deployment/common/verify-mariadb-tls.sh keystone
#   tools/deployment/common/verify-mariadb-tls.sh glance
#   USER_SECRET=nova-db-api-user ADMIN_SECRET=nova-db-api-admin \
#     CLIENT_SECRET=nova-client tools/deployment/common/verify-mariadb-tls.sh nova

set -uo pipefail

SERVICE="${1:-keystone}"
NAMESPACE="${2:-osh}"
RELEASE="${RELEASE:-$SERVICE}"
USER_SECRET="${USER_SECRET:-${SERVICE}-db-user}"
ADMIN_SECRET="${ADMIN_SECRET:-${SERVICE}-db-admin}"
CLIENT_SECRET="${CLIENT_SECRET:-${SERVICE}-client}"
SERVER_SECRET="${SERVER_SECRET:-mariadb-tls-direct}"
MARIADB_SELECTOR="${MARIADB_SELECTOR:-application=mariadb,component=server}"

PASS=0 FAIL=0 WARN=0
ok()    { echo "  PASS: $*"; PASS=$((PASS+1)); }
no()    { echo "  FAIL: $*"; FAIL=$((FAIL+1)); }
warn()  { echo "  WARN: $*"; WARN=$((WARN+1)); }
hdr()   { printf '\n== %s ==\n' "$*"; }

kgsecret() { # namespace secret key  -> decoded value
  kubectl -n "$NAMESPACE" get secret "$1" -o "jsonpath={.data.$2}" 2>/dev/null | base64 -d
}

# Parse a SQLAlchemy URI: scheme://user:pass@host:port/db?params
uri_user() { local r="${1#*://}"; r="${r%%@*}"; printf '%s' "${r%%:*}"; }
uri_pass() { local r="${1#*://}"; r="${r%%@*}"; printf '%s' "${r#*:}"; }
uri_host() { local r="${1#*://}"; r="${r#*@}"; r="${r%%/*}"; printf '%s' "${r%%:*}"; }
uri_port() { local r="${1#*://}"; r="${r#*@}"; r="${r%%/*}"; case "$r" in *:*) printf '%s' "${r##*:}";; *) printf '3306';; esac; }

hdr "Target"
echo "  service=$SERVICE namespace=$NAMESPACE"
echo "  user-secret=$USER_SECRET  admin-secret=$ADMIN_SECRET  client-cert-secret=$CLIENT_SECRET"

# Discover a MariaDB pod (has the mysql client; used to run queries in-cluster).
MARIADB_POD="$(kubectl -n "$NAMESPACE" get pods -l "$MARIADB_SELECTOR" \
  -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
if [[ -z "$MARIADB_POD" ]]; then
  echo "Could not find a MariaDB pod (selector: $MARIADB_SELECTOR). Set MARIADB_SELECTOR." >&2
  exit 2
fi
echo "  mariadb-pod=$MARIADB_POD"

DB_URI="$(kgsecret "$USER_SECRET" DB_CONNECTION)"
if [[ -z "$DB_URI" ]]; then
  echo "Could not read DB_CONNECTION from secret $USER_SECRET in ns $NAMESPACE." >&2
  exit 2
fi
DB_USER="$(uri_user "$DB_URI")"; DB_PASS="$(uri_pass "$DB_URI")"
DB_HOST="$(uri_host "$DB_URI")"; DB_PORT="$(uri_port "$DB_URI")"

# Is MariaDB TLS (tls.oslo_db) enabled for this release? Prefer the value
# reported by Helm; fall back to the SSL params the chart only adds to
# DB_CONNECTION when tls.oslo_db is true.
tls_oslo_db_enabled() {
  local v="" json
  if command -v helm >/dev/null 2>&1; then
    json="$(helm -n "$NAMESPACE" get values "$RELEASE" -a -o json 2>/dev/null)"
    if [[ -n "$json" ]]; then
      if command -v jq >/dev/null 2>&1; then
        v="$(jq -r '.tls.oslo_db // false' <<<"$json" 2>/dev/null)"
      elif command -v python3 >/dev/null 2>&1; then
        v="$(python3 -c 'import sys,json; d=json.load(sys.stdin) or {}; print(str((d.get("tls") or {}).get("oslo_db", False)).lower())' <<<"$json" 2>/dev/null)"
      fi
    fi
  fi
  if [[ -n "$v" ]]; then
    [[ "$v" == "true" ]]; return
  fi
  grep -q "ssl_verify_cert" <<<"$DB_URI"
}

hdr "0. MariaDB TLS (tls.oslo_db) enabled for $SERVICE?"
if tls_oslo_db_enabled; then
  ok "tls.oslo_db is enabled for $SERVICE -> verifying the connection actually uses TLS"
else
  echo "  tls.oslo_db is NOT enabled for $SERVICE -> nothing to verify, skipping"
  exit 0
fi

# helper: run mysql inside the mariadb pod
mysql_in_pod() { # user pass extra-args... ; SQL on stdin
  local u="$1" p="$2"; shift 2
  kubectl -n "$NAMESPACE" exec -i "$MARIADB_POD" -c mariadb -- \
    mariadb -h "$DB_HOST" -P "$DB_PORT" -u "$u" -p"$p" "$@" 2>&1
}

###############################################################################
hdr "1. Client connection string is configured for TLS"
if grep -q "ssl_verify_cert" <<<"$DB_URI" && grep -q "ssl_cert=" <<<"$DB_URI"; then
  ok "DB_CONNECTION in $USER_SECRET carries ssl_ca/ssl_cert/ssl_key/ssl_verify_cert"
else
  no "DB_CONNECTION in $USER_SECRET has no SSL parameters -> service connects in plaintext"
fi

###############################################################################
hdr "2. A dedicated client certificate exists (not the server certificate)"
if kubectl -n "$NAMESPACE" get secret "$CLIENT_SECRET" >/dev/null 2>&1; then
  if [[ "$CLIENT_SECRET" != "$SERVER_SECRET" ]]; then
    ok "Client cert secret '$CLIENT_SECRET' is separate from server cert '$SERVER_SECRET'"
  else
    no "Client cert and server cert are the same secret ($CLIENT_SECRET)"
  fi
  usages="$(kubectl -n "$NAMESPACE" get certificate "$CLIENT_SECRET" \
            -o jsonpath='{.spec.usages}' 2>/dev/null)"
  if [[ -n "$usages" ]]; then
    if grep -q "client auth" <<<"$usages"; then
      ok "Certificate/$CLIENT_SECRET usages: $usages"
    else
      warn "Certificate/$CLIENT_SECRET usages do not include 'client auth': $usages"
    fi
  else
    warn "No cert-manager Certificate/$CLIENT_SECRET found (secret may be supplied manually)"
  fi
  # Compare issued cert fingerprints to make sure client != server on the wire.
  cfp="$(kgsecret "$CLIENT_SECRET" 'tls\.crt' | openssl x509 -noout -fingerprint -sha256 2>/dev/null)"
  sfp="$(kgsecret "$SERVER_SECRET" 'tls\.crt' | openssl x509 -noout -fingerprint -sha256 2>/dev/null)"
  if [[ -n "$cfp" && -n "$sfp" ]]; then
    [[ "$cfp" != "$sfp" ]] && ok "Client and server certificates have different fingerprints" \
                           || no "Client and server certificates are identical!"
  fi
else
  no "Client cert secret '$CLIENT_SECRET' not found"
fi

###############################################################################
hdr "3. The live connection is encrypted (Ssl_cipher)"
# Push the client cert into the mariadb pod and connect as the service user.
TMPD="/tmp/vtls-$$"
kubectl -n "$NAMESPACE" exec -i "$MARIADB_POD" -c mariadb -- mkdir -p "$TMPD" 2>/dev/null
push() { kubectl -n "$NAMESPACE" exec -i "$MARIADB_POD" -c mariadb -- sh -c "cat > $TMPD/$1"; }
kgsecret "$CLIENT_SECRET" 'ca\.crt'  | push ca.crt
kgsecret "$CLIENT_SECRET" 'tls\.crt' | push tls.crt
kgsecret "$CLIENT_SECRET" 'tls\.key' | push tls.key

cipher_out="$(kubectl -n "$NAMESPACE" exec -i "$MARIADB_POD" -c mariadb -- \
  mariadb -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" \
        --ssl-ca="$TMPD/ca.crt" --ssl-cert="$TMPD/tls.crt" --ssl-key="$TMPD/tls.key" \
        -N -e "SHOW SESSION STATUS LIKE 'Ssl_cipher';" 2>&1)"
cipher="$(awk '{print $2}' <<<"$cipher_out" | tail -1)"
if [[ -n "$cipher" && "$cipher" != "NULL" ]]; then
  ok "Service user '$DB_USER' session is using TLS (Ssl_cipher: $cipher)"
else
  no "Could not confirm an encrypted session. Output: $cipher_out"
fi

###############################################################################
hdr "4. TLS is enforced for the DB user (REQUIRE X509)"
ADMIN_URI="$(kgsecret "$ADMIN_SECRET" DB_CONNECTION)"
if [[ -n "$ADMIN_URI" ]]; then
  ADMIN_USER="$(uri_user "$ADMIN_URI")"; ADMIN_PASS="$(uri_pass "$ADMIN_URI")"
  grants="$(kubectl -n "$NAMESPACE" exec -i "$MARIADB_POD" -c mariadb -- \
    mariadb -h "$DB_HOST" -P "$DB_PORT" -u "$ADMIN_USER" -p"$ADMIN_PASS" \
          --ssl-ca="$TMPD/ca.crt" --ssl-cert="$TMPD/tls.crt" --ssl-key="$TMPD/tls.key" \
          -N -e "SHOW GRANTS FOR '$DB_USER'@'%';" 2>&1)"
  if grep -qi "REQUIRE X509\|REQUIRE SSL" <<<"$grants"; then
    ok "DB user '$DB_USER' requires X509/SSL"
  else
    warn "DB user '$DB_USER' grants do not show REQUIRE X509 (TLS may be optional). Output: $(tr '\n' ' ' <<<"$grants")"
  fi
else
  warn "Could not read admin secret $ADMIN_SECRET; skipping grant check"
fi

###############################################################################
hdr "5. Negative test: a plaintext connection is rejected"
plain="$(kubectl -n "$NAMESPACE" exec -i "$MARIADB_POD" -c mariadb -- \
  mariadb -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" \
        --skip-ssl -N -e "SELECT 1;" 2>&1)"
if grep -qi "access denied\|ERROR\|required\|insecure" <<<"$plain"; then
  ok "Plaintext (--skip-ssl) connection refused as expected"
else
  no "Plaintext connection succeeded -> TLS is NOT enforced. Output: $(tr '\n' ' ' <<<"$plain")"
fi

# Cleanup
kubectl -n "$NAMESPACE" exec -i "$MARIADB_POD" -c mariadb -- rm -rf "$TMPD" 2>/dev/null

###############################################################################
hdr "Summary"
echo "  PASS=$PASS  FAIL=$FAIL  WARN=$WARN"
if [[ "$FAIL" -eq 0 ]]; then
  echo "MariaDB TLS verification succeeded for '$SERVICE'."
  exit 0
else
  echo "MariaDB TLS verification found problems for '$SERVICE'."
  exit 1
fi
