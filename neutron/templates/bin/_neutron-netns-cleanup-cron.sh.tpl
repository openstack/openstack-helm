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

set -xe

# Run "neutron-netns-cleanup" every 5 minutes
while sleep 300; do
    neutron-netns-cleanup \
        --config-file /etc/neutron/neutron.conf \
        --config-file /etc/neutron/dhcp_agent.ini \
        --config-file /etc/neutron/l3_agent.ini
done
