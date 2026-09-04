#!/bin/bash

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

export LC_ALL=C

: "${CLUSTER:=ceph}"
: "${ADMIN_KEYRING:=/etc/ceph/${CLUSTER}.client.admin.keyring}"

# Desired mon key type, taken from `conf.keyring.bootstrap.key_type` in
# values.yaml. An empty value means the mon key type check is skipped (e.g.
# for Ceph releases predating the `--key-type` option added in 20.2.4).
DESIRED_MON_KEY_TYPE="{{ .Values.conf.keyring.bootstrap.key_type | default "" }}"

# Desired bootstrap key type, taken from the same value. An empty value
# means the bootstrap key rotation is skipped.
DESIRED_BOOTSTRAP_KEY_TYPE="{{ .Values.conf.keyring.bootstrap.key_type | default "" }}"

{{- $monSecret := .Values.secrets.keyrings.mon }}
{{- $mgrSecret := .Values.secrets.keyrings.mgr }}
{{- $mdsSecret := .Values.secrets.keyrings.mds }}
{{- $osdSecret := .Values.secrets.keyrings.osd }}
{{- $adminSecret := .Values.secrets.keyrings.admin }}

{{ include "helm-toolkit.snippets.ceph_key_rotation" . }}

if [[ ! -f /etc/ceph/${CLUSTER}.conf ]]; then
  echo "ERROR- /etc/ceph/${CLUSTER}.conf must exist; get it from your existing mon"
  exit 1
fi

if [[ ! -f ${ADMIN_KEYRING} ]]; then
   echo "ERROR- ${ADMIN_KEYRING} must exist; get it from your existing mon"
   exit 1
fi

# Pick the admin keyring the rest of this job authenticates with. The admin
# keyring Secret is mounted read-only with a subPath, so it is never refreshed
# in this pod: when the storage key was replaced by the aes-storage-keys job,
# the mounted keyring may no longer be accepted by the cluster. In that case
# fall back to the previous keyring kept alongside the current one in the admin
# keyring Secret by that job, so an interrupted storage key replacement is
# repaired instead of failing this job forever. Any later ceph call in this job
# uses ${ADMIN_KEYRING}, which is repointed at the fallback copy.
function select_admin_keyring () {
  if timeout 15 ceph --cluster "${CLUSTER}" --name client.admin \
      --keyring "${ADMIN_KEYRING}" status >/dev/null 2>&1; then
    return 0
  fi

  local previous="" jsonpath_key="ceph\\.client\\.admin\\.keyring\\.previous" fallback=""
  previous=$(kubectl --namespace "${NAMESPACE}" get secret "{{ $adminSecret }}" \
    -o "jsonpath={.data.${jsonpath_key}}" 2>/dev/null || true)
  [[ -n "${previous}" ]] || return 0
  fallback=$(mktemp) || return 0
  if ! printf '%s' "${previous}" | base64 -d > "${fallback}" 2>/dev/null; then
    rm -f "${fallback}"
    return 0
  fi
  # ceph-authtool rejects a keyring whose last line has no newline.
  if [[ -n "$(tail -c 1 "${fallback}")" ]]; then
    printf '\n' >> "${fallback}"
  fi
  if ! timeout 15 ceph --cluster "${CLUSTER}" --name client.admin \
      --keyring "${fallback}" status >/dev/null 2>&1; then
    rm -f "${fallback}"
    return 0
  fi

  echo "WARNING- the admin keyring ${ADMIN_KEYRING} does not authenticate, using the previous keyring kept in Secret {{ $adminSecret }}"
  ADMIN_KEYRING="${fallback}"
}

select_admin_keyring

ceph --cluster ${CLUSTER}  -s
function wait_for_pods() {
  timeout=${2:-1800}
  end=$(date -ud "${timeout} seconds" +%s)
  # Selecting containers with "ceph-mon" name and
  # counting them based on "ready" field.
  count_pods=".items | map(.status.containerStatuses | .[] | \
              select(.name==\"ceph-mon\")) | \
              group_by(.ready) | map({(.[0].ready | tostring): length}) | .[]"
  min_mons="add | if .true >= (.false + .true) \
           then \"pass\" else \"fail\" end"
  while true; do
      # Leave while loop if all mons are ready.
      state=$(kubectl get pods --namespace="${1}" -l component=mon -o json | jq "${count_pods}")
      mon_state=$(jq -s "${min_mons}" <<< "${state}")
      if [[ "${mon_state}" == \"pass\" ]]; then
        break
      fi
      sleep 5

      if [ $(date -u +%s) -gt $end ] ; then
          echo -e "Containers failed to start after $timeout seconds\n"
          kubectl get pods --namespace "${1}" -o wide -l component=mon
          exit 1
      fi
  done
}

# Return 0 only when every mon in the monmap is in the quorum, i.e. no mon is
# down or out of quorum. If no mon can be reached at all, quorum_status fails
# and the quorum is treated as degraded. Restarts must never begin while any
# mon is down: deleting a mon pod on an already degraded quorum can tip it
# below majority and block all cluster I/O.
function wait_for_healthy_quorum () {
  local wait_timeout=${1:-${QUORUM_WAIT_TIMEOUT:-1800}}
  local end=$(date -ud "${wait_timeout} seconds" +%s)
  local all_up=""
  while true; do
      all_up=$(timeout 15 ceph --cluster "${CLUSTER}" --name client.admin --keyring "${ADMIN_KEYRING}" \
          quorum_status --format json 2>/dev/null | \
          jq -e '(.quorum_names | length) == (.monmap.mons | length)' 2>/dev/null) || all_up=""
      if [[ "${all_up}" == "true" ]]; then
        echo "All mons are up and in quorum"
        return 0
      fi
      sleep 5

      if [ $(date -u +%s) -gt $end ] ; then
          echo -e "ERROR- mon quorum failed to reach a healthy state (all mons up) after ${wait_timeout} seconds\n"
          ceph --cluster "${CLUSTER}" -s
          kubectl get pods --namespace "${CEPH_NAMESPACE}" -o wide -l component=mon
          exit 1
      fi
  done
}

function check_ds() {
 for ds in `kubectl get ds --namespace=$CEPH_NAMESPACE -l component=mon --no-headers=true|awk '{print $1}'`
 do
   ds_query=`kubectl get ds -n $CEPH_NAMESPACE $ds -o json|jq -r .status`
   if echo $ds_query |grep -i "numberAvailable" ;then
     currentNumberScheduled=`echo $ds_query|jq -r .currentNumberScheduled`
     desiredNumberScheduled=`echo $ds_query|jq -r .desiredNumberScheduled`
     numberAvailable=`echo $ds_query|jq -r .numberAvailable`
     numberReady=`echo $ds_query|jq -r .numberReady`
     updatedNumberScheduled=`echo $ds_query|jq -r .updatedNumberScheduled`
     ds_check=`echo "$currentNumberScheduled $desiredNumberScheduled $numberAvailable $numberReady $updatedNumberScheduled"| \
       tr ' ' '\n'|sort -u|wc -l`
     if [ $ds_check != 1 ]; then
       echo "Some pods in daemonset $ds are not ready"
       exit
     else
       echo "All pods in deamonset $ds are ready"
     fi
   else
     echo "There are no mons under daemonset $ds"
   fi
 done
}

function restart_mons() {
  # Never begin restarting mons while any mon is down.
  wait_for_healthy_quorum

  mon_pods=`kubectl get po -n $CEPH_NAMESPACE -l component=mon --no-headers | awk '{print $1}'`

  for pod in ${mon_pods}
  do
    if [[ -n "$pod" ]]; then
      echo "Restarting pod $pod"
      kubectl delete pod -n $CEPH_NAMESPACE $pod
    fi
    if [[ "$DISRUPTIVE_MON_RESTART" != "true" ]]; then
      echo "Waiting for the pod $pod to restart"
      # The pod will not be ready in first 60 seconds. Thus we can reduce
      # amount of queries to kubernetes.
      sleep 60
      wait_for_pods $CEPH_NAMESPACE
      # A Ready pod is not enough: do not touch the next mon until every mon
      # in the monmap, including the one just restarted, is back in quorum.
      wait_for_healthy_quorum
      ceph -s
    fi
  done
}

# Wait until all ceph-mgr pods are ready again after a restart.
function wait_for_mgr_pods () {
  namespace="$1"
  timeout=${2:-1800}
  end=$(date -ud "${timeout} seconds" +%s)

  while true; do
      if ! kubectl get deployment ceph-mgr --namespace="${namespace}" >/dev/null 2>&1; then
        echo "ceph-mgr deployment not found, skipping wait"
        break
      fi
      desired=`kubectl get deployment ceph-mgr --namespace="${namespace}" -o jsonpath='{.spec.replicas}'`
      ready=`kubectl get pods --namespace="${namespace}" -l component=mgr -o json | \
        jq '[.items[].status.containerStatuses[]? | select(.name=="ceph-mgr") | select(.ready)] | length'`
      if [[ -n "${desired}" ]] && [[ -n "${ready}" ]] && [[ "${ready}" -ge "${desired}" ]]; then
        break
      fi
      sleep 5

      if [ $(date -u +%s) -gt $end ] ; then
          echo -e "ceph-mgr containers failed to start after $timeout seconds\n"
          kubectl get pods --namespace "${namespace}" -o wide -l component=mgr
          exit 1
      fi
  done
}

# Restart every ceph-mgr pod one at a time, waiting for the deployment to
# become ready again after each pod.
function restart_mgrs_serially () {
  # Never begin restarting mgrs while any mon is down.
  wait_for_healthy_quorum

  mgr_pods=`kubectl get po -n $CEPH_NAMESPACE -l component=mgr --no-headers | awk '{print $1}'`

  for pod in ${mgr_pods}
  do
    if [[ -n "$pod" ]]; then
      echo "Restarting pod $pod"
      kubectl delete pod -n $CEPH_NAMESPACE $pod
    fi
    echo "Waiting for the pod $pod to restart"
    # The pod will not be ready in first 60 seconds. Thus we can reduce
    # amount of queries to kubernetes.
    sleep 60
    wait_for_mgr_pods $CEPH_NAMESPACE
    ceph -s
  done
}

# Return 0 when the cluster-side key for <entity> already matches the desired
# key type (a secure key), 1 when the key exists but has the wrong length and
# 2 when the state cannot be determined. Key material is never echoed.
# Usage: entity_key_type_state <entity> <desired-key_type>
function entity_key_type_state () {
  local entity="$1"
  local key_type="$2"
  local expected_length="" current_key="" tmpdir="" rc=0 xtrace=0

  expected_length=$(key_type_length "${key_type}" || true)
  if [[ -z "${expected_length}" || ! -e "${ADMIN_KEYRING}" ]]; then
    return 2
  fi

  tmpdir=$(mktemp -d) || return 2
  [[ "${-}" == *x* ]] && xtrace=1
  # Self-clearing: fires on this function's return, then removes itself so
  # it never runs again inside a later function with stale locals.
  trap '[[ -n "${tmpdir:-}" ]] && rm -rf "${tmpdir}" || true; [[ "${xtrace:-0}" -eq 1 ]] && set -x || true; trap - RETURN' RETURN

  # Set +x for the key handling below: key material must never leak through
  # tracing. The RETURN trap above restores tracing on every return path.
  set +x
  if ! timeout 15 ceph --cluster "${CLUSTER}" --name client.admin --keyring "${ADMIN_KEYRING}" \
      auth get "${entity}" -o "${tmpdir}/entity.keyring" >/dev/null 2>&1; then
    # Entity does not exist yet or the cluster cannot be reached.
    return 2
  fi

  current_key=$(keyring_key "${tmpdir}/entity.keyring" "${entity}" || true)
  if [[ -z "${current_key}" ]]; then
    return 2
  fi
  if [[ "${#current_key}" -ne "${expected_length}" ]]; then
    rc=1
  fi
  return "${rc}"
}

# Rotate the shared mon key (mon.) to the mon key type configured via
# conf.keyring.bootstrap.key_type, and keep the mon keyring Secret in step with
# the mon. key of the cluster. Key material is never echoed.
#
# The mon key may only be rotated while every mon is up and in quorum, and the
# mons must not be restarted before the rotation has been committed everywhere.
# The mons authenticate to each other with the mon. key held in their own auth
# database (the keyring file is only a fallback, which the msgr1 connections
# used between the mons never use), and a database can only receive a new key
# from the quorum. A mon which is down while the key is rotated -- for example
# one rotating the key from its own start script -- keeps the old key in its
# database: the quorum and that mon then reject each other's authorizers
# ("could not decrypt ticket info"), and the mon can neither rejoin nor sync.
# The running mons carry on authenticating with the key in their database, so
# no mon restart is needed; the keyring Secret is patched so that a mon which
# starts later takes the new key. The key type is passed to `ceph auth rotate`,
# so the new key has the desired type whatever the monmap ciphers are.
function reconcile_mon_key () {
  local expected_length="" tmpdir="" xtrace=0 cluster_key="" secret_key=""

  [[ -n "${DESIRED_MON_KEY_TYPE}" ]] || return 0
  expected_length=$(key_type_length "${DESIRED_MON_KEY_TYPE}" || true)
  [[ -n "${expected_length}" ]] || return 0

  tmpdir=$(mktemp -d) || { echo "WARNING- unable to create temp dir, skipping the mon key check"; return 0; }
  [[ "${-}" == *x* ]] && xtrace=1
  # Self-clearing: fires on this function's return, then removes itself so
  # it never runs again inside a later function with stale locals.
  trap '[[ -n "${tmpdir:-}" ]] && rm -rf "${tmpdir}" || true; [[ "${xtrace:-0}" -eq 1 ]] && set -x || true; trap - RETURN' RETURN

  # Set +x for the key handling below: key material must never leak through
  # tracing. The RETURN trap above restores tracing on every return path.
  set +x

  # Every mon has to be up and in quorum before the key is touched.
  wait_for_healthy_quorum

  if ! timeout 15 ceph --cluster "${CLUSTER}" --name client.admin --keyring "${ADMIN_KEYRING}" \
      auth get "mon." -o "${tmpdir}/cluster.keyring" >/dev/null 2>&1; then
    echo "WARNING- unable to read the mon. key from the cluster, skipping the mon key check"
    return 0
  fi
  cluster_key=$(keyring_key "${tmpdir}/cluster.keyring" "mon." || true)
  if [[ -z "${cluster_key}" ]]; then
    echo "WARNING- unable to read the mon. key from the cluster, skipping the mon key check"
    return 0
  fi

  if [[ "${#cluster_key}" -ne "${expected_length}" ]]; then
    echo "mon. key length does not match desired type ${DESIRED_MON_KEY_TYPE}, rotating key"
    if ! rotate_entity_key "mon." "${tmpdir}/cluster.keyring" "${DESIRED_MON_KEY_TYPE}"; then
      echo "WARNING- failed to rotate the mon. key, keeping the existing key"
      return 0
    fi
    cluster_key=$(keyring_key "${tmpdir}/cluster.keyring" "mon." || true)
    if [[ -z "${cluster_key}" ]]; then
      echo "WARNING- unable to read the rotated mon. key, the mon keyring Secret is updated on the next run"
      return 0
    fi
    # Do not let anything touch the mons before the rotation has been
    # committed everywhere.
    wait_for_healthy_quorum
  fi

  if secret_keyring "{{ $monSecret }}" "ceph.mon.keyring" "${tmpdir}/secret.keyring"; then
    secret_key=$(keyring_key "${tmpdir}/secret.keyring" "mon." || true)
  fi
  if [[ "${secret_key}" != "${cluster_key}" ]]; then
    echo "Updating the mon keyring Secret with the mon. key of the cluster"
    patch_secret_keyring "{{ $monSecret }}" "ceph.mon.keyring" "${tmpdir}/cluster.keyring" || \
      echo "WARNING- failed to patch the mon keyring Secret, continuing"
  fi
  return 0
}

# Echo the manager daemon names reported by the cluster. These match the
# mgr.<hostname> entities created by the manager start script.
function mgr_daemon_names () {
  timeout 15 ceph --cluster "${CLUSTER}" --name client.admin --keyring "${ADMIN_KEYRING}" \
    mgr dump --format json 2>/dev/null | jq -r '.active_name, (.standbys[]?.name)' 2>/dev/null
}

# Return 0 when any manager key (mgr.<name>) still has to be rotated to the
# cipher configured on the monmap (conf.auth_ciphers.auth-service-cipher).
function mgr_key_needs_rotation () {
  local key_type="" name="" rc=2
  key_type=$(get_monmap_cipher auth_service_cipher)
  [[ -n "${key_type}" ]] || return 1
  for name in $(mgr_daemon_names); do
    [[ -n "${name}" ]] || continue
    rc=2
    entity_key_type_state "mgr.${name}" "${key_type}" || rc=$?
    [[ "${rc}" -eq 1 ]] && return 0
  done
  return 1
}

# Rotate the client.bootstrap-mgr, client.bootstrap-mds and client.bootstrap-osd
# keys to the bootstrap key type configured via conf.keyring.bootstrap.key_type
# and patch the rotated keyrings back into the bootstrap keyring Secrets. Runs
# after the mon upgrade pass above and before the key rotation pass below, so
# the mons which start later mount the already-rotated Secrets and never
# rotate the bootstrap keys themselves. The current keys are read from the
# keyring Secrets (this job has no local keyring files) and each rotation is
# tempered by the shared quorum-version check; keys already matching the
# desired type are skipped, so this is a no-op once everything is converged.
function rotate_bootstrap_keys () {
  if [[ -z "${DESIRED_BOOTSTRAP_KEY_TYPE}" ]]; then
    echo "No desired bootstrap key type configured, skipping the bootstrap key rotation"
    return 0
  fi
  check_secret_entity_key_type "client.bootstrap-mgr" "${DESIRED_BOOTSTRAP_KEY_TYPE}" "{{ $mgrSecret }}" "ceph.keyring"
  check_secret_entity_key_type "client.bootstrap-mds" "${DESIRED_BOOTSTRAP_KEY_TYPE}" "{{ $mdsSecret }}" "ceph.keyring"
  check_secret_entity_key_type "client.bootstrap-osd" "${DESIRED_BOOTSTRAP_KEY_TYPE}" "{{ $osdSecret }}" "ceph.keyring"
}

# After the mon pods have been restarted, give any daemon that could not
# rotate its CephX key yet another chance. Rotation is only possible once
# every mon in the quorum runs at least KEY_ROTATION_MIN_CEPH_VERSION
# (default 20.2.4), so daemons which started before the quorum finished
# upgrading still hold legacy (insecure) keys. The mon key is rotated in place,
# without restarting the mons (see reconcile_mon_key); when an insecure mgr key
# is found, the mgr pods are restarted one at a time so that they can retry the
# rotation without disrupting the cluster.
function reconcile_key_rotation () {
  if ! mon_quorum_supports_key_rotation "${KEY_ROTATION_MIN_CEPH_VERSION}"; then
    echo "Not all mons in quorum run Ceph ${KEY_ROTATION_MIN_CEPH_VERSION} or later, skipping the key rotation pass"
    return 0
  fi

  reconcile_mon_key

  if mgr_key_needs_rotation; then
    echo "A ceph-mgr key is still insecure, restarting the mgr pods one at a time to allow key rotation"
    restart_mgrs_serially
    if mgr_key_needs_rotation; then
      echo "WARNING- at least one ceph-mgr key is still insecure after restarting the mgr pods"
    fi
  fi
}

wait_for_pods $CEPH_NAMESPACE

require_upgrade=0
max_release=0

for ds in `kubectl get ds --namespace=$CEPH_NAMESPACE -l component=mon --no-headers=true|awk '{print $1}'`
do
  updatedNumberScheduled=`kubectl get ds -n $CEPH_NAMESPACE $ds -o json|jq -r .status.updatedNumberScheduled`
  desiredNumberScheduled=`kubectl get ds -n $CEPH_NAMESPACE $ds -o json|jq -r .status.desiredNumberScheduled`
  if [[ $updatedNumberScheduled != $desiredNumberScheduled ]]; then
    if kubectl get ds -n $CEPH_NAMESPACE  $ds -o json|jq -r .status|grep -i "numberAvailable" ;then
      require_upgrade=$((require_upgrade+1))
      _release=`kubectl get ds -n $CEPH_NAMESPACE $ds  -o json|jq -r .status.observedGeneration`
      max_release=$(( max_release > _release ? max_release : _release ))
    fi
  fi
done

echo "Latest revision of the helm chart(s) is : $max_release"

if [[ "$UNCONDITIONAL_MON_RESTART" == "true" ]] || [[ $max_release -gt 1  ]]; then
  if [[ "$UNCONDITIONAL_MON_RESTART" == "true" ]] || [[  $require_upgrade -gt 0 ]]; then
    echo "Restart ceph-mon pods one at a time to prevent disruption"
    restart_mons
  fi

  # Check all the ceph-mon daemonsets
  echo "checking DS"
  check_ds
else
  echo "No revisions found for upgrade"
fi

# The monmap auth ciphers (conf.auth_ciphers) and the storage (client.admin)
# key (conf.keyring.storage.key_type) are reconciled by the separate
# aes-storage-keys job, enabled with manifests.aes_storage_keys, so that they
# can be configured independently of the rest of this job. That job is not
# ordered with respect to this one and may run before the mons have been
# upgraded, when it cannot publish the ciphers to the running cluster yet: the
# rotations below pass the desired key type to `ceph auth rotate` and do not
# depend on it.
#
# Rotate the bootstrap keys now that the mon upgrade pass above has finished,
# before the key rotation pass below: the mons which start later mount the
# freshly rotated keyring Secrets instead of rotating the bootstrap keys
# themselves on every restart.
rotate_bootstrap_keys

# Give the mon and the mgrs another chance to rotate their keys now that the
# whole mon quorum runs a Ceph version that supports secure keys. The mon key
# is rotated in place while every mon is up and in quorum; an mgr which was
# unable to rotate its key during the restarts above is restarted again, one at
# a time, so it can retry without disrupting the cluster.
reconcile_key_rotation
