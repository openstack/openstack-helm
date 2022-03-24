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
apt update && apt install -y python3-rbd python3-rados ceph-common sg3-utils multipath-tools
sed -i 's/stack-volumes-lvmdriver-1/cinder-vol/' /usr/lib/python3/dist-packages/contego/nova/extension/driver/backends/cinder_backend.py
/usr/bin/s3vaultfuse.py --config-file=/etc/tvault-object-store.conf &
exec /usr/bin/tvault-contego --config-file=/etc/nova/nova.conf --config-file=/etc/tvault-contego/tvault-contego.conf
