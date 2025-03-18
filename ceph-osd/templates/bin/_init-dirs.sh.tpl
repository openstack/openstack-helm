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
: "${OSD_BOOTSTRAP_KEYRING:=/var/lib/ceph/bootstrap-osd/${CLUSTER}.keyring}"

mkdir -p "$(dirname "${OSD_BOOTSTRAP_KEYRING}")"

# Let's create the ceph directories
for DIRECTORY in osd tmp crash; do
  mkdir -p "/var/lib/ceph/${DIRECTORY}"
done

# Create socket directory
mkdir -p /run/ceph

# Adjust the owner of all those directories
chown -R ceph. /run/ceph/ /var/lib/ceph/*
