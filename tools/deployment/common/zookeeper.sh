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

#NOTE: Lint and package chart
make zookeeper

#NOTE: Deploy command
helm upgrade --install zookeeper ./zookeeper \
    --namespace=osh-infra

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

#NOTE: Validate Deployment info
helm status zookeeper

#NOTE: Sleep for 60 seconds to allow leader election to complete
sleep 60

#NOTE: Create arbitrary znode
ZOO_POD=$(kubectl -n osh-infra get pods -l='application=zookeeper,component=server' --output=jsonpath='{.items[0].metadata.name}')
kubectl exec $ZOO_POD -n osh-infra -- bash bin/zkCli.sh -server localhost:2181 create /OSHZnode “osh-infra_is_awesome”

#NOTE: Sleep for 10 seconds to ensure replication across members
sleep 10

#NOTE: Query separate zookeeper instance for presence of znode
ZOO_POD=$(kubectl -n osh-infra get pods -l='application=zookeeper,component=server' --output=jsonpath='{.items[2].metadata.name}')
kubectl exec $ZOO_POD -n osh-infra -- bash bin/zkCli.sh -server localhost:2181 stat /OSHZnode
