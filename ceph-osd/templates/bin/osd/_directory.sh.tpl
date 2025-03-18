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

set -ex
export LC_ALL=C

source /tmp/osd-common-ceph-volume.sh

: "${JOURNAL_DIR:=/var/lib/ceph/journal}"

if [[ ! -d /var/lib/ceph/osd ]]; then
  echo "ERROR- could not find the osd directory, did you bind mount the OSD data directory?"
  echo "ERROR- use -v <host_osd_data_dir>:/var/lib/ceph/osd"
  exit 1
fi

# check if anything is present, if not, create an osd and its directory
if [[ -n "$(find /var/lib/ceph/osd -type d  -empty ! -name "lost+found")" ]]; then
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
     OSD_JOURNAL="${JOURNAL_DIR}/journal.${OSD_ID}"
     chown -R ceph. ${JOURNAL_DIR}
  else
     if [ -n "${JOURNAL}" ]; then
        OSD_JOURNAL=${JOURNAL}
        chown -R ceph. $(dirname ${JOURNAL_DIR})
     else
        OSD_JOURNAL=${OSD_PATH%/}/journal
     fi
  fi
  # create the folder and own it
  mkdir -p "${OSD_PATH}"
  echo "created folder ${OSD_PATH}"
  # write the secret to the osd keyring file
  ceph-authtool --create-keyring ${OSD_PATH%/}/keyring --name osd.${OSD_ID} --add-key ${OSD_SECRET}
  chown -R "${CHOWN_OPT[@]}" ceph. "${OSD_PATH}"
  OSD_KEYRING="${OSD_PATH%/}/keyring"
  # init data directory
  ceph-osd -i ${OSD_ID} --mkfs --osd-uuid ${UUID} --mkjournal --osd-journal ${OSD_JOURNAL} --setuser ceph --setgroup ceph
  # add the osd to the crush map
  crush_location
fi

for OSD_ID in $(ls /var/lib/ceph/osd | sed 's/.*-//'); do
  # NOTE(gagehugo): Writing the OSD_ID to tmp for logging
  echo "${OSD_ID}" > /tmp/osd-id
  OSD_PATH="$OSD_PATH_BASE-$OSD_ID/"
  OSD_KEYRING="${OSD_PATH%/}/keyring"
  if [ -n "${JOURNAL_DIR}" ]; then
     OSD_JOURNAL="${JOURNAL_DIR}/journal.${OSD_ID}"
     chown -R ceph. ${JOURNAL_DIR}
  else
     if [ -n "${JOURNAL}" ]; then
        OSD_JOURNAL=${JOURNAL}
        chown -R ceph. $(dirname ${JOURNAL_DIR})
     else
        OSD_JOURNAL=${OSD_PATH%/}/journal
        chown ceph. ${OSD_JOURNAL}
     fi
  fi
  # log osd filesystem type
  FS_TYPE=`stat --file-system -c "%T" ${OSD_PATH}`
  echo "OSD $OSD_PATH filesystem type: $FS_TYPE"

  # NOTE(supamatt): Just in case permissions do not align up, we recursively set them correctly.
  if [ $(stat -c%U ${OSD_PATH}) != ceph ]; then
    chown -R ceph. ${OSD_PATH};
  fi

  crush_location
done

exec /usr/bin/ceph-osd \
    --cluster ${CLUSTER} \
    -f \
    -i ${OSD_ID} \
    --osd-journal ${OSD_JOURNAL} \
    -k ${OSD_KEYRING}
    --setuser ceph \
    --setgroup disk $! > /run/ceph-osd.pid
