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

mkdir -p /tmp/pod-shared
cp /etc/neutron/plugins/ml2/ml2_conf.ini /tmp/pod-shared/ml2_conf.ini

# This is because neutron doesn't support DNS names for ovsdb-nb-connection and ovsdb-sb-connection!
sed -i -e "s|__OVN_NB_DB_SERVICE_HOST__|$OVN_NB_DB_SERVICE_HOST|g" /tmp/pod-shared/ml2_conf.ini
sed -i -e "s|__OVN_NB_DB_SERVICE_PORT__|$OVN_NB_DB_SERVICE_PORT|g" /tmp/pod-shared/ml2_conf.ini
sed -i -e "s|__OVN_SB_DB_SERVICE_HOST__|$OVN_SB_DB_SERVICE_HOST|g" /tmp/pod-shared/ml2_conf.ini
sed -i -e "s|__OVN_SB_DB_SERVICE_PORT__|$OVN_SB_DB_SERVICE_PORT|g" /tmp/pod-shared/ml2_conf.ini
