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

NOVA_VERSION=$(nova-manage --version 2>&1 > /dev/null)

function manage_cells () {
  # NOTE(portdirect): check if nova fully supports cells v2, and manage
  # accordingly. Support was complete in ocata (V14.x.x).
  if [ "${NOVA_VERSION%%.*}" -gt "14" ]; then
    nova-manage cell_v2 map_cell0
    nova-manage cell_v2 list_cells | grep -q " cell1 " || \
      nova-manage cell_v2 create_cell --name=cell1 --verbose
  fi
}

# NOTE(portdirect): if the db has been populated we should setup cells if
# required, otherwise we should poulate the api db, and then setup cells.
if [ "$(nova-manage api_db version)" -gt "0" ]; then
  manage_cells
  nova-manage api_db sync
else
  nova-manage api_db sync
  manage_cells
fi

nova-manage db sync

nova-manage db online_data_migrations

echo 'Finished DB migrations'
