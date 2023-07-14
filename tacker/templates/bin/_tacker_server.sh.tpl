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

pip install python-cinderclient
pip install retrying
pip install boto3
apt update
apt install curl -y -f --install-suggests
curl -o /tmp/helm.tar.gz https://get.helm.sh/helm-v3.11.2-linux-amd64.tar.gz
tar zxf /tmp/helm.tar.gz -C /tmp/;mv /tmp/linux-amd64/helm /usr/local/bin/helm
tacker-server --config-file /etc/tacker/tacker.conf
