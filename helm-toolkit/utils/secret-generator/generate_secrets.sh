#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

gen-fsid() {
  echo "$(uuidgen)"
}

gen-ceph-conf-raw() {
  fsid=${1:?}
  shift
  conf=$(sigil -p -f templates/ceph/ceph.conf.tmpl "fsid=${fsid}" $@)
  echo "${conf}"
}

gen-ceph-conf() {
  fsid=${1:?}
  shift
  conf=$(sigil -p -f templates/ceph/ceph.conf.tmpl "fsid=${fsid}" $@)
  echo "${conf}"
}

gen-admin-keyring() {
  key=$(python ceph-key.py)
  keyring=$(sigil -f templates/ceph/admin.keyring.tmpl "key=${key}")
  echo "${keyring}"
}

gen-mon-keyring() {
  key=$(python ceph-key.py)
  keyring=$(sigil -f templates/ceph/mon.keyring.tmpl "key=${key}")
  echo "${keyring}"
}

gen-combined-conf() {
  fsid=${1:?}
  shift
  conf=$(sigil -p -f templates/ceph/ceph.conf.tmpl "fsid=${fsid}" $@)
  echo "${conf}" > ../../secrets/ceph.conf

  key=$(python ceph-key.py)
  keyring=$(sigil -f templates/ceph/admin.keyring.tmpl "key=${key}")
  echo "${key}" > ../../secrets/ceph-client-key
  echo "${keyring}" > ../../secrets/ceph.client.admin.keyring

  key=$(python ceph-key.py)
  keyring=$(sigil -f templates/ceph/mon.keyring.tmpl "key=${key}")
  echo "${keyring}" > ../../secrets/ceph.mon.keyring
}

gen-bootstrap-keyring() {
  service="${1:-osd}"
  key=$(python ceph-key.py)
  bootstrap=$(sigil -f templates/ceph/bootstrap.keyring.tmpl "key=${key}" "service=${service}")
  echo "${bootstrap}"
}

gen-all-bootstrap-keyrings() {
  gen-bootstrap-keyring osd > ../../secrets/ceph.osd.keyring
  gen-bootstrap-keyring mds > ../../secrets/ceph.mds.keyring
  gen-bootstrap-keyring rgw > ../../secrets/ceph.rgw.keyring
}

gen-all() {
  gen-combined-conf $@
  gen-all-bootstrap-keyrings
}


main() {
  set -eo pipefail
  case "$1" in
  fsid)            shift; gen-fsid $@;;
  ceph-conf-raw)            shift; gen-ceph-conf-raw $@;;
  ceph-conf)            shift; gen-ceph-conf $@;;
  admin-keyring)            shift; gen-admin-keyring $@;;
  mon-keyring)            shift; gen-mon-keyring $@;;
  bootstrap-keyring)            shift; gen-bootstrap-keyring $@;;
  combined-conf)               shift; gen-combined-conf $@;;
  all)                         shift; gen-all $@;;
  esac
}

main "$@"
