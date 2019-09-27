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
# test_netpol(namespace, application, component, target_host, expected_result{fail,success})
function test_netpol {
  NS=$1
  APP=$2
  COMPONENT=$3
  HOST=$4
  STATUS=$5
  echo Testing connection from $APP - $COMPONENT to host $HOST with namespace $NS
  POD=$(kubectl -n $NS get pod -l application=$APP,component=$COMPONENT | grep Running | cut -f 1 -d " " | head -n 1)
  PID=$(sudo docker inspect --format '{{ .State.Pid }}' $(kubectl get pods --namespace $NS $POD -o jsonpath='{.status.containerStatuses[0].containerID}' | cut -c 10-21))
  if [ "x${STATUS}" == "xfail" ]; then
    if ! sudo nsenter -t $PID -n wget --spider --timeout=5 --tries=1 $HOST ; then
      echo "Connection timed out; as expected by policy."
    else
      exit 1
    fi
  else
    sudo nsenter -t $PID -n wget --spider --timeout=5 --tries=1 $HOST
  fi
}

#NOTE(gagehugo): Enable the negative tests once the services policy is defined

# General Netpol Tests
# Doing negative tests
#test_netpol openstack mariadb server rabbitmq.openstack.svc.cluster.local:5672 fail
#test_netpol openstack rabbitmq-rabbitmq server memcached.openstack.svc.cluster.local:11211 fail
#test_netpol openstack memcached server mariadb.openstack.svc.cluster.local:3306 fail
# Doing positive tests
test_netpol openstack keystone api mariadb.openstack.svc.cluster.local:3306 success
test_netpol openstack keystone api rabbitmq.openstack.svc.cluster.local:5672 success

if kubectl -n openstack get pod -l application=cinder | grep Running ; then
# Negative Cinder Tests
  #test_netpol openstack keystone api cinder-api.openstack.svc.cluster.local fail
# Positive Cinder Tests
  test_netpol openstack cinder api rabbitmq.openstack.svc.cluster.local:5672 success
else
# Negative Compute-Kit Tests
  #test_netpol openstack keystone api heat-api.openstack.svc.cluster.local fail
  #test_netpol openstack keystone api glance-api.openstack.svc.cluster.local fail
# Positive Compute-Kit Tests
  test_netpol openstack heat api mariadb.openstack.svc.cluster.local:3306 success
  test_netpol openstack glance api mariadb.openstack.svc.cluster.local:3306 success
fi

echo Test Success
