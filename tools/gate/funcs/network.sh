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

function find_multi_subnet_range {
  : ${PRIMARY_NODE_IP:="$(cat /etc/nodepool/primary_node | tail -1)"}
  : ${SUB_NODE_IPS:="$(cat /etc/nodepool/sub_nodes)"}
  NODE_IPS="${PRIMARY_NODE_IP} ${SUB_NODE_IPS}"
  NODE_IP_UNSORTED=$(mktemp --suffix=.txt)
  for NODE_IP in $NODE_IPS; do
    echo $NODE_IP >> ${NODE_IP_UNSORTED}
  done
  NODE_IP_SORTED=$(mktemp --suffix=.txt)
  sort -V ${NODE_IP_UNSORTED} > ${NODE_IP_SORTED}
  rm -f ${NODE_IP_UNSORTED}
  FIRST_IP_SUBNET=$(ipcalc "$(head -n 1 ${NODE_IP_SORTED})/24" | awk '/^Network/ { print $2 }')
  LAST_IP_SUBNET=$(ipcalc "$(tail -n 1 ${NODE_IP_SORTED})/24" | awk '/^Network/ { print $2 }')
  rm -f ${NODE_IP_SORTED}
  function ip_diff {
    echo $(($(echo $LAST_IP_SUBNET | awk -F '.' "{ print \$$1}") - $(echo $FIRST_IP_SUBNET | awk -F '.' "{ print \$$1}")))
  }
  for X in {1..4}; do
    if ! [ "$(ip_diff $X)" -eq "0" ]; then
      SUBMASK=$(((($X - 1 )) * 8))
      break
    elif [ $X -eq "4" ]; then
      SUBMASK=24
    fi
  done
  echo ${FIRST_IP_SUBNET%/*}/${SUBMASK}
}
