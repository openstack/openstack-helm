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

export OS_CLOUD=openstack_helm
function keystone_token () {
  openstack token issue -f value -c id
}

function report_failed_policy () {
  echo "$1 was $2 to perform $3, which contradicts current policy"
  exit 1
}

function test_user_is_authorized () {
  TOKEN=$(keystone_token)
  if ! kubectl --kubeconfig /tmp/kubeconfig.yaml --token $TOKEN $1 ; then
    report_failed_policy "$OS_USERNAME" "not allowed" "$1"
  fi
}

function test_user_is_unauthorized () {
  TOKEN=$(keystone_token)
  if ! kubectl --kubeconfig /tmp/kubeconfig.yaml --token $TOKEN $1 ; then
    echo "Denied, as expected by policy"
  else
    report_failed_policy "$OS_USERNAME" "allowed" "$1"
  fi
}

sudo cp -va $HOME/.kube/config /tmp/kubeconfig.yaml
sudo kubectl --kubeconfig /tmp/kubeconfig.yaml config unset users.kubernetes-admin

# Test
# This issues token with admin role
TOKEN=$(keystone_token)
kubectl --kubeconfig /tmp/kubeconfig.yaml --token $TOKEN get pods
kubectl --kubeconfig /tmp/kubeconfig.yaml --token $TOKEN get pods -n openstack
kubectl --kubeconfig /tmp/kubeconfig.yaml --token $TOKEN get secrets -n openstack

# This is used to grab a pod name for the following tests
TEST_POD="$(kubectl get pods -n openstack | awk 'NR==2{print $1}')"

# create users
openstack user create --or-show --password password admin_k8cluster_user
openstack user create --or-show --password password admin_k8cluster_edit_user
openstack user create --or-show --password password admin_k8cluster_view_user

# create project
openstack project create --or-show openstack-system
openstack project create --or-show demoProject

# create roles
openstack role create --or-show openstackRole
openstack role create --or-show kube-system-admin
openstack role create --or-show admin_k8cluster
openstack role create --or-show admin_k8cluster_editor
openstack role create --or-show admin_k8cluster_viewer

# assign user role to project
openstack role add --project openstack-system --user bob --project-domain default --user-domain ldapdomain openstackRole
openstack role add --project demoProject --user alice --project-domain default --user-domain ldapdomain kube-system-admin
openstack role add --project demoProject --user admin_k8cluster_user --project-domain default --user-domain default admin_k8cluster
openstack role add --project demoProject --user admin_k8cluster_edit_user --project-domain default --user-domain default admin_k8cluster_editor
openstack role add --project demoProject --user admin_k8cluster_view_user --project-domain default --user-domain default admin_k8cluster_viewer

unset OS_CLOUD
export OS_AUTH_URL="http://keystone.openstack.svc.cluster.local/v3"
export OS_IDENTITY_API_VERSION="3"
export OS_PROJECT_NAME="openstack-system"
export OS_PASSWORD="password"
export OS_USERNAME="bob"
export OS_USER_DOMAIN_NAME="ldapdomain"

# Create files for secret generation
echo -n 'admin' > /tmp/user.txt
echo -n 'password' > /tmp/pass.txt

# See this does fail as the policy does not allow for a non-admin user
TOKEN=$(keystone_token)
test_user_is_unauthorized "get pods"

export OS_USERNAME="alice"
export OS_PROJECT_NAME="demoProject"
test_user_is_unauthorized "get pods -n openstack"

export OS_USER_DOMAIN_NAME="default"

#admin_k8cluser_user
export OS_USERNAME="admin_k8cluster_user"
RESOURCES=("pods" "configmaps" "endpoints" "persistentvolumeclaims" \
           "replicationcontrollers" "secrets" "serviceaccounts" \
           "services" "events" "limitranges" "namespace" \
           "replicationcontrollers" "resourcequotas" "daemonsets" \
           "deployments" "replicasets" "statefulsets" "jobs" \
           "cronjobs" "poddisruptionbudgets" "serviceaccounts" \
           "networkpolicies" "horizontalpodautoscalers")
for r in "${RESOURCES[@]}" ; do
  test_user_is_authorized "get $r"
done

test_user_is_authorized "create secret generic test-secret --from-file=/tmp/user.txt --from-file=/tmp/pass.txt"
test_user_is_authorized "delete secret test-secret"

#admin_k8cluster_edit_user
export OS_USERNAME="admin_k8cluster_edit_user"
RESOURCES=("pods" "configmaps" "endpoints" "persistentvolumeclaims" \
           "replicationcontrollers" "secrets" "serviceaccounts" \
           "services" "events" "limitranges" "namespace" \
           "replicationcontrollers" "resourcequotas" "daemonsets" \
           "deployments" "replicasets" "statefulsets" "jobs" \
           "cronjobs" "poddisruptionbudgets" "serviceaccounts" \
           "networkpolicies" "horizontalpodautoscalers")
for r in "${RESOURCES[@]}" ; do
  test_user_is_authorized "get $r"
done

test_user_is_authorized "create secret generic test-secret --from-file=/tmp/user.txt --from-file=/tmp/pass.txt"
test_user_is_authorized "delete secret test-secret"
test_user_is_authorized "logs -n openstack $TEST_POD --tail=5"

test_user_is_unauthorized "create namespace test"


#admin_k8cluster_view_user
export OS_USERNAME="admin_k8cluster_view_user"
RESOURCES=("pods" "configmaps" "endpoints" "persistentvolumeclaims" \
           "replicationcontrollers" "services" "serviceaccounts" \
           "replicationcontrollers" "resourcequotas" "namespaces" \
           "daemonsets" "deployments" "replicasets" "statefulsets" \
           "poddisruptionbudgets" "networkpolicies")
for r in "${RESOURCES[@]}" ; do
  test_user_is_authorized "get $r"
done

test_user_is_authorized "logs -n openstack $TEST_POD --tail=5"

test_user_is_unauthorized "delete pod $TEST_POD -n openstack"
test_user_is_unauthorized "create namespace test"
test_user_is_unauthorized "get secrets"
test_user_is_unauthorized "create secret generic test-secret --from-file=/tmp/user.txt --from-file=/tmp/pass.txt"
