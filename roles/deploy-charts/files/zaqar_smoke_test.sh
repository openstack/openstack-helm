#!/bin/bash
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -ex

export OS_CLOUD=openstack_helm

OS_PROJECT_ID=$(openstack project show admin -c id -f value)
QUEUE_NAME="test"
CLIENT_ID=$(uuidgen)

openstack --os-project-id $OS_PROJECT_ID messaging queue list

openstack --os-project-id $OS_PROJECT_ID messaging queue create $QUEUE_NAME

openstack --os-project-id $OS_PROJECT_ID messaging message post $QUEUE_NAME '{"body": "hello world 1"}' --client-id $CLIENT_ID
openstack --os-project-id $OS_PROJECT_ID messaging message post $QUEUE_NAME '{"body": "hello world 2"}' --client-id $CLIENT_ID

openstack --os-project-id $OS_PROJECT_ID messaging message list $QUEUE_NAME --client-id $CLIENT_ID --echo
