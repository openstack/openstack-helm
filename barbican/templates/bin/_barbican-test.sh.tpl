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

openstack secret list

# Come up with a random payload
PAYLOAD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
echo $PAYLOAD

SECRET=`openstack secret store --name mysecret --payload ${PAYLOAD} | awk ' /href/ {print $5}'`

openstack secret list

openstack secret get $SECRET

openstack secret get --payload $SECRET

openstack secret delete $SECRET

openstack secret list
