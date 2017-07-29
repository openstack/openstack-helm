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

function net_default_iface {
 sudo ip -4 route list 0/0 | awk '{ print $5; exit }'
}

function net_default_host_addr {
 sudo ip addr | awk "/inet / && /$(net_default_iface)/{print \$2; exit }"
}

function net_default_host_ip {
 echo $(net_default_host_addr) | awk -F '/' '{ print $1; exit }'
}

function net_resolv_pre_kube {
  sudo cp -f /etc/resolv.conf /etc/resolv-pre-kube.conf
  sudo rm -f /etc/resolv.conf
  cat << EOF | sudo tee /etc/resolv.conf
nameserver ${UPSTREAM_DNS}
EOF
}

function net_resolv_post_kube {
  sudo cp -f /etc/resolv-pre-kube.conf /etc/resolv.conf
}

function net_hosts_pre_kube {
  sudo cp -f /etc/hosts /etc/hosts-pre-kube
  sudo sed -i "/$(hostname)/d" /etc/hosts
  echo "$(net_default_host_ip) $(hostname)" | sudo tee -a /etc/hosts
}

function net_hosts_post_kube {
  sudo cp -f /etc/hosts-pre-kube /etc/hosts
}

function find_subnet_range {
  if [ "x$HOST_OS" == "xubuntu" ]; then
    ipcalc $(net_default_host_addr) | awk '/^Network/ { print $2 }'
  else
    eval $(ipcalc --network --prefix $(net_default_host_addr))
    echo "$NETWORK/$PREFIX"
  fi
}
