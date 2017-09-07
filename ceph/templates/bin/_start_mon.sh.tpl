#!/bin/bash
set -ex
export LC_ALL=C

source variables_entrypoint.sh
source common_functions.sh

if [[ -z "$CEPH_PUBLIC_NETWORK" ]]; then
  log "ERROR- CEPH_PUBLIC_NETWORK must be defined as the name of the network for the OSDs"
  exit 1
fi

if [[ -z "$MON_IP" ]]; then
  log "ERROR- MON_IP must be defined as the IP address of the monitor"
  exit 1
fi

if [[ -z "$MON_IP" || -z "$CEPH_PUBLIC_NETWORK" ]]; then
  log "ERROR- it looks like we have not been able to discover the network settings"
  exit 1
fi

function get_mon_config {
  # Get fsid from ceph.conf
  local fsid=$(ceph-conf --lookup fsid -c /etc/ceph/${CLUSTER}.conf)

  timeout=10
  MONMAP_ADD=""

  while [[ -z "${MONMAP_ADD// }" && "${timeout}" -gt 0 ]]; do
    # Get the ceph mon pods (name and IP) from the Kubernetes API. Formatted as a set of monmap params
    if [[ ${K8S_HOST_NETWORK} -eq 0 ]]; then
        MONMAP_ADD=$(kubectl get pods --namespace=${NAMESPACE} -l application=ceph -l component=mon -o template --template="{{`{{range .items}}`}}{{`{{if .status.podIP}}`}}--add {{`{{.metadata.name}}`}} {{`{{.status.podIP}}`}} {{`{{end}}`}} {{`{{end}}`}}")
    else
        MONMAP_ADD=$(kubectl get pods --namespace=${NAMESPACE} -l application=ceph -l component=mon -o template --template="{{`{{range .items}}`}}{{`{{if .status.podIP}}`}}--add {{`{{.spec.nodeName}}`}} {{`{{.status.podIP}}`}} {{`{{end}}`}} {{`{{end}}`}}")
    fi
    (( timeout-- ))
    sleep 1
  done

  if [[ -z "${MONMAP_ADD// }" ]]; then
      exit 1
  fi

  # Create a monmap with the Pod Names and IP
  monmaptool --create ${MONMAP_ADD} --fsid ${fsid} $MONMAP --clobber
}

get_mon_config $IP_VERSION

# If we don't have a monitor keyring, this is a new monitor
if [ ! -e "$MON_DATA_DIR/keyring" ]; then
  if [ ! -e $MON_KEYRING ]; then
    log "ERROR- $MON_KEYRING must exist.  You can extract it from your current monitor by running 'ceph auth get mon. -o $MON_KEYRING' or use a KV Store"
    exit 1
  fi

  if [ ! -e $MONMAP ]; then
    log "ERROR- $MONMAP must exist.  You can extract it from your current monitor by running 'ceph mon getmap -o $MONMAP' or use a KV Store"
    exit 1
  fi

  # Testing if it's not the first monitor, if one key doesn't exist we assume none of them exist
  for keyring in $OSD_BOOTSTRAP_KEYRING $MDS_BOOTSTRAP_KEYRING $RGW_BOOTSTRAP_KEYRING $ADMIN_KEYRING; do
    ceph-authtool $MON_KEYRING --import-keyring $keyring
  done

  # Prepare the monitor daemon's directory with the map and keyring
  ceph-mon --setuser ceph --setgroup ceph --cluster ${CLUSTER} --mkfs -i ${MON_NAME} --inject-monmap $MONMAP --keyring $MON_KEYRING --mon-data "$MON_DATA_DIR"
else
  log "Trying to get the most recent monmap..."
  # Ignore when we timeout, in most cases that means the cluster has no quorum or
  # no mons are up and running yet
  timeout 5 ceph ${CLI_OPTS} mon getmap -o $MONMAP || true
  ceph-mon --setuser ceph --setgroup ceph --cluster ${CLUSTER} -i ${MON_NAME} --inject-monmap $MONMAP --keyring $MON_KEYRING --mon-data "$MON_DATA_DIR"
  timeout 7 ceph ${CLI_OPTS} mon add "${MON_NAME}" "${MON_IP}:6789" || true
fi

log "SUCCESS"

# start MON
exec /usr/bin/ceph-mon $DAEMON_OPTS -i ${MON_NAME} --mon-data "$MON_DATA_DIR" --public-addr "${MON_IP}:6789"
