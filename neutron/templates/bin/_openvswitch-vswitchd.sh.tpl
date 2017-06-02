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

set -ex

# load tunnel kernel modules we may use and gre/vxlan
modprobe openvswitch

modprobe gre
modprobe vxlan

ovs-vsctl --no-wait show
bash -x /tmp/openvswitch-ensure-configured.sh
exec /usr/sbin/ovs-vswitchd unix:/run/openvswitch/db.sock --mlockall -vconsole:emer -vconsole:err -vconsole:info
