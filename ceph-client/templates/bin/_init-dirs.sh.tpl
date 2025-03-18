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
: "${HOSTNAME:=$(uname -n)}"
: "${MGR_NAME:=${HOSTNAME}}"
: "${MDS_NAME:=mds-${HOSTNAME}}"
: "${MDS_BOOTSTRAP_KEYRING:=/var/lib/ceph/bootstrap-mds/${CLUSTER}.keyring}"
: "${OSD_BOOTSTRAP_KEYRING:=/var/lib/ceph/bootstrap-osd/${CLUSTER}.keyring}"

for keyring in ${OSD_BOOTSTRAP_KEYRING} ${MDS_BOOTSTRAP_KEYRING}; do
  mkdir -p "$(dirname "$keyring")"
done

# Let's create the ceph directories
for DIRECTORY in mds tmp mgr crash; do
  mkdir -p "/var/lib/ceph/${DIRECTORY}"
done

# Create socket directory
mkdir -p /run/ceph

# Create the MDS directory
mkdir -p "/var/lib/ceph/mds/${CLUSTER}-${MDS_NAME}"

# Create the MGR directory
mkdir -p "/var/lib/ceph/mgr/${CLUSTER}-${MGR_NAME}"

# Adjust the owner of all those directories
chown -R ceph. /run/ceph/ /var/lib/ceph/*
