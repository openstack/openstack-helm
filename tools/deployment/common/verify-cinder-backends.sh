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
# Verify that cinder's storage backends are actually usable, not merely that
# the cinder-volume pods reached Running.
#
# A cinder-volume pod stays Running with a completely dead driver: if the RBD
# driver cannot connect to Ceph, cinder logs "Failed to initialize driver" and
# the service reports itself down, but nothing in the pod lifecycle reflects
# that. There is no readiness probe on driver state, so a deployment whose
# every volume backend is broken looks healthy to `kubectl` and to
# `helm osh wait-for-pods`. This script closes that gap.
#
# Usage:
#   tools/deployment/common/verify-cinder-backends.sh [NAMESPACE]
#
#   NAMESPACE  Kubernetes namespace cinder runs in (default: osh)
#
# Environment:
#   OS_CLOUD              openstack CLI cloud (default: openstack_helm)
#   SERVICE_UP_RETRIES    attempts waiting for backends to report up (default: 30)
#   SERVICE_UP_DELAY      seconds between those attempts (default: 10)
#   POOL_STATS_RETRIES    attempts waiting for pool capacity stats (default: 12)
#   POOL_STATS_DELAY      seconds between those attempts (default: 10)
#   EXPECT_STORAGE_PROTOCOL  protocol at least one pool must report
#                            (default: ceph; empty disables the check)

set -uo pipefail

NAMESPACE="${1:-osh}"
export OS_CLOUD="${OS_CLOUD:-openstack_helm}"
SERVICE_UP_RETRIES="${SERVICE_UP_RETRIES:-30}"
SERVICE_UP_DELAY="${SERVICE_UP_DELAY:-10}"
POOL_STATS_RETRIES="${POOL_STATS_RETRIES:-12}"
POOL_STATS_DELAY="${POOL_STATS_DELAY:-10}"
EXPECT_STORAGE_PROTOCOL="${EXPECT_STORAGE_PROTOCOL-ceph}"

PASS=0 FAIL=0
ok()  { echo "  PASS: $*"; PASS=$((PASS+1)); }
no()  { echo "  FAIL: $*"; FAIL=$((FAIL+1)); }
hdr() { printf '\n== %s ==\n' "$*"; }

echo "Verifying cinder backends in namespace '$NAMESPACE' (OS_CLOUD=$OS_CLOUD)"

###############################################################################
hdr "1. Every cinder-volume backend reports up"

# `openstack volume service list` prints one row per binary/host pair:
#   | cinder-volume | cinder-volume-0@rbd1 | nova | enabled | up   | ... |
# A backend whose driver failed to initialize stays "down" forever.
volume_services() {
  openstack volume service list -f value -c Binary -c Host -c Status -c State 2>/dev/null \
    | awk '$1 == "cinder-volume"'
}

services=""
for _ in $(seq 1 "$SERVICE_UP_RETRIES"); do
  services="$(volume_services)"
  # Keep waiting only while a backend has yet to report up; the driver needs a
  # moment after the pod goes Running to connect and send its first heartbeat.
  if [[ -n "$services" ]] && [[ -z "$(awk '$4 != "up"' <<<"$services")" ]]; then
    break
  fi
  sleep "$SERVICE_UP_DELAY"
done

if [[ -z "$services" ]]; then
  no "No cinder-volume services registered at all"
  echo "--- openstack volume service list ---"
  openstack volume service list || true
else
  echo "--- cinder-volume services (binary host status state) ---"
  echo "$services"
  not_up="$(awk '$4 != "up"' <<<"$services")"
  if [[ -n "$not_up" ]]; then
    no "cinder-volume backend(s) not up:"
    echo "$not_up" | sed 's/^/      /'
  else
    ok "All $(wc -l <<<"$services" | tr -d ' ') cinder-volume backend(s) report up"
  fi
  not_enabled="$(awk '$3 != "enabled"' <<<"$services")"
  if [[ -n "$not_enabled" ]]; then
    no "cinder-volume backend(s) not enabled:"
    echo "$not_enabled" | sed 's/^/      /'
  fi
fi

###############################################################################
hdr "2. No driver initialization failures in the cinder-volume logs"

# Belt and braces: the service state above is the authoritative signal, but
# scraping the log names the actual cause (e.g. a RADOS auth/connect error)
# right where someone debugging the job will look.
pods="$(kubectl -n "$NAMESPACE" get pods \
          -l application=cinder,component=volume \
          -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)"
if [[ -z "$pods" ]]; then
  no "Found no cinder-volume pods in namespace '$NAMESPACE'"
else
  for pod in $pods; do
    logs="$(kubectl -n "$NAMESPACE" logs "$pod" -c cinder-volume --tail=-1 2>/dev/null)"
    if [[ -z "$logs" ]]; then
      no "Could not read cinder-volume logs from $pod"
      continue
    fi
    if grep -qE "Failed to initialize driver|Error connecting to ceph cluster" <<<"$logs"; then
      no "$pod: driver failed to initialize"
      grep -E "Failed to initialize driver|Error connecting to ceph cluster|rados\.(IOError|ObjectNotFound|PermissionError)" <<<"$logs" \
        | tail -5 | sed 's/^/      /'
    else
      ok "$pod: no driver initialization failures logged"
    fi
  done
fi

###############################################################################
hdr "3. Backend pool capacity is read from the storage cluster"

# This is the part that proves the backend is genuinely talking to Ceph rather
# than merely holding a connection open. cinder's RBD driver seeds its stats
# with:
#
#     'total_capacity_gb': 'unknown', 'free_capacity_gb': 'unknown'
#
# and only replaces them with real numbers once _get_pool_stats() has round
# tripped to the cluster; on rados.Error it logs and leaves them 'unknown'
# (cinder/volume/drivers/rbd.py). So a numeric capacity here means the driver
# authenticated with its cephx key and read the pool's actual usage, and
# storage_protocol tells us which driver produced it.
#
# `volume backend pool list` builds only the volume client, so unlike
# `volume create` it does not require an image endpoint -- which matters
# because every playbook here deploys cinder before glance.
pool_json=""
for _ in $(seq 1 "$POOL_STATS_RETRIES"); do
  pool_json="$(openstack volume backend pool list --long -f json 2>/dev/null)"
  if [[ -n "$pool_json" ]] && ! grep -q "unknown" <<<"$pool_json"; then
    break
  fi
  sleep "$POOL_STATS_DELAY"
done

if [[ -z "$pool_json" ]]; then
  no "Could not list backend pools"
else
  # Emit one "name|protocol|total|free" line per pool, then assert on it.
  pool_rows="$(python3 - "$pool_json" <<'PY'
import json, re, sys
try:
    pools = json.loads(sys.argv[1]) or []
except (ValueError, IndexError):
    sys.exit(1)
for p in pools:
    caps = p.get("Capabilities") or {}
    if not isinstance(caps, dict):
        # Older clients may render capabilities as "key='value', key2='value2'"
        # instead of a nested object.
        caps = dict(re.findall(r"(\w+)='([^']*)'", str(caps)))
    print("%s|%s|%s|%s" % (
        p.get("Name", "?"),
        caps.get("storage_protocol", "?"),
        caps.get("total_capacity_gb", "?"),
        caps.get("free_capacity_gb", "?"),
    ))
PY
)"
  if [[ -z "$pool_rows" ]]; then
    no "No backend pools reported by the scheduler"
    echo "$pool_json"
  else
    echo "--- backend pools (name | protocol | total_gb | free_gb) ---"
    tr '|' ' ' <<<"$pool_rows" | sed 's/^/  /'

    while IFS='|' read -r pname proto total free; do
      [[ -z "$pname" ]] && continue
      # A real capacity is a positive number. 'unknown' is the driver's
      # explicit "I could not reach the cluster" marker.
      if awk -v v="$total" 'BEGIN { exit !(v ~ /^[0-9]+(\.[0-9]+)?$/ && v + 0 > 0) }'; then
        ok "$pname: capacity read from the cluster (total=${total}GB free=${free}GB)"
      else
        no "$pname: capacity is '$total' -- the driver never read the cluster"
      fi
    done <<<"$pool_rows"

    if [[ -n "$EXPECT_STORAGE_PROTOCOL" ]]; then
      if grep -qi "|${EXPECT_STORAGE_PROTOCOL}|" <<<"$pool_rows"; then
        ok "At least one pool reports storage_protocol '$EXPECT_STORAGE_PROTOCOL'"
      else
        no "No pool reports storage_protocol '$EXPECT_STORAGE_PROTOCOL'"
      fi
    fi
  fi
fi

###############################################################################
hdr "Summary"
echo "  PASS=$PASS  FAIL=$FAIL"
if [[ "$FAIL" -eq 0 ]]; then
  echo "Cinder backend verification succeeded."
  exit 0
else
  echo "Cinder backend verification found problems."
  exit 1
fi
