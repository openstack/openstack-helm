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

# Negative Keystone tests
test_netpol openstack mariadb server keystone-api.openstack.svc.cluster.local:5000 fail
test_netpol openstack mariadb ingress keystone-api.openstack.svc.cluster.local:5000 fail
test_netpol openstack memcached server keystone-api.openstack.svc.cluster.local:5000 fail
test_netpol openstack rabbitmq server keystone-api.openstack.svc.cluster.local:5000 fail

# Negative Mariadb tests
test_netpol openstack memcached server mariadb.openstack.svc.cluster.local:3306 fail
test_netpol openstack ingress server mariadb-server.openstack.svc.cluster.local:3306 fail

# Doing positive tests

# Positive Mariadb tests
test_netpol openstack keystone api mariadb.openstack.svc.cluster.local:3306 success
test_netpol openstack keystone api mariadb-server.openstack.svc.cluster.local:3306 success
test_netpol openstack mariadb ingress mariadb-server.openstack.svc.cluster.local:3306 success

test_netpol openstack keystone api rabbitmq.openstack.svc.cluster.local:5672 success
test_netpol openstack ingress server keystone-api.openstack.svc.cluster.local:5000 success
test_netpol openstack prometheus-openstack-exporter exporter keystone-api.openstack.svc.cluster.local:5000 success

if kubectl -n openstack get pod -l application=horizon | grep Running ; then
  test_netpol openstack keystone api horizon.openstack.svc.cluster.local:80 fail
fi

if kubectl -n openstack get pod -l application=cinder | grep Running ; then
# Negative Cinder Tests
  #test_netpol openstack keystone api cinder-api.openstack.svc.cluster.local fail
  test_netpol openstack cinder api horizon.openstack.svc.cluster.local:80 fail
# Positive Cinder Tests
  test_netpol openstack cinder api rabbitmq.openstack.svc.cluster.local:5672 success

  # Positive Keystone test
  test_netpol openstack cinder api keystone-api.openstack.svc.cluster.local:5000 success

  # Positive Mariadb tests
  test_netpol openstack cinder api mariadb.openstack.svc.cluster.local:3306 success
  test_netpol openstack cinder api mariadb-server.openstack.svc.cluster.local:3306 success
else
# Negative Compute-Kit Tests
  #test_netpol openstack keystone api heat-api.openstack.svc.cluster.local fail
  #test_netpol openstack keystone api glance-api.openstack.svc.cluster.local fail
  test_netpol openstack mariadb server glance-api.openstack.svc.cluster.local:9292 fail
  test_netpol openstack memcached server glance-api.openstack.svc.cluster.local:9292 fail
  test_netpol openstack keystone api glance-api.openstack.svc.cluster.local:9292 fail
  # Memcached Negative Tests
  test_netpol openstack mariadb server memcached.openstack.svc.cluster.local:11211 fail
  test_netpol openstack rabbitmq server memcached.openstack.svc.cluster.local:11211 fail
  test_netpol openstack openvswitch openvswitch-vswitchd memcached.openstack.svc.cluster.local:11211 fail
  test_netpol openstack libvirt libvirt memcached.openstack.svc.cluster.local:11211 fail
  # Heat Negative Tests
  test_netpol openstack keystone api heat-api.openstack.svc.cluster.local:8004 fail
  test_netpol openstack nova os-api heat-api.openstack.svc.cluster.local:8004 fail
  test_netpol openstack neutron server heat-api.openstack.svc.cluster.local:8004 fail
  test_netpol openstack glance api heat-api.openstack.svc.cluster.local:8004 fail

# Positive Compute-Kit Tests

  # Positive Mariadb tests
  test_netpol openstack heat api mariadb.openstack.svc.cluster.local:3306 success
  test_netpol openstack glance api mariadb.openstack.svc.cluster.local:3306 success
  test_netpol openstack glance api mariadb-server.openstack.svc.cluster.local:3306 success

  # Positive Keystone tests
  test_netpol openstack heat api keystone-api.openstack.svc.cluster.local:5000 success
  test_netpol openstack glance api keystone-api.openstack.svc.cluster.local:5000 success
  test_netpol openstack horizon server keystone-api.openstack.svc.cluster.local:5000 success
  test_netpol openstack nova os-api keystone-api.openstack.svc.cluster.local:5000 success
  test_netpol openstack nova compute keystone-api.openstack.svc.cluster.local:5000 success
  test_netpol openstack neutron l3-agent keystone-api.openstack.svc.cluster.local:5000 success
  test_netpol openstack ingress server glance-api.openstack.svc.cluster.local:9292 success
  test_netpol openstack nova os-api glance-api.openstack.svc.cluster.local:9292 success
  test_netpol openstack nova compute glance-api.openstack.svc.cluster.local:9292 success
  test_netpol openstack heat api glance-api.openstack.svc.cluster.local:9292 success
  test_netpol openstack horizon server glance-api.openstack.svc.cluster.local:9292 success
  test_netpol openstack horizon server heat-api.openstack.svc.cluster.local:8004 success
  test_netpol openstack horizon server heat-cfn.openstack.svc.cluster.local:8000 success
  test_netpol openstack heat api heat-api.openstack.svc.cluster.local:8004 success
fi

echo Test Success
