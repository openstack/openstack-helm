#!/usr/bin/env bash

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

set -o pipefail

MYSQL="mysql --defaults-file=/etc/mysql/admin_user.cnf --host=localhost"

if [ ! $($MYSQL -e 'select 1') ]; then
    echo "Could not SELECT 1" 1>&2
    exit 1
fi

# Set this late, so that we can give a nicer error message above.
set -o errexit

CLUSTER_STATUS=$($MYSQL -e "show status like 'wsrep_cluster_status'" | tail -n 1 | cut -f 2)
if [ "x${CLUSTER_STATUS}" != "xPrimary" ]; then
    echo "Not in primary cluster: '${CLUSTER_STATUS}'" 1>&2
    exit 1
fi

WSREP_READY=$($MYSQL -e "show status like 'wsrep_ready'" | tail -n 1 | cut -f 2)
if [ "x${WSREP_READY}" != "xON" ]; then
    echo "WSREP not ready: '${WSREP_READY}'" 1>&2
    exit 1
fi

WSREP_STATE=$($MYSQL -e "show status like 'wsrep_local_state_comment'" | tail -n 1 | cut -f 2)
if [ "x${WSREP_STATE}" != "xSynced" ]; then
    echo "WSREP not synced: '${WSREP_STATE}'" 1>&2
    exit 1
fi

echo "${POD_NAME} ready." 1>&2

exit 0
