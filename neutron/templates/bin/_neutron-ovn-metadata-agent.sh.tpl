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

set -x

cp /etc/neutron/ovn_metadata_agent.ini /tmp/ovn_metadata_agent.ini

# This is because neutron doesn't support DNS names for ovsdb-nb-connection and ovsdb-sb-connection!
sed -i -e "s|__OVN_NB_DB_SERVICE_HOST__|$OVN_NB_DB_SERVICE_HOST|g" /tmp/ovn_metadata_agent.ini
sed -i -e "s|__OVN_NB_DB_SERVICE_PORT__|$OVN_NB_DB_SERVICE_PORT|g" /tmp/ovn_metadata_agent.ini
sed -i -e "s|__OVN_SB_DB_SERVICE_HOST__|$OVN_SB_DB_SERVICE_HOST|g" /tmp/ovn_metadata_agent.ini
sed -i -e "s|__OVN_SB_DB_SERVICE_PORT__|$OVN_SB_DB_SERVICE_PORT|g" /tmp/ovn_metadata_agent.ini
sed -i -e "s|__NOVA_METADATA_SERVICE_HOST__|$NOVA_METADATA_SERVICE_HOST|g" /tmp/ovn_metadata_agent.ini

exec neutron-ovn-metadata-agent \
      --config-file /etc/neutron/neutron.conf \
{{- if and ( empty .Values.conf.neutron.DEFAULT.host ) ( .Values.pod.use_fqdn.neutron_agent ) }}
  --config-file /tmp/pod-shared/neutron-agent.ini \
{{- end }}
      --config-file /tmp/ovn_metadata_agent.ini

