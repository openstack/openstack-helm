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

[ml2]
# Changing type_drivers after bootstrap can lead to database inconsistencies
type_drivers = {{ include "helm-toolkit.joinListWithComma" .Values.ml2.type_drivers }}
tenant_network_types = {{ .Values.ml2.tenant_network_types }}
mechanism_drivers = {{ include "helm-toolkit.joinListWithComma" .Values.ml2.mechanism_drivers }}
extension_drivers = {{ include "helm-toolkit.joinListWithComma" .Values.ml2.extension_drivers }}

[ml2_type_flat]
flat_networks = {{ include "helm-toolkit.joinListWithComma" .Values.ml2.ml2_type_flat.flat_networks }}

[ml2_type_gre]
# (ListOpt) Comma-separated list of <tun_min>:<tun_max> tuples enumerating ranges
# of GRE tunnel IDs that are available for tenant network allocation
tunnel_id_ranges = {{ .Values.ml2.ml2_type_gre.tunnel_id_ranges }}

[ml2_type_vxlan]
vni_ranges = {{ .Values.ml2.ml2_type_vxlan.vni_ranges }}
vxlan_group = {{ .Values.ml2.ml2_type_vxlan.vxlan_group }}

[ml2_type_vlan]
# (ListOpt) List of <physical_network>[:<vlan_min>:<vlan_max>] tuples
# specifying physical_network names usable for VLAN provider and
# tenant networks, as well as ranges of VLAN tags on each
# physical_network available for allocation as tenant networks.
network_vlan_ranges = {{ .Values.ml2.ml2_type_vlan.network_vlan_ranges }}

[securitygroup]
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
enable_security_group = True

{{- if .Values.ml2.agent.tunnel_types }}
[agent]
tunnel_types = {{ .Values.ml2.agent.tunnel_types }}
l2_population = false
arp_responder = false
{{- end }}

[ovs]
bridge_mappings = {{ include "helm-toolkit.joinListWithComma" .Values.ml2.ovs.bridge_mappings }}
tenant_network_type = {{ .Values.ml2.agent.tunnel_types }}

[vxlan]
l2_population = true
ovsdb_interface = {{ .Values.network.interface.openvswitch | default .Values.network.interface.default }}
