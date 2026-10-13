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

# Read-only calls through the Trove API, which authenticate against Keystone
# and read the Trove database. Creating an instance needs a guest image, a
# registered datastore and a network, none of which a deployment of the
# chart alone provides.
openstack datastore list
for datastore in $(openstack datastore list -f value -c ID); do
  openstack datastore version list "${datastore}"
done
openstack database instance list
openstack database cluster list
openstack database backup list
openstack database configuration list
