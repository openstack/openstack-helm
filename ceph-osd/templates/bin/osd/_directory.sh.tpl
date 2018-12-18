#!/bin/bash
set -ex
export LC_ALL=C
: "${HOSTNAME:=$(uname -n)}"
: "${CRUSH_LOCATION:=root=default host=${HOSTNAME}}"
: "${OSD_PATH_BASE:=/var/lib/ceph/osd/${CLUSTER}}"
: "${JOURNAL_DIR:=/var/lib/ceph/journal}"
: "${OSD_BOOTSTRAP_KEYRING:=/var/lib/ceph/bootstrap-osd/${CLUSTER}.keyring}"

eval OSD_PG_INTERVAL_FIX=$(cat /etc/ceph/storage.json | python -c 'import sys, json; data = json.load(sys.stdin); print(json.dumps(data["osd_pg_interval_fix"]))')
eval CRUSH_FAILURE_DOMAIN_TYPE=$(cat /etc/ceph/storage.json | python -c 'import sys, json; data = json.load(sys.stdin); print(json.dumps(data["failure_domain"]))')
eval CRUSH_FAILURE_DOMAIN_NAME=$(cat /etc/ceph/storage.json | python -c 'import sys, json; data = json.load(sys.stdin); print(json.dumps(data["failure_domain_name"]))')
eval CRUSH_FAILURE_DOMAIN_BY_HOSTNAME=$(cat /etc/ceph/storage.json | python -c 'import sys, json; data = json.load(sys.stdin); print(json.dumps(data["failure_domain_by_hostname"]))')

function is_available {
  command -v $@ &>/dev/null
}
if is_available rpm; then
  OS_VENDOR=redhat
  source /etc/sysconfig/ceph
elif is_available dpkg; then
  OS_VENDOR=ubuntu
  source /etc/default/ceph
fi

if [[ $(ceph -v | egrep -q "12.2|luminous"; echo $?) -ne 0 ]]; then
    echo "ERROR- need Luminous release"
    exit 1
fi

if [[ ! -d /var/lib/ceph/osd ]]; then
  echo "ERROR- could not find the osd directory, did you bind mount the OSD data directory?"
  echo "ERROR- use -v <host_osd_data_dir>:/var/lib/ceph/osd"
  exit 1
fi

if [ -z "${HOSTNAME}" ]; then
  echo "HOSTNAME not set; This will prevent to add an OSD into the CRUSH map"
  exit 1
fi

# check if anything is present, if not, create an osd and its directory
if [[ -n "$(find /var/lib/ceph/osd -prune -empty)" ]]; then
  echo "Creating osd"
  UUID=$(uuidgen)
  OSD_SECRET=$(ceph-authtool --gen-print-key)
  OSD_ID=$(echo "{\"cephx_secret\": \"${OSD_SECRET}\"}" | ceph osd new ${UUID} -i - -n client.bootstrap-osd -k "$OSD_BOOTSTRAP_KEYRING")

  # test that the OSD_ID is an integer
  if [[ "$OSD_ID" =~ ^-?[0-9]+$ ]]; then
    echo "OSD created with ID: ${OSD_ID}"
  else
    echo "OSD creation failed: ${OSD_ID}"
    exit 1
  fi

  OSD_PATH="$OSD_PATH_BASE-$OSD_ID/"
  if [ -n "${JOURNAL_DIR}" ]; then
     OSD_J="${JOURNAL_DIR}/journal.${OSD_ID}"
     chown -R ceph. ${JOURNAL_DIR}
  else
     if [ -n "${JOURNAL}" ]; then
        OSD_J=${JOURNAL}
        chown -R ceph. $(dirname ${JOURNAL_DIR})
     else
        OSD_J=${OSD_PATH%/}/journal
     fi
  fi
  # create the folder and own it
  mkdir -p "${OSD_PATH}"
  chown "${CHOWN_OPT[@]}" ceph. "${OSD_PATH}"
  echo "created folder ${OSD_PATH}"
  # write the secret to the osd keyring file
  ceph-authtool --create-keyring ${OSD_PATH%/}/keyring --name osd.${OSD_ID} --add-key ${OSD_SECRET}
  OSD_KEYRING="${OSD_PATH%/}/keyring"
  # init data directory
  ceph-osd -i ${OSD_ID} --mkfs --osd-uuid ${UUID} --mkjournal --osd-journal ${OSD_J} --setuser ceph --setgroup ceph
  # add the osd to the crush map
  # NOTE(supamatt): set the initial crush weight of the OSD to 0 to prevent automatic rebalancing
  OSD_WEIGHT=0
  function crush_create_or_move {
    local crush_location=${1}
    ceph --cluster "${CLUSTER}" --name="osd.${OSD_ID}" --keyring="${OSD_KEYRING}" \
      osd crush create-or-move -- "${OSD_ID}" "${OSD_WEIGHT}" ${crush_location} || true
  }
  function crush_add_and_move {
    local crush_failure_domain_type=${1}
    local crush_failure_domain_name=${2}
    local crush_location=$(echo "root=default ${crush_failure_domain_type}=${crush_failure_domain_name} host=${HOSTNAME}")
    crush_create_or_move "${crush_location}"
    local crush_failure_domain_location_check=$(ceph --cluster "${CLUSTER}" --name="osd.${OSD_ID}" --keyring="${OSD_KEYRING}" osd find ${OSD_ID} | grep "${crush_failure_domain_type}" | awk -F '"' '{print $4}')
    if [ "x${crush_failure_domain_location_check}" != "x${crush_failure_domain_name}" ];  then
      # NOTE(supamatt): Manually move the buckets for previously configured CRUSH configurations
      # as create-or-move may not appropiately move them.
      ceph --cluster "${CLUSTER}" --name="osd.${OSD_ID}" --keyring="${OSD_KEYRING}" \
        osd crush add-bucket "${crush_failure_domain_name}" "${crush_failure_domain_type}" || true
      ceph --cluster "${CLUSTER}" --name="osd.${OSD_ID}" --keyring="${OSD_KEYRING}" \
        osd crush move "${crush_failure_domain_name}" root=default || true
      ceph --cluster "${CLUSTER}" --name="osd.${OSD_ID}" --keyring="${OSD_KEYRING}" \
        osd crush move "${HOSTNAME}" "${crush_failure_domain_type}=${crush_failure_domain_name}" || true
    fi
  }
  if [ "x${CRUSH_FAILURE_DOMAIN_TYPE}" != "xhost" ]; then
    if [ "x${CRUSH_FAILURE_DOMAIN_NAME}" != "xfalse" ]; then
      crush_add_and_move "${CRUSH_FAILURE_DOMAIN_TYPE}" "${CRUSH_FAILURE_DOMAIN_NAME}"
    elif [ "x${CRUSH_FAILURE_DOMAIN_BY_HOSTNAME}" != "xfalse" ]; then
      crush_add_and_move "${CRUSH_FAILURE_DOMAIN_TYPE}" "$(echo ${CRUSH_FAILURE_DOMAIN_TYPE}_$(echo ${HOSTNAME} | cut -c ${CRUSH_FAILURE_DOMAIN_BY_HOSTNAME}))"
    else
      # NOTE(supamatt): neither variables are defined then we fall back to default behavior
      crush_create_or_move "${CRUSH_LOCATION}"
    fi
  else
    crush_create_or_move "${CRUSH_LOCATION}"
  fi
fi

# create the directory and an empty Procfile
mkdir -p /etc/forego/"${CLUSTER}"
echo "" > /etc/forego/"${CLUSTER}"/Procfile

# NOTE(supamatt): https://tracker.ceph.com/issues/21142 is impacting us due to the older Ceph version 12.2.3 that we are running
if [ "x${OSD_PG_INTERVAL_FIX}" == "xtrue" ]; then
  for PG in $(ls ${OSD_PATH}/current | awk -F'_' '/head/{print $1}'); do
    ceph-objectstore-tool --data-path ${OSD_PATH} --op rm-past-intervals --pgid ${PG};
  done
fi

for OSD_ID in $(ls /var/lib/ceph/osd | sed 's/.*-//'); do
  OSD_PATH="$OSD_PATH_BASE-$OSD_ID/"
  OSD_KEYRING="${OSD_PATH%/}/keyring"
  if [ -n "${JOURNAL_DIR}" ]; then
     OSD_J="${JOURNAL_DIR}/journal.${OSD_ID}"
     chown -R ceph. ${JOURNAL_DIR}
  else
     if [ -n "${JOURNAL}" ]; then
        OSD_J=${JOURNAL}
        chown -R ceph. $(dirname ${JOURNAL_DIR})
     else
        OSD_J=${OSD_PATH%/}/journal
     fi
  fi
  # log osd filesystem type
  FS_TYPE=`stat --file-system -c "%T" ${OSD_PATH}`
  echo "OSD $OSD_PATH filesystem type: $FS_TYPE"
  echo "${CLUSTER}-${OSD_ID}: /usr/bin/ceph-osd --cluster ${CLUSTER} -f -i ${OSD_ID} --osd-journal ${OSD_J} -k $OSD_KEYRING" | tee -a /etc/forego/"${CLUSTER}"/Procfile
done

exec /usr/local/bin/forego start -f /etc/forego/"${CLUSTER}"/Procfile
