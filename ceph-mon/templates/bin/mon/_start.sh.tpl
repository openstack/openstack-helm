#!/bin/bash
set -ex
export LC_ALL=C
: "${K8S_HOST_NETWORK:=0}"
: "${MON_KEYRING:=/etc/ceph/${CLUSTER}.mon.keyring}"
: "${ADMIN_KEYRING:=/etc/ceph/${CLUSTER}.client.admin.keyring}"
: "${MDS_BOOTSTRAP_KEYRING:=/var/lib/ceph/bootstrap-mds/${CLUSTER}.keyring}"
: "${OSD_BOOTSTRAP_KEYRING:=/var/lib/ceph/bootstrap-osd/${CLUSTER}.keyring}"
: "${CEPH_CONF:="/etc/ceph/${CLUSTER}.conf"}"

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

  # Create a monmap with the Pod Names and IP
  monmaptool --create ${MONMAP_ADD} --fsid ${fsid} ${MONMAP} --clobber
}

get_mon_config

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
  echo "Trying to get the most recent monmap..."
  # Ignore when we timeout, in most cases that means the cluster has no quorum or
  # no mons are up and running yet
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
