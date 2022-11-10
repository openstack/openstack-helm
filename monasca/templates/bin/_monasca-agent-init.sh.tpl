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
# Start our service.
echo "Start script: starting container"
mkdir -p /etc/monasca/agent
cp /tmp/agent.yaml /etc/monasca/agent/agent.yaml
sudo chmod 600 /etc/monasca/agent/agent.yaml
ls -al /etc/monasca/agent/agent.yaml
sed -i "s/%FORWARDER_IP%/$MY_POD_IP/g" /etc/monasca/agent/agent.yaml
sed -i "s/%AGENT_HOSTNAME%/$(hostname --fqdn)/g" /etc/monasca/agent/agent.yaml
