#!/bin/bash
set -ex
export LC_ALL=C
: "${HOSTNAME:=$(uname -n)}"
: "${CEPHFS_CREATE:=0}"
: "${CEPHFS_NAME:=cephfs}"
: "${CEPHFS_DATA_POOL:=${CEPHFS_NAME}_data}"
: "${CEPHFS_DATA_POOL_PG:=8}"
: "${CEPHFS_METADATA_POOL:=${CEPHFS_NAME}_metadata}"
: "${CEPHFS_METADATA_POOL_PG:=8}"
: "${MDS_NAME:=mds-${HOSTNAME}}"
: "${ADMIN_KEYRING:=/etc/ceph/${CLUSTER}.client.admin.keyring}"
: "${MDS_KEYRING:=/var/lib/ceph/mds/${CLUSTER}-${MDS_NAME}/keyring}"
: "${MDS_BOOTSTRAP_KEYRING:=/var/lib/ceph/bootstrap-mds/${CLUSTER}.keyring}"
: "${CEPH_CONF:="/etc/ceph/${CLUSTER}.conf"}"

{{ include "helm-toolkit.snippets.mon_host_from_k8s_ep" . }}

if [[ ! -e ${CEPH_CONF}.template ]]; then
  echo "ERROR- ${CEPH_CONF}.template must exist; get it from your existing mon"
  exit 1
else
  ENDPOINT=$(mon_host_from_k8s_ep "${NAMESPACE}" ceph-mon-discovery)
  if [[ "${ENDPOINT}" == "" ]]; then
    /bin/sh -c -e "cat ${CEPH_CONF}.template | tee ${CEPH_CONF}" || true
  else
    /bin/sh -c -e "cat ${CEPH_CONF}.template | sed 's#mon_host.*#mon_host = ${ENDPOINT}#g' | tee ${CEPH_CONF}" || true
  fi
fi

# Check to see if we are a new MDS
if [ ! -e "${MDS_KEYRING}" ]; then

  if [ -e "${ADMIN_KEYRING}" ]; then
     KEYRING_OPT=(--name client.admin --keyring "${ADMIN_KEYRING}")
  elif [ -e "${MDS_BOOTSTRAP_KEYRING}" ]; then
     KEYRING_OPT=(--name client.bootstrap-mds --keyring "${MDS_BOOTSTRAP_KEYRING}")
  else
    echo "ERROR- Failed to bootstrap MDS: could not find admin or bootstrap-mds keyring.  You can extract it from your current monitor by running 'ceph auth get client.bootstrap-mds -o ${MDS_BOOTSTRAP_KEYRING}"
    exit 1
  fi

  timeout 10 ceph --cluster "${CLUSTER}" "${KEYRING_OPT[@]}" health || exit 1

  # Generate the MDS key
  ceph --cluster "${CLUSTER}" "${KEYRING_OPT[@]}" auth get-or-create "mds.${MDS_NAME}" osd 'allow rwx' mds 'allow' mon 'allow profile mds' -o "${MDS_KEYRING}"
  chown ceph. "${MDS_KEYRING}"
  chmod 600 "${MDS_KEYRING}"

fi

# NOTE (leseb): having the admin keyring is really a security issue
# If we need to bootstrap a MDS we should probably create the following on the monitors
# I understand that this handy to do this here
# but having the admin key inside every container is a concern

# Create the Ceph filesystem, if necessary
if [ $CEPHFS_CREATE -eq 1 ]; then

  if [[ ! -e ${ADMIN_KEYRING} ]]; then
      echo "ERROR- ${ADMIN_KEYRING} must exist; get it from your existing mon"
      exit 1
  fi

  if [[ "$(ceph --cluster "${CLUSTER}" fs ls | grep -c name:.${CEPHFS_NAME},)" -eq 0 ]]; then
     # Make sure the specified data pool exists
     if ! ceph --cluster "${CLUSTER}" osd pool stats ${CEPHFS_DATA_POOL} > /dev/null 2>&1; then
        ceph --cluster "${CLUSTER}" osd pool create ${CEPHFS_DATA_POOL} ${CEPHFS_DATA_POOL_PG}
     fi

     # Make sure the specified metadata pool exists
     if ! ceph --cluster "${CLUSTER}" osd pool stats ${CEPHFS_METADATA_POOL} > /dev/null 2>&1; then
        ceph --cluster "${CLUSTER}" osd pool create ${CEPHFS_METADATA_POOL} ${CEPHFS_METADATA_POOL_PG}
     fi

     ceph --cluster "${CLUSTER}" fs new ${CEPHFS_NAME} ${CEPHFS_METADATA_POOL} ${CEPHFS_DATA_POOL}
  fi
fi

# NOTE: prefixing this with exec causes it to die (commit suicide)
/usr/bin/ceph-mds \
  --cluster "${CLUSTER}" \
  --setuser "ceph" \
  --setgroup "ceph" \
  -d \
  -i "${MDS_NAME}"
