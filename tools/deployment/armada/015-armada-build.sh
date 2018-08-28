#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
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

set -xe

TMP_DIR=$(mktemp -d)
  git clone --depth 1 http://github.com/openstack/airship-armada.git ${TMP_DIR}/armada
sudo pip3 install ${TMP_DIR}/armada
sudo make build -C ${TMP_DIR}/armada
sudo rm -rf ${TMP_DIR}
