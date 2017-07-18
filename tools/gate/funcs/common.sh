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

function base_install {
  if [ "x$HOST_OS" == "xubuntu" ]; then
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends \
      iproute2 \
      iptables \
      ipcalc \
      nmap \
      lshw
  elif [ "x$HOST_OS" == "xcentos" ]; then
    sudo yum install -y \
      epel-release
    # ipcalc is in the initscripts package
    sudo yum install -y \
      iproute \
      iptables \
      initscripts \
      nmap \
      lshw
  elif [ "x$HOST_OS" == "xfedora" ]; then
    sudo dnf install -y \
      iproute \
      iptables \
      ipcalc \
      nmap \
      lshw
  fi
}

function loopback_support_install {
  if [ "x$HOST_OS" == "xubuntu" ]; then
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends \
      targetcli \
      open-iscsi \
      lshw
    sudo systemctl restart iscsid
  elif [ "x$HOST_OS" == "xcentos" ]; then
    sudo yum install -y \
      targetcli \
      iscsi-initiator-utils \
      lshw
  elif [ "x$HOST_OS" == "xfedora" ]; then
    sudo dnf install -y \
      targetcli \
      iscsi-initiator-utils \
      lshw
  fi
}

function loopback_setup {
  sudo mkdir -p ${LOOPBACK_DIR}
  for ((LOOPBACK_DEV=1;LOOPBACK_DEV<=${LOOPBACK_DEVS};LOOPBACK_DEV++)); do
    if [ "x$HOST_OS" == "xubuntu" ]; then
      sudo targetcli backstores/fileio create loopback-${LOOPBACK_DEV} ${LOOPBACK_DIR}/fileio-${LOOPBACK_DEV} ${LOOPBACK_SIZE}
    else
      sudo targetcli backstores/fileio create loopback-${LOOPBACK_DEV} ${LOOPBACK_DIR}/fileio-${LOOPBACK_DEV} ${LOOPBACK_SIZE} write_back=false
    fi
  done
  sudo targetcli iscsi/ create iqn.2016-01.com.example:target
  if ! [ "x$HOST_OS" == "xubuntu" ]; then
    sudo targetcli iscsi/iqn.2016-01.com.example:target/tpg1/portals delete 0.0.0.0 3260
    sudo targetcli iscsi/iqn.2016-01.com.example:target/tpg1/portals create 127.0.0.1 3260
  else
    #NOTE (Portdirect): Frustratingly it appears that Ubuntu's targetcli wont
    # let you bind to localhost.
    sudo targetcli iscsi/iqn.2016-01.com.example:target/tpg1/portals create 0.0.0.0 3260
  fi
  for ((LOOPBACK_DEV=1;LOOPBACK_DEV<=${LOOPBACK_DEVS};LOOPBACK_DEV++)); do
    sudo targetcli iscsi/iqn.2016-01.com.example:target/tpg1/luns/ create /backstores/fileio/loopback-${LOOPBACK_DEV}
  done
  sudo targetcli iscsi/iqn.2016-01.com.example:target/tpg1/acls/ create $(sudo cat /etc/iscsi/initiatorname.iscsi | awk -F '=' '/^InitiatorName/ { print $NF}')
  if [ "x$HOST_OS" == "xubuntu" ]; then
    sudo targetcli iscsi/iqn.2016-01.com.example:target/tpg1 set attribute authentication=0
  fi
  sudo iscsiadm --mode discovery --type sendtargets --portal 127.0.0.1
  sudo iscsiadm -m node -T iqn.2016-01.com.example:target -p 127.0.0.1:3260 -l
  # Display disks
  sudo lshw -class disk
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
  sudo modprobe rbd
}

function nfs_support_install {
  if [ "x$HOST_OS" == "xubuntu" ]; then
    sudo apt-get update -y
    sudo apt-get install -y --no-install-recommends -qq \
      nfs-common
  elif [ "x$HOST_OS" == "xcentos" ]; then
    sudo yum install -y \
      nfs-utils
  elif [ "x$HOST_OS" == "xfedora" ]; then
    sudo dnf install -y \
      nfs-utils
  fi
}

function gate_base_setup {
  # Install base requirements
  base_install

  # Install and setup iscsi loopback devices if required.
  if [ "x$LOOPBACK_CREATE" == "xtrue" ]; then
    loopback_support_install
    loopback_setup
  fi

  # Install support packages for pvc backends
  if [ "x$PVC_BACKEND" == "xceph" ]; then
    ceph_support_install
  elif [ "x$PVC_BACKEND" == "xnfs" ]; then
    nfs_support_install
  fi
}
