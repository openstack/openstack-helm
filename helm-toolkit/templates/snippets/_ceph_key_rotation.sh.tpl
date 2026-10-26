{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

{{- define "helm-toolkit.snippets.ceph_key_rotation" -}}
{{/*

Inserts bash constants and function definitions shared by the CephX key type
rotation checks in the ceph-mon, ceph-osd and ceph-rgw charts.

Key rotation is tempered during upgrades: rotate_entity_key refuses to rotate
any key unless every monitor in the quorum is running at least
KEY_ROTATION_MIN_CEPH_VERSION (default "20.2.4"), since monitors running older
releases cannot use keys of a newer type. The minimum version can be
overridden via the KEY_ROTATION_MIN_CEPH_VERSION environment variable.

Requires the CLUSTER and ADMIN_KEYRING environment variables to be set in
the calling script. The Secret-backed helpers (secret_keyring,
patch_secret_keyring, check_secret_entity_key_type) additionally require the
NAMESPACE environment variable.

Usage (e.g. in _start.sh.tpl):
    #!/bin/bash

    : "${CLUSTER:=ceph}"
    : "${ADMIN_KEYRING:=/etc/ceph/${CLUSTER}.client.admin.keyring}"

    {{ include "helm-toolkit.snippets.ceph_key_rotation" . }}

    # Thin, chart-side wrapper deriving the desired type:
    #   key_type=$(get_monmap_cipher auth_preferred_cipher)
    #   check_cluster_entity_key_type "client.rgw.${RGW_NAME}" "${key_type}" "${RGW_KEYRING}"
*/}}
{{`
# Well-known base64-encoded key lengths per key type: 40 chars for "aes",
# 60 chars for "aes256k". Keys of any other length are left alone.
AES_KEY_LENGTH=40
AES256K_KEY_LENGTH=60

# Minimum Ceph version that every monitor in the quorum must run before any
# CephX key is rotated. Releases older than the one introducing the configured
# key type (aes256k needs 20.2.4) cannot use rotated keys, so rotation is
# tempered while the quorum is mixed-version (e.g. during a rolling upgrade)
# or its versions cannot be determined. Override via the environment.
: "${KEY_ROTATION_MIN_CEPH_VERSION:=20.2.4}"

# Numerically compare two dotted version strings. Returns 0 when the first
# version is greater than or equal to the second. Missing components count as
# zero, so "20.2" equals "20.2.0".
# Usage: version_ge <version> <minimum>
function version_ge () {
  awk -v version="$1" -v minimum="$2" 'BEGIN {
    n = split(version, V, "."); m = split(minimum, M, ".")
    for (i = 1; i <= (n > m ? n : m); i++) {
      v = V[i] + 0; w = M[i] + 0
      if (v > w) exit 0
      if (v < w) exit 1
    }
    exit 0
  }'
}

# Verify that every monitor in the quorum reports a Ceph version of at least
# <minimum>. "ceph mon versions" lists the versions of all monitors in quorum.
# Returns 0 only when the quorum is reachable and every reported version meets
# the minimum. Returns 1 when the quorum cannot be reached, no versions can be
# parsed, or any monitor is older, so callers skip rotation and retry on the
# next daemon start rather than rotating a key older monitors cannot use.
# Usage: mon_quorum_supports_key_rotation <minimum-version>
function mon_quorum_supports_key_rotation () {
  local minimum="$1" versions="" version=""
  versions=$(timeout 15 ceph --cluster "${CLUSTER}" --name client.admin \
    --keyring "${ADMIN_KEYRING}" mon versions 2>/dev/null || true)
  [[ -n "${versions}" ]] || return 1
  for version in $(echo "${versions}" | awk '/version/{print $3}'); do
    version_ge "${version}" "${minimum}" || return 1
  done
  return 0
}

# Map a key type name to its expected base64-encoded key length. Echoes an
# empty string for unknown key types, in which case no rotation is performed.
# Usage: key_type_length <key_type>
function key_type_length () {
  case "$1" in
    aes) echo "${AES_KEY_LENGTH}" ;;
    aes256k) echo "${AES256K_KEY_LENGTH}" ;;
    *) echo "" ;;
  esac
}

# Extract a single entity key from a keyring file without ever echoing it.
# Usage: keyring_key <keyring-file> [entity]
function keyring_key () {
  local keyring_file="$1"
  local entity="${2:-}"
  if [[ -n "${entity}" ]]; then
    ceph-authtool "${keyring_file}" -n "${entity}" --print-key 2>/dev/null
  else
    ceph-authtool "${keyring_file}" --print-key 2>/dev/null
  fi
}

# Rotate a CephX entity key in the cluster, preserving its caps, and write the
# resulting keyring to a file. When a key type is given it is passed to ceph
# auth rotate (--key-type, available from Ceph 20.2.4), so the rotated key has
# that type whatever the monmap auth_preferred_cipher currently is: during an
# upgrade the monmap ciphers may not be reconciled yet, and rotating without a
# key type would then generate a legacy key again. Without a key type the
# monitors use their preferred key type. Requires cluster access with the
# client.admin keyring in ${ADMIN_KEYRING}. Rotation is tempered during
# upgrades: it is refused unless every monitor in the quorum runs at least
# KEY_ROTATION_MIN_CEPH_VERSION and the quorum versions can be determined, so
# mixed-version quorums (e.g. during a rolling upgrade) keep their existing keys
# until every monitor has been upgraded. Callers retry on the next daemon
# start. The new key is only written to the output keyring, never to stdout.
# Usage: rotate_entity_key <entity> <output-keyring> [key-type]
function rotate_entity_key () {
  local entity="$1"
  local output_keyring="$2"
  local key_type="${3:-}"
  local key_type_args=()
  if ! mon_quorum_supports_key_rotation "${KEY_ROTATION_MIN_CEPH_VERSION}"; then
    echo "WARNING- mon quorum is not fully running Ceph ${KEY_ROTATION_MIN_CEPH_VERSION} or later, skipping ${entity} key rotation"
    return 1
  fi
  if [[ -n "${key_type}" ]]; then
    key_type_args=("--key-type=${key_type}")
  fi
  timeout 30 ceph --cluster "${CLUSTER}" --name client.admin --keyring "${ADMIN_KEYRING}" auth rotate "${key_type_args[@]}" "${entity}" >/dev/null && \
    timeout 30 ceph --cluster "${CLUSTER}" --name client.admin --keyring "${ADMIN_KEYRING}" auth get "${entity}" -o "${output_keyring}"
}

# Determine a cipher name (e.g. "auth_service_cipher" or
# "auth_preferred_cipher") from the monmap, which the ceph-mon chart sets
# via "conf.auth_ciphers". Echoes the cipher name, or an empty string
# when it cannot be determined (in which case no rotation is performed and
# new keys are still created by the mon with the configured cipher).
# Usage: get_monmap_cipher <field>
function get_monmap_cipher () {
  local field="$1" monmap="" cipher=""
  monmap=$(mktemp) || return 0
  if timeout 15 ceph --cluster "${CLUSTER}" --name client.admin --keyring "${ADMIN_KEYRING}" mon getmap -o "${monmap}" 2>/dev/null; then
    cipher=$(monmaptool --print "${monmap}" 2>/dev/null | awk -v pattern="^${field} " '$0 ~ pattern {print $2; exit}')
  fi
  rm -f "${monmap}"
  if [[ -z "${cipher}" ]]; then
    cipher=$(timeout 15 ceph --cluster "${CLUSTER}" --name client.admin --keyring "${ADMIN_KEYRING}" config get "${field}" 2>/dev/null | tr -d '[:space:]' || true)
  fi
  case "${cipher}" in
    aes|aes256k) echo "${cipher}" ;;
    *) echo "" ;;
  esac
}

# Best-effort check of a cluster-side entity key: if the key length does not
# match the desired key type, rotate it. When a refresh file is given, the
# rotated keyring is written to it. Skipped for entities that do not exist yet
# ("auth get-or-create" creates them with the cluster's configured cipher).
# Never blocks startup; always returns 0.
# Usage: check_cluster_entity_key_type <entity> <desired-key_type> [refresh-file]
function check_cluster_entity_key_type () {
  local entity="$1"
  local key_type="$2"
  local refresh_file="${3:-}"
  local expected_length="" current_key="" tmpdir="" xtrace=0
  local fetched=""

  if [[ ! -e "${ADMIN_KEYRING}" ]]; then
    echo "WARNING- ${ADMIN_KEYRING} not found, skipping ${entity} key type check"
    return 0
  fi

  expected_length=$(key_type_length "${key_type}" || true)
  if [[ -z "${expected_length}" ]]; then
    return 0
  fi

  tmpdir=$(mktemp -d) || { echo "WARNING- unable to create temp dir, skipping ${entity} key type check"; return 0; }
  [[ "${-}" == *x* ]] && xtrace=1
  # Self-clearing: fires on this function's return, then removes itself so
  # it never runs again inside a later function with stale locals.
  trap '[[ -n "${tmpdir:-}" ]] && rm -rf "${tmpdir}" || true; [[ "${xtrace:-0}" -eq 1 ]] && set -x || true; trap - RETURN' RETURN

  # Set +x for the key handling below: key material must never leak through
  # tracing. The RETURN trap above restores tracing on every return path.
  set +x
  fetched="${tmpdir}/entity.keyring"
  if ! timeout 15 ceph --cluster "${CLUSTER}" --name client.admin --keyring "${ADMIN_KEYRING}" auth get "${entity}" -o "${fetched}" 2>/dev/null; then
    # Entity does not exist yet; "auth get-or-create" creates it with the
    # cluster's configured cipher.
    return 0
  fi

  current_key=$(keyring_key "${fetched}" "${entity}" || true)
  if [[ -z "${current_key}" ]]; then
    echo "WARNING- unable to read ${entity} key from cluster, skipping ${entity} key type check"
    return 0
  fi

  if [[ "${#current_key}" -eq "${expected_length}" ]]; then
    return 0
  fi

  echo "${entity} key length does not match desired type ${key_type}, rotating key"
  local rotated="${tmpdir}/entity.rotated.keyring"
  if rotate_entity_key "${entity}" "${rotated}" "${key_type}"; then
    if [[ -n "${refresh_file}" ]]; then
      mkdir -p "$(dirname "${refresh_file}")"
      cp -vf "${rotated}" "${refresh_file}" || \
        echo "WARNING- failed to refresh local ${entity} keyring, continuing"
      chown ceph. "${refresh_file}" 2>/dev/null || true
      chmod 0600 "${refresh_file}" 2>/dev/null || true
    fi
  else
    echo "WARNING- failed to rotate ${entity} key, keeping existing key"
  fi
  return 0
}

# Best-effort check of a key stored in a local keyring file: if the key length
# does not match the desired key type, rotate the cluster-side key and refresh
# the local file. Skipped for unknown desired types, missing admin or local
# keyrings, and unreadable keys. Never blocks startup; always returns 0.
# Usage: check_local_entity_key_type <entity> <desired-key_type> <keyring-file>
function check_local_entity_key_type () {
  local entity="$1"
  local key_type="$2"
  local keyring_file="$3"
  local expected_length="" current_key="" tmpdir="" xtrace=0

  expected_length=$(key_type_length "${key_type}" || true)
  if [[ -z "${expected_length}" ]]; then
    return 0
  fi

  if [[ ! -e "${ADMIN_KEYRING}" ]]; then
    echo "WARNING- ${ADMIN_KEYRING} not found, skipping ${entity} key type check"
    return 0
  fi
  if [[ ! -e "${keyring_file}" ]]; then
    echo "WARNING- ${keyring_file} not found, skipping ${entity} key type check"
    return 0
  fi

  tmpdir=$(mktemp -d) || { echo "WARNING- unable to create temp dir, skipping ${entity} key type check"; return 0; }
  [[ "${-}" == *x* ]] && xtrace=1
  # Self-clearing: fires on this function's return, then removes itself so
  # it never runs again inside a later function with stale locals.
  trap '[[ -n "${tmpdir:-}" ]] && rm -rf "${tmpdir}" || true; [[ "${xtrace:-0}" -eq 1 ]] && set -x || true; trap - RETURN' RETURN

  # Set +x for the key handling below: key material must never leak through
  # tracing. The RETURN trap above restores tracing on every return path.
  set +x
  current_key=$(keyring_key "${keyring_file}" "${entity}" || true)
  if [[ -z "${current_key}" ]]; then
    echo "WARNING- unable to read ${entity} key from ${keyring_file}, skipping ${entity} key type check"
    return 0
  fi

  if [[ "${#current_key}" -eq "${expected_length}" ]]; then
    return 0
  fi

  echo "${entity} key length does not match desired type ${key_type}, rotating key"
  local rotated="${tmpdir}/entity.rotated.keyring"
  if rotate_entity_key "${entity}" "${rotated}" "${key_type}"; then
    cp -vf "${rotated}" "${keyring_file}" || \
      echo "WARNING- failed to refresh local ${entity} keyring, continuing"
    chown ceph. "${keyring_file}" 2>/dev/null || true
    chmod 0600 "${keyring_file}" 2>/dev/null || true
  else
    echo "WARNING- failed to rotate ${entity} key, keeping existing key"
  fi
  return 0
}

# Fetch a keyring stored in a Kubernetes Secret into a file.
# Requires the NAMESPACE environment variable.
# Usage: secret_keyring <secret-name> <secret-data-key> <output-file>
function secret_keyring () {
  local secret_name="$1"
  local secret_key="$2"
  local output_file="$3"
  local encoded="" jsonpath_key=""
  # kubectl's JSONPath re-parses bracket-quoted keys as field paths, so the
  # dot in data keys such as "ceph.keyring" or "ceph.mon.keyring" would split
  # the lookup into nested fields that do not exist ("ceph is not found") and
  # the keyring would never be read. Escape the dots and use plain field
  # notation, as done elsewhere in this repo (roles/deploy-charts).
  jsonpath_key="${secret_key//./\\.}"
  encoded=$(kubectl --namespace "${NAMESPACE}" get secret "${secret_name}" \
    -o "jsonpath={.data.${jsonpath_key}}" 2>/dev/null || true)
  if [[ -z "${encoded}" ]]; then
    return 1
  fi
  echo "${encoded}" | base64 -d > "${output_file}" 2>/dev/null
}

# Patch a keyring payload back into a Kubernetes Secret.
# Requires the NAMESPACE environment variable.
# Usage: patch_secret_keyring <secret-name> <secret-data-key> <keyring-file>
function patch_secret_keyring () {
  local secret_name="$1"
  local secret_key="$2"
  local keyring_file="$3"
  local encoded
  encoded=$(base64 < "${keyring_file}" | tr -d '\n')
  if [[ -z "${encoded}" ]]; then
    echo "WARNING- unable to encode ${keyring_file} for Secret ${secret_name}, skipping patch"
    return 1
  fi
  kubectl --namespace "${NAMESPACE}" patch secret "${secret_name}" \
    --type merge \
    -p "{\"data\":{\"${secret_key}\":\"${encoded}\"}}"
}

# Best-effort check of a key whose source of truth is a Kubernetes Secret: if
# the key length does not match the desired key type, rotate it, patch the
# rotated keyring back into the Secret, and refresh any local keyring files.
# The current key is read from the first existing refresh file, falling back to
# the Secret. Skipped for unknown desired types, missing admin keyring, and
# unreadable keys. Never blocks startup; always returns 0.
# Usage: check_secret_entity_key_type <entity> <desired-key_type> <secret-name> <secret-data-key> [refresh-file ...]
function check_secret_entity_key_type () {
  local entity="$1"
  local key_type="$2"
  local secret_name="$3"
  local secret_data_key="$4"
  shift 4
  local refresh_files=("$@")

  local expected_length="" current_key="" tmpdir="" xtrace=0
  local fetched=""

  expected_length=$(key_type_length "${key_type}" || true)
  if [[ -z "${expected_length}" ]]; then
    return 0
  fi

  if [[ ! -e "${ADMIN_KEYRING}" ]]; then
    echo "WARNING- ${ADMIN_KEYRING} not found, skipping ${entity} key type check"
    return 0
  fi

  tmpdir=$(mktemp -d) || { echo "WARNING- unable to create temp dir, skipping ${entity} key type check"; return 0; }
  [[ "${-}" == *x* ]] && xtrace=1
  # Self-clearing: fires on this function's return, then removes itself so
  # it never runs again inside a later function with stale locals.
  trap '[[ -n "${tmpdir:-}" ]] && rm -rf "${tmpdir}" || true; [[ "${xtrace:-0}" -eq 1 ]] && set -x || true; trap - RETURN' RETURN

  # Set +x for the key handling below: key material must never leak through
  # tracing. The RETURN trap above restores tracing on every return path.
  set +x
  for refresh_file in "${refresh_files[@]}"; do
    if [[ -n "${refresh_file}" && -e "${refresh_file}" ]]; then
      current_key=$(keyring_key "${refresh_file}" "${entity}" || true)
      if [[ -n "${current_key}" ]]; then
        break
      fi
    fi
  done

  if [[ -z "${current_key}" ]]; then
    fetched="${tmpdir}/entity.keyring"
    if secret_keyring "${secret_name}" "${secret_data_key}" "${fetched}"; then
      current_key=$(keyring_key "${fetched}" "${entity}" || true)
    fi
  fi

  if [[ -z "${current_key}" ]]; then
    echo "WARNING- unable to read ${entity} key, skipping ${entity} key type check"
    return 0
  fi

  if [[ "${#current_key}" -eq "${expected_length}" ]]; then
    return 0
  fi

  echo "${entity} key length does not match desired type ${key_type}, rotating key"
  local rotated="${tmpdir}/entity.rotated.keyring"
  if rotate_entity_key "${entity}" "${rotated}" "${key_type}"; then
    patch_secret_keyring "${secret_name}" "${secret_data_key}" "${rotated}" || \
      echo "WARNING- failed to patch ${entity} keyring Secret, continuing"
    for refresh_file in "${refresh_files[@]}"; do
      if [[ -n "${refresh_file}" ]]; then
        mkdir -p "$(dirname "${refresh_file}")"
        cp -vf "${rotated}" "${refresh_file}" || \
          echo "WARNING- failed to refresh local ${entity} keyring, continuing"
        chown ceph. "${refresh_file}" 2>/dev/null || true
        chmod 0600 "${refresh_file}" 2>/dev/null || true
      fi
    done
  else
    echo "WARNING- failed to rotate ${entity} key, keeping existing key"
  fi
  return 0
}
`}}
{{- end -}}
