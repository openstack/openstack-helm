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
set -xe

stages="prepare deploy checkdns setupdns"
OSH_INFRA_PATH=${OSH_INFRA_PATH:="../openstack-helm-infra"}
: ${RUN_HELM_TESTS:="yes"}

function get_node_ip() {
  local phys_int=$(ip route get 1 | grep -o 'dev.*' | awk '{print($2)}')
  local node_ip=$(ip addr show dev $phys_int | grep -Pom1 "(?<=inet )([0-9]+\.{0,1}){4}")
  echo $node_ip
}

function nic_has_ip() {
  local nic=$1
  if nic_ip=$(ip addr show $nic | grep -Pom1 "(?<=inet )([0-9]+\.{0,1}){4}"); then
    printf "\n$nic has IP $nic_ip"
    return 0
  else
    return 1
  fi
}

function wait_cmd_success() {
  # silent mode = don't print output of input cmd for each attempt.
  local cmd=$1
  local interval=${2:-3}
  local max=${3:-300}
  local silent_cmd=${4:-1}

  local state_save=$(set +o)
  set +o xtrace
  set -o pipefail
  local i=0
  if [[ "$silent_cmd" != "0" ]]; then
    local to_dev_null="&>/dev/null"
  else
    local to_dev_null=""
  fi
  while ! eval "$cmd" "$to_dev_null"; do
    printf "."
    i=$((i + 1))
    if (( i > max )) ; then
      echo ""
      echo "ERROR: wait failed in $((i*10))s"
      eval "$cmd"
      eval "$state_save"
      return 1
    fi
    sleep $interval
  done
  echo ""
  echo "INFO: done in $((i*10))s"
  eval "$state_save"
}

function wait_nic_up() {
  local nic=$1
  printf "INFO: wait for $nic is up"
  if ! wait_cmd_success "nic_has_ip $nic" 10 60; then
    echo "ERROR: $nic is not up"
    echo "INFO: Start vrouter logs"
    local agent_pod=$(kubectl get pods -n tungsten-fabric --no-headers -o custom-columns=NAME:.metadata.name)
    kubectl describe pod $agent_pod -n tungsten-fabric
    echo "INFO: vrouter-agent logs"
    kubectl logs $agent_pod -n tungsten-fabric -c contrail-vrouter-agent
    echo "INFO: vrouter-init-kernel logs"
    kubectl logs $agent_pod -c contrail-vrouter-init-kernel -n tungsten-fabric
    sudo docker image list
    echo "INFO: End vrouter logs"
    return 1
  fi
  echo "INFO: $nic is up"
}

function show_usage_tf(){
  cat <<EOF
To use this script pass a stage you need as a first argument:

  tungsten_fabric.sh <stage>

Possible stages are:

  'setupdns' - configure DNS for use k8s using resolvconf service
    - Install resolvconf service
    - Add k8s cluster IP as a nameserver to the config

  'prepare' - prepared host to deploy Tungsten fabric:
    - add an tf.yaml file to libvirt/values_overrides
    - comment lines in compute_kit.sh which wait nova and neutron is working and run tests
    - check and add line to /etc/hosts file
    Run 'preapare' stage after install kubernetes and before run libvirt.sh and compute_kit.sh

  'deploy' - deploy Tungsten fabric:
    - download tf Helm charts
    - prepare tf config
    - deploy Tungsten fabric to Kubernetes
    - wait for tf pods
    - wait for openstack pods
    - run couple of openstack commands and nova tests
    Run 'deploy' stage after compute_kit.sh
EOF
}

# 'setupdns' stage implementation
function setupdns_tf() {
  local distro=$(cat /etc/*release | egrep '^ID=' | awk -F= '{print $2}' | tr -d \")
  if [[ $distro == 'ubuntu' ]] ; then
    export DEBIAN_FRONTEND=noninteractive
    sudo -E apt-get install -y resolvconf
    dns_cluster_ip=`kubectl get svc kube-dns -n kube-system --no-headers -o custom-columns=":spec.clusterIP"`
    echo "nameserver ${dns_cluster_ip}" | sudo tee -a /etc/resolvconf/resolv.conf.d/head > /dev/null
    sudo systemctl restart resolvconf
  fi
}

# 'checkdns' stage
function checkdns_tf() {
  cat /etc/resolv.conf
}

# 'prepare' stage implementation
function prepare_tf(){
  # Linux kernel headers required to build vrouter kernel module on Ubuntu
  local distro=$(cat /etc/*release | egrep '^ID=' | awk -F= '{print $2}' | tr -d \")
  if [[ $distro == 'ubuntu' ]] ; then
    sudo apt-get install -y linux-headers-$(uname -r) chrony
  fi
  # add an tf.yaml file to libvirt/values_overrides
  cat <<EOF > ${OSH_INFRA_PATH}/libvirt/values_overrides/tf.yaml
---
network:
  backend:
    - tungstenfabric
dependencies:
  dynamic:
    targeted:
      tungstenfabric:
        libvirt:
          daemonset: []
conf:
  qemu:
    cgroup_device_acl: ["/dev/null", "/dev/full", "/dev/zero", "/dev/random", "/dev/urandom", "/dev/ptmx", "/dev/kvm", "/dev/kqemu", "/dev/rtc", "/dev/hpet", "/dev/net/tun"]
...

EOF

  # check and add a line to /etc/hosts file
  local node_ip=$(get_node_ip)
  if ! cat /etc/hosts | grep "${node_ip}" ; then
    local tf_hostname=$(hostname)
    cat <<EOF | sudo tee -a /etc/hosts
${node_ip} ${tf_hostname}.cluster.local ${tf_hostname}
EOF
  fi
}

# 'deploy' stage implementation
function deploy_tf(){
  if [[ -z "$CONTAINER_DISTRO_NAME" ]] ; then
    echo "ERROR: Please set up CONTAINER_DISTRO_NAME"
    exit 1
  fi

  export CONTROLLER_NODES=$(get_node_ip)

  # download tf Helm charts
  sudo docker create --name tf-helm-deployer-src --entrypoint /bin/true tungstenfabric/tf-helm-deployer-src:latest
  sudo docker cp tf-helm-deployer-src:/src ./tf-helm-deployer
  sudo docker rm -fv tf-helm-deployer-src

  pushd tf-helm-deployer
  helm repo add local http://localhost:8879/charts
  sudo make all
  popd

  # prepare tf config
  cat <<EOF > ./tf-devstack-values.yaml
global:
  contrail_env:
    CONTAINER_REGISTRY: tungstenfabric
    CONTRAIL_CONTAINER_TAG: "2020-06-08"
    CONTROLLER_NODES: ${CONTROLLER_NODES}
    JVM_EXTRA_OPTS: "-Xms1g -Xmx2g"
    BGP_PORT: "1179"
    CONFIG_DATABASE_NODEMGR__DEFAULTS__minimum_diskGB: "2"
    DATABASE_NODEMGR__DEFAULTS__minimum_diskGB: "2"
    LOG_LEVEL: SYS_DEBUG
    VROUTER_ENCRYPTION: FALSE
    ANALYTICS_ALARM_ENABLE: TRUE
    ANALYTICS_SNMP_ENABLE: TRUE
    ANALYTICSDB_ENABLE: TRUE
    CLOUD_ORCHESTRATOR: ${CONTAINER_DISTRO_NAME}
  node:
    host_os: ubuntu
EOF

  # deploy Tungsten fabric to Kubernetes
  sudo mkdir -p /var/log/contrail
  kubectl create ns tungsten-fabric
  helm upgrade --install --namespace tungsten-fabric tungsten-fabric tf-helm-deployer/contrail -f tf-devstack-values.yaml
  kubectl label nodes --all opencontrail.org/vrouter-kernel=enabled
  wait_nic_up vhost0
  kubectl label nodes --all opencontrail.org/controller=enabled

  # wait for tf pods
  ./tools/deployment/common/wait-for-pods.sh tungsten-fabric
  echo "INFO: Tungsten Fabric info"
  # Display contrail state
  sudo contrail-status
  kubectl get pods -n tungsten-fabric

  # wait for openstack pods
  ./tools/deployment/common/wait-for-pods.sh openstack

  # run couple of openstack commands and nova tests
  openstack compute service list
  openstack hypervisor list
  if [ "x${RUN_HELM_TESTS}" != "xno" ]; then
    ./tools/deployment/common/run-helm-tests.sh nova
    ./tools/deployment/common/run-helm-tests.sh neutron
  fi
}

if [[ $# == 0 ]] ; then
  echo "ERROR: You have to pass some stage in this script"
  show_usage_tf
  exit 1
fi

if [[ ! $stages =~ .*${1}.* ]] ; then
  echo "ERROR: Not any valid stage has been found"
  show_usage_tf
  exit 1
fi

${1}_tf
