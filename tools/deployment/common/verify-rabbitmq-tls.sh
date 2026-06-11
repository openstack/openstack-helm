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
# Verify that an OpenStack service talks to RabbitMQ over mutual TLS (mTLS)
# using a dedicated client certificate (not the RabbitMQ server certificate),
# and that RabbitMQ actually requires a client certificate
# (ssl_options.fail_if_no_peer_cert = true) on the AMQP listener.
#
# Usage:
#   tools/deployment/common/verify-rabbitmq-tls.sh [SERVICE] [NAMESPACE]
#
#   SERVICE    OpenStack service name (default: keystone)
#   NAMESPACE  Kubernetes namespace (default: osh)
#
# The client certificate is the single per-chart client certificate shared by
# the MariaDB and RabbitMQ connections (<service>-client). Override the
# auto-derived names with env vars if a chart deviates from convention:
#   CLIENT_SECRET, SERVER_SECRET, RABBIT_SELECTOR, RABBIT_CONTAINER, RABBIT_AMQP_PORT

set -uo pipefail

SERVICE="${1:-keystone}"
NAMESPACE="${2:-osh}"
RELEASE="${RELEASE:-$SERVICE}"
CLIENT_SECRET="${CLIENT_SECRET:-${SERVICE}-client}"
SERVER_SECRET="${SERVER_SECRET:-rabbitmq-tls-direct}"
RABBIT_SELECTOR="${RABBIT_SELECTOR:-application=rabbitmq,component=server}"
RABBIT_CONTAINER="${RABBIT_CONTAINER:-rabbitmq}"
RABBIT_AMQP_PORT="${RABBIT_AMQP_PORT:-5672}"

PASS=0 FAIL=0 WARN=0
ok()    { echo "  PASS: $*"; PASS=$((PASS+1)); }
no()    { echo "  FAIL: $*"; FAIL=$((FAIL+1)); }
warn()  { echo "  WARN: $*"; WARN=$((WARN+1)); }
hdr()   { printf '\n== %s ==\n' "$*"; }

kgsecret() { # secret key -> decoded value
  kubectl -n "$NAMESPACE" get secret "$1" -o "jsonpath={.data.$2}" 2>/dev/null | base64 -d
}
rexec() { # run a command in the rabbitmq pod/container
  kubectl -n "$NAMESPACE" exec -i "$RABBIT_POD" -c "$RABBIT_CONTAINER" -- "$@"
}

hdr "Target"
echo "  service=$SERVICE namespace=$NAMESPACE"
echo "  client-cert-secret=$CLIENT_SECRET  server-cert-secret=$SERVER_SECRET"

RABBIT_POD="$(kubectl -n "$NAMESPACE" get pods -l "$RABBIT_SELECTOR" \
  -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
if [[ -z "$RABBIT_POD" ]]; then
  echo "Could not find a RabbitMQ pod (selector: $RABBIT_SELECTOR). Set RABBIT_SELECTOR." >&2
  exit 2
fi
RABBIT_HOST="$(kubectl -n "$NAMESPACE" get svc rabbitmq -o jsonpath='{.metadata.name}.{.metadata.namespace}.svc' 2>/dev/null)"
RABBIT_HOST="${RABBIT_HOST:-rabbitmq.$NAMESPACE.svc}"
echo "  rabbitmq-pod=$RABBIT_POD  amqp-endpoint=$RABBIT_HOST:$RABBIT_AMQP_PORT"

# Is messaging TLS (tls.oslo_messaging) enabled for this release?
tls_oslo_messaging_enabled() {
  local v="" json
  if command -v helm >/dev/null 2>&1; then
    json="$(helm -n "$NAMESPACE" get values "$RELEASE" -a -o json 2>/dev/null)"
    if [[ -n "$json" ]]; then
      if command -v jq >/dev/null 2>&1; then
        v="$(jq -r '.tls.oslo_messaging // false' <<<"$json" 2>/dev/null)"
      elif command -v python3 >/dev/null 2>&1; then
        v="$(python3 -c 'import sys,json; d=json.load(sys.stdin) or {}; print(str((d.get("tls") or {}).get("oslo_messaging", False)).lower())' <<<"$json" 2>/dev/null)"
      fi
    fi
  fi
  [[ "$v" == "true" ]]
}

hdr "0. Messaging TLS (tls.oslo_messaging) enabled for $SERVICE?"
if tls_oslo_messaging_enabled; then
  ok "tls.oslo_messaging is enabled for $SERVICE -> verifying RabbitMQ mTLS"
else
  echo "  tls.oslo_messaging is NOT enabled for $SERVICE -> nothing to verify, skipping"
  exit 0
fi

###############################################################################
hdr "1. A dedicated client certificate exists (not the server certificate)"
if kubectl -n "$NAMESPACE" get secret "$CLIENT_SECRET" >/dev/null 2>&1; then
  if [[ "$CLIENT_SECRET" != "$SERVER_SECRET" ]]; then
    ok "Client cert secret '$CLIENT_SECRET' is separate from server cert '$SERVER_SECRET'"
  else
    no "Client cert and server cert are the same secret ($CLIENT_SECRET)"
  fi
  usages="$(kubectl -n "$NAMESPACE" get certificate "$CLIENT_SECRET" \
            -o jsonpath='{.spec.usages}' 2>/dev/null)"
  if [[ -n "$usages" ]]; then
    grep -q "client auth" <<<"$usages" \
      && ok "Certificate/$CLIENT_SECRET usages: $usages" \
      || warn "Certificate/$CLIENT_SECRET usages do not include 'client auth': $usages"
  else
    warn "No cert-manager Certificate/$CLIENT_SECRET found (secret may be supplied manually)"
  fi
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
hdr "2. RabbitMQ enforces mutual TLS (ssl_options in rabbitmq.conf)"
conf="$(rexec cat /etc/rabbitmq/rabbitmq.conf 2>/dev/null)"
if [[ -z "$conf" ]]; then
  warn "Could not read /etc/rabbitmq/rabbitmq.conf from pod $RABBIT_POD"
else
  if grep -qE "ssl_options\.fail_if_no_peer_cert\s*=\s*true" <<<"$conf"; then
    ok "ssl_options.fail_if_no_peer_cert = true (a client certificate is required)"
  else
    no "ssl_options.fail_if_no_peer_cert is not true -> mTLS is not enforced"
  fi
  grep -qE "ssl_options\.verify\s*=\s*verify_peer" <<<"$conf" \
    && ok "ssl_options.verify = verify_peer (client certificate is validated)" \
    || warn "ssl_options.verify is not verify_peer"
fi

###############################################################################
hdr "3. Live AMQP TLS handshake (best-effort; requires openssl in the pod)"
if ! rexec sh -c 'command -v openssl >/dev/null 2>&1'; then
  warn "openssl not available in pod $RABBIT_POD -> skipping live handshake test"
else
  TMPD="/tmp/vrmqtls-$$"
  rexec mkdir -p "$TMPD" 2>/dev/null
  push() { rexec sh -c "cat > $TMPD/$1"; }
  kgsecret "$CLIENT_SECRET" 'ca\.crt'  | push ca.crt
  kgsecret "$CLIENT_SECRET" 'tls\.crt' | push tls.crt
  kgsecret "$CLIENT_SECRET" 'tls\.key' | push tls.key

  with_cert="$(rexec sh -c "echo Q | openssl s_client -connect $RABBIT_HOST:$RABBIT_AMQP_PORT -CAfile $TMPD/ca.crt -cert $TMPD/tls.crt -key $TMPD/tls.key 2>&1")"
  if grep -q "Verify return code: 0 (ok)" <<<"$with_cert" && grep -qi "Cipher is" <<<"$with_cert"; then
    ok "AMQP TLS handshake succeeded presenting client cert $CLIENT_SECRET"
  else
    warn "Could not confirm a successful mTLS handshake with the client cert. Tail: $(tr '\n' ' ' <<<"$with_cert" | tail -c 300)"
  fi

  no_cert="$(rexec sh -c "echo Q | openssl s_client -connect $RABBIT_HOST:$RABBIT_AMQP_PORT -CAfile $TMPD/ca.crt 2>&1")"
  if grep -qiE "alert handshake failure|peer did not return a certificate|no certificate|sslv3 alert|tlsv1 alert|errno|Verify return code: [^0]" <<<"$no_cert" \
     && ! grep -q "Verify return code: 0 (ok)" <<<"$no_cert"; then
    ok "RabbitMQ rejected the AMQP connection with no client cert (mTLS enforced on the wire)"
  else
    warn "Connection without a client cert was not clearly rejected. Tail: $(tr '\n' ' ' <<<"$no_cert" | tail -c 300)"
  fi
  rexec rm -rf "$TMPD" 2>/dev/null
fi

###############################################################################
hdr "Summary"
echo "  PASS=$PASS  FAIL=$FAIL  WARN=$WARN"
if [[ "$FAIL" -eq 0 ]]; then
  echo "RabbitMQ mTLS verification succeeded for '$SERVICE'."
  exit 0
else
  echo "RabbitMQ mTLS verification found problems for '$SERVICE'."
  exit 1
fi
