#!/bin/bash

{{/*
Copyright 2017 The Openstack-Helm Authors.

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

COMMAND="${@:-liveness}"

function heath_check () {
  IS_MGR_AVAIL=$(ceph --cluster "${CLUSTER}" mgr dump | python -c "import json, sys; print json.load(sys.stdin)['available']")

  if [ "${IS_MGR_AVAIL}" = True ]; then
    exit 0
  else
    exit 1
  fi
}

function liveness () {
  heath_check
}

function readiness () {
  heath_check
}

$COMMAND
