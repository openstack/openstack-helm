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

function net_resolv_pre_kube {
  sudo cp -f /etc/resolv.conf /etc/resolv-pre-kube.conf
  sudo rm -f /etc/resolv.conf
  cat << EOF | sudo tee /etc/resolv.conf
nameserver 8.8.8.8
EOF
}

function net_resolv_post_kube {
  sudo cp -f /etc/resolv-pre-kube.conf /etc/resolv.conf
}

function net_hosts_pre_kube {
  sudo cp -f /etc/hosts /etc/hosts-pre-kube
  HOST_IFACE=$(sudo ip route | grep "^default" | awk '{ print $5 }')
  HOST_IP=$(sudo ip addr | awk "/inet/ && /${HOST_IFACE}/{sub(/\/.*$/,\"\",\$2); print \$2}")

  sudo sed -i "/$(hostname)/d" /etc/hosts
  echo "${HOST_IP} $(hostname)" | sudo tee -a /etc/hosts
}

function net_hosts_post_kube {
  sudo cp -f /etc/hosts-pre-kube /etc/hosts
}

function find_subnet_range {
  DEFAULT_IFACE=$(sudo ip route | awk --posix '$1~/^default$/{print $5}')
  IFS=/ read IP_ADDR SUBNET_PREFIX <<< $(sudo ip addr show ${DEFAULT_IFACE} | awk --posix '$1~/^inet$/{print $2}')

  set -- $(( 5 - (${SUBNET_PREFIX} / 8) )) 255 255 255 255 $(( (255 << (8 - (${SUBNET_PREFIX} % 8))) & 255 )) 0 0 0
  [ $1 -gt 1 ] && shift $1 || shift
  SUBNET_MASK=$(echo ${1-0}.${2-0}.${3-0}.${4-0})

  IFS=. read -r i1 i2 i3 i4 <<< ${IP_ADDR}
  IFS=. read -r m1 m2 m3 m4 <<< ${SUBNET_MASK}
  BASE_SUBNET_IP=$(printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))")
  echo "$BASE_SUBNET_IP/$SUBNET_PREFIX"
}
