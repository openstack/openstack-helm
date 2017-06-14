#!/bin/bash
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
set -e

function base_install {
  if [ "x$HOST_OS" == "xubuntu" ]; then
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends -qq \
      iproute2 \
      iptables
  elif [ "x$HOST_OS" == "xcentos" ]; then
    sudo yum install -y \
      iproute \
      iptables
  elif [ "x$HOST_OS" == "xfedora" ]; then
    sudo dnf install -y \
      iproute \
      iptables
  fi
}

function ceph_support_install {
  if [ "x$HOST_OS" == "xubuntu" ]; then
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends -qq \
      ceph-common
  elif [ "x$HOST_OS" == "xcentos" ]; then
    sudo yum install -y \
      ceph
  elif [ "x$HOST_OS" == "xfedora" ]; then
    sudo dnf install -y \
      ceph
  fi
}
