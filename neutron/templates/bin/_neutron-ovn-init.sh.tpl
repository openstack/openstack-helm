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

# See: https://bugs.launchpad.net/neutron/+bug/2028442
mkdir -p /tmp/pod-shared
tee > /tmp/pod-shared/ovn.ini << EOF
[ovn]
ovn_nb_connection=tcp:$OVN_OVSDB_NB_SERVICE_HOST:$OVN_OVSDB_NB_SERVICE_PORT_OVSDB
ovn_sb_connection=tcp:$OVN_OVSDB_SB_SERVICE_HOST:$OVN_OVSDB_SB_SERVICE_PORT_OVSDB
EOF
