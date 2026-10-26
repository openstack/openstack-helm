#!/bin/bash
set -ex
export LC_ALL=C
: "${K8S_HOST_NETWORK:=0}"
: "${MON_KEYRING:=/etc/ceph/${CLUSTER}.mon.keyring}"
: "${ADMIN_KEYRING:=/etc/ceph/${CLUSTER}.client.admin.keyring}"
: "${MDS_BOOTSTRAP_KEYRING:=/var/lib/ceph/bootstrap-mds/${CLUSTER}.keyring}"
: "${OSD_BOOTSTRAP_KEYRING:=/var/lib/ceph/bootstrap-osd/${CLUSTER}.keyring}"
: "${CEPH_CONF:="/etc/ceph/${CLUSTER}.conf"}"

# Desired mon key type, used below to tell which of the mon keyring Secret and
# the local mon store holds a stale key. The value comes from the
# `conf.keyring.bootstrap.key_type` value in values.yaml. An empty value means
# the type comparison is skipped. The mon key is never rotated from this
# script, see check_mon_key.
DESIRED_MON_KEY_TYPE="{{ .Values.conf.keyring.bootstrap.key_type | default "" }}"

{{ include "helm-toolkit.snippets.ceph_key_rotation" . }}

{{- $monSecret := .Values.secrets.keyrings.mon }}

{{ include "helm-toolkit.snippets.mon_host_from_k8s_ep" . }}

if [[ ! -e ${CEPH_CONF}.template ]]; then
  echo "ERROR- ${CEPH_CONF}.template must exist; get it from your existing mon"
  exit 1
else

  ENDPOINT=$(mon_host_from_k8s_ep "${NAMESPACE}" ceph-mon-discovery)

  if [[ -z "${ENDPOINT}" ]]; then
    /bin/sh -c -e "cat ${CEPH_CONF}.template | tee ${CEPH_CONF}" || true
  else
    /bin/sh -c -e "cat ${CEPH_CONF}.template | sed 's#mon_host.*#mon_host = ${ENDPOINT}#g' | tee ${CEPH_CONF}" || true
  fi
fi

if [[ -z "$CEPH_PUBLIC_NETWORK" ]]; then
  echo "ERROR- CEPH_PUBLIC_NETWORK must be defined as the name of the network for the OSDs"
  exit 1
fi

if [[ -z "$MON_IP" ]]; then
  echo "ERROR- MON_IP must be defined as the IP address of the monitor"
  exit 1
fi

if [[ ${K8S_HOST_NETWORK} -eq 0 ]]; then
    MON_NAME=${POD_NAME}
else
    MON_NAME=${NODE_NAME}
fi
MON_DATA_DIR="/var/lib/ceph/mon/${CLUSTER}-${MON_NAME}"
MONMAP="/etc/ceph/monmap-${CLUSTER}"

# Make the monitor directory
/bin/sh -c "mkdir -p \"${MON_DATA_DIR}\""

function get_mon_config {
  # Get fsid from ceph.conf
  local fsid=$(ceph-conf --lookup fsid -c /etc/ceph/${CLUSTER}.conf)

  timeout=10
  MONMAP_ADD=""

  while [[ -z "${MONMAP_ADD// }" && "${timeout}" -gt 0 ]]; do
    # Get the ceph mon pods (name and IP) from the Kubernetes API. Formatted as a set of monmap params
    if [[ ${K8S_HOST_NETWORK} -eq 0 ]]; then
        MONMAP_ADD=$(kubectl get pods --namespace=${NAMESPACE} ${KUBECTL_PARAM} -o template --template="{{`{{range .items}}`}}{{`{{if .status.podIP}}`}}--addv {{`{{.metadata.name}}`}} [v1:{{`{{.status.podIP}}`}}:${MON_PORT},v2:{{`{{.status.podIP}}`}}:${MON_PORT_V2}] {{`{{end}}`}} {{`{{end}}`}}")
    else
        MONMAP_ADD=$(kubectl get pods --namespace=${NAMESPACE} ${KUBECTL_PARAM} -o template --template="{{`{{range .items}}`}}{{`{{if .status.podIP}}`}}--addv {{`{{.spec.nodeName}}`}} [v1:{{`{{.status.podIP}}`}}:${MON_PORT},v2:{{`{{.status.podIP}}`}}:${MON_PORT_V2}] {{`{{end}}`}} {{`{{end}}`}}")
    fi
    (( timeout-- ))
    sleep 1
  done

  if [[ -z "${MONMAP_ADD// }" ]]; then
      exit 1
  fi

  # Create a monmap with the Pod Names, the IP and the CephX ciphers
  # configured via `conf.auth_ciphers`. Left to itself `monmaptool --create`
  # applies the ciphers defaulted by the local Ceph release, which on
  # Tentacle 20.2.4 allows aes256k only: a mon building its store from this
  # monmap (a new mon, or any mon while no quorum is reachable and the monmap
  # cannot be refreshed from a live quorum) would then reject the legacy aes
  # keys still in use during the transition. The aes-storage-keys job
  # reconciles the running monmap with the same values with `ceph mon set`.
  #
  # Each key of the `auth_ciphers` map is a monmaptool auth cipher option
  # name without the leading dashes (underscores are accepted in place of the
  # hyphens) and is rendered here as one argument pair, so any, all or none of
  # the ciphers may be configured. The options are passed unguarded: on a Ceph
  # release predating them (Squid before 19.2.6, Tentacle before 20.2.4)
  # `auth_ciphers` must be set to null or monmaptool rejects the unknown
  # options and the monmap is not created.
  local monmap_cipher_args=(
{{- range $key, $value := (default dict .Values.conf.auth_ciphers) }}
{{- if $value }}
    --{{ $key | replace "_" "-" }} {{ $value | quote }}
{{- end }}
{{- end }}
  )

  if [[ "${#monmap_cipher_args[@]}" -eq 0 ]]; then
    echo "No monmap auth ciphers configured, creating the monmap with the monmaptool defaults"
  else
    echo "Creating the monmap with the monmap auth ciphers: ${monmap_cipher_args[*]}"
  fi

  monmaptool --create \
    ${MONMAP_ADD} \
    --fsid ${fsid} \
    "${monmap_cipher_args[@]}" \
    ${MONMAP} \
    --clobber
}

get_mon_config

# Ensure the mon key in the local mon store matches the mon keyring Secret.
#
# The shared mon. key must NOT be rotated from here. Once the key lives in the
# auth database of the mons, mon<->mon cephx authentication uses the database
# copy (the keyring file is only a fallback, and the msgr1 connections used
# between the mons never fall back to it). This script runs while the mon is
# down, so a `ceph auth rotate mon.` issued from it changes the key in the
# database of the running quorum only: the starting mon keeps the old key in its
# own database, the quorum and the mon reject each other's authorizers
# ("could not decrypt ticket info" / BADAUTHORIZER) and the mon can never rejoin
# or sync. The key is rotated by the post-apply job instead, while every mon is
# up and in quorum.
function check_mon_key () {
  local seed_key="" store_key="" tmpdir="" xtrace=0

  tmpdir=$(mktemp -d) || { echo "WARNING- unable to create temp dir, skipping mon key check"; return 0; }
  [[ "${-}" == *x* ]] && xtrace=1
  # Self-clearing: fires on this function's return, then removes itself so
  # it never runs again inside a later function with stale locals.
  trap '[[ -n "${tmpdir:-}" ]] && rm -rf "${tmpdir}" || true; [[ "${xtrace:-0}" -eq 1 ]] && set -x || true; trap - RETURN' RETURN

  # Set +x for the key handling below: key material must never leak through
  # tracing. The RETURN trap above restores tracing on every return path.
  set +x
  seed_key=$(keyring_key "${MON_KEYRING}.seed" "mon." || true)
  store_key=$(keyring_key "${MON_DATA_DIR}/keyring" "mon." || true)

  if [[ -z "${seed_key}" ]]; then
    echo "WARNING- unable to read mon key from ${MON_KEYRING}.seed, skipping mon key check"
    return 0
  fi
  if [[ -z "${store_key}" ]]; then
    echo "WARNING- unable to read mon key from ${MON_DATA_DIR}/keyring, skipping mon key check"
    return 0
  fi

  # The mon keyring Secret is the source of truth for a newly-created mon, but
  # during a key rotation the local mon store can already contain the rotated
  # key while the Secret still holds the old one. Prefer the locally stored key
  # whenever it already matches the configured key type, otherwise the stale
  # Secret would clobber the rotated value and the mon would restart with the
  # old key material.
  if [[ "${seed_key}" != "${store_key}" ]]; then
    local desired_length=""
    desired_length=$(key_type_length "${DESIRED_MON_KEY_TYPE}" || true)
    if [[ -n "${desired_length}" && "${#store_key}" -eq "${desired_length}" && "${#seed_key}" -ne "${desired_length}" ]]; then
      echo "Mon key in Secret is stale relative to desired type ${DESIRED_MON_KEY_TYPE}, updating Secret from the mon store"
      cp -vf "${MON_DATA_DIR}/keyring" "${MON_KEYRING}"
      cp -vf "${MON_DATA_DIR}/keyring" "${MON_KEYRING}.seed"
      patch_secret_keyring "{{ $monSecret }}" "ceph.mon.keyring" "${MON_DATA_DIR}/keyring" || true
      return 0
    fi

    echo "Mon key in mon store differs from the mon keyring Secret, updating mon store from the Secret"
    cp -vf "${MON_KEYRING}.seed" "${MON_KEYRING}"
    cp -vf "${MON_KEYRING}.seed" "${MON_DATA_DIR}/keyring"
    return 0
  fi

  # Keys match, nothing to reconcile. A legacy key type is left to the
  # post-apply job, see above.
  return 0
}


# Best-effort reconciliation of the mon key. Must never block monitor
# startup. Neither the mon key nor the bootstrap keys are rotated here: they
# are rotated by the post-apply job, which patches the rotated keys into their
# keyring Secrets, so mon pods always start with the already-rotated Secrets.
function check_keyring_consistency () {
  check_mon_key || echo "WARNING- mon key check failed, continuing with startup"
}


# If we don't have a monitor keyring, this is a new monitor
if [ ! -e "${MON_DATA_DIR}/keyring" ]; then
  if [ ! -e ${MON_KEYRING}.seed ]; then
    echo "ERROR- ${MON_KEYRING}.seed must exist. You can extract it from your current monitor by running 'ceph auth get mon. -o ${MON_KEYRING}' or use a KV Store"
    exit 1
  else
    cp -vf ${MON_KEYRING}.seed ${MON_KEYRING}
  fi

  if [ ! -e ${MONMAP} ]; then
    echo "ERROR- ${MONMAP} must exist. You can extract it from your current monitor by running 'ceph mon getmap -o ${MONMAP}' or use a KV Store"
    exit 1
  fi

  # Testing if it's not the first monitor, if one key doesn't exist we assume none of them exist
  for KEYRING in ${OSD_BOOTSTRAP_KEYRING} ${MDS_BOOTSTRAP_KEYRING} ${ADMIN_KEYRING}; do
    ceph-authtool ${MON_KEYRING} --import-keyring ${KEYRING}
  done

  # Prepare the monitor daemon's directory with the map and keyring
  ceph-mon --setuser ceph --setgroup ceph --cluster "${CLUSTER}" --mkfs -i ${MON_NAME} --inject-monmap ${MONMAP} --keyring ${MON_KEYRING} --mon-data "${MON_DATA_DIR}"
else
  # Existing monitor: reconcile the mon key with the Secrets before
  # starting. Best effort only, never blocks startup.
  check_keyring_consistency
  echo "Trying to get the most recent monmap..."
  # A monmap refreshed from a live quorum already carries the cluster's cipher
  # settings. When no quorum is reachable (in most cases that means the
  # cluster has no quorum or no mons are up and running yet) reuse the monmap
  # left over from `get_mon_config` above, which was created with the ciphers
  # configured in `conf.auth_ciphers`. Best effort only, never blocks startup.
  timeout 5 ceph --cluster "${CLUSTER}" mon getmap -o ${MONMAP} || true
  ceph-mon --setuser ceph --setgroup ceph --cluster "${CLUSTER}" -i ${MON_NAME} --inject-monmap ${MONMAP} --keyring ${MON_KEYRING} --mon-data "${MON_DATA_DIR}"
  timeout 7 ceph --cluster "${CLUSTER}" mon add "${MON_NAME}" "${MON_IP}:${MON_PORT_V2}" || true
fi

# start MON
exec /usr/bin/ceph-mon \
  --cluster "${CLUSTER}" \
  --setuser "ceph" \
  --setgroup "ceph" \
  -d \
  -i ${MON_NAME} \
  --mon-data "${MON_DATA_DIR}" \
  --public-addr "${MON_IP}:${MON_PORT_V2}"
