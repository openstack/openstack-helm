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

namespace="metacontroller"
: ${HELM_ARGS_DAEMONJOB_CONTROLLER:="$(./tools/deployment/common/get-values-overrides.sh daemonjob-controller)"}

#NOTE: Lint and package chart
make daemonjob-controller

#NOTE: Deploy command
helm upgrade --install daemonjob-controller ./daemonjob-controller \
    --namespace=$namespace \
    --set pod.replicas.daemonjob_controller=4 \
    ${HELM_ARGS_DAEMONJOB_CONTROLLER}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh daemonjob-controller

#NOTE: CompositeController succesfully deployed
composite_controller_cr=$(kubectl get compositecontrollers | awk '{print $1}')
echo "$composite_controller_cr, a CompositeController created succesfully"

#NOTE: Check crd of APIGroup ctl.example.com
daemonjob_crd=$(kubectl get crd | awk '/ctl.example.com/{print $1}')
echo "$daemonjob_crd is succesfully created"

#NOTE: Check daemonjob_controller is running
pod=$(kubectl get pods -n $namespace | awk '/daemonjob-controller/{print $1}')
daemonjob_controller_status=$(kubectl get pods -n $namespace | awk '/daemonjob-controller/{print $3}')

NEXT_WAIT_TIME=0
until [[ $daemonjob_controller_status == 'Running' ]] || [ $NEXT_WAIT_TIME -eq 5 ]; do
  daemonjob_controller_status=$(kubectl get pods -n $namespace | awk '/daemonjob-controller/{print $3}')
  echo "DaemonjobController is not still up and running"
  sleep 20
  NEXT_WAIT_TIME=$((NEXT_WAIT_TIME+1))
done

#NOTE: Create sample-daemonjob.yaml
tee /tmp/sample-daemonjob.yaml << EOF
apiVersion: ctl.example.com/v1
kind: DaemonJob
metadata:
  name: hello-world
  annotations:
    imageregistry: "https://hub.docker.com/"
  labels:
    app: hello-world
spec:
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
      annotations:
        container.apparmor.security.beta.kubernetes.io/hello-world: localhost/docker-default
    spec:
      containers:
      - name: hello-world
        image: busybox
        command: ["sh", "-c", "echo 'Hello world' && sleep 120"]
        resources:
          requests:
            cpu: 10m
      terminationGracePeriodSeconds: 10
EOF

dj="daemonjobs"

#NOTE: Deploy daemonjob
kubectl apply -f /tmp/sample-daemonjob.yaml

#NOTE: Wait for successful completion
NEXT_WAIT_TIME=0
echo "Wait for successful completion..."
until [[ "$(kubectl get $dj hello-world -o 'jsonpath={.status.conditions[0].status}')" == "True" ]] || [ $NEXT_WAIT_TIME -eq 5 ]; do
  daemonset_pod=$(kubectl get pods | awk '/hello-world-dj/{print $1}')
  if [ -z "$daemonset_pod" ]
  then
    echo "Child resource daemonset not yet created"
  else
    daemonset_pod_status=$(kubectl get pods | awk '/hello-world-dj/{print $3}')
    if [ $daemonset_pod_status == 'Init:0/1' ]; then
      kubectl describe dj hello-world
      init_container_status=$(kubectl get pod $daemonset_pod -o 'jsonpath={.status.initContainerStatuses[0].state.running}')
      if [ ! -z "$init_container_status" ]; then
        expected_log=$(kubectl logs $daemonset_pod -c hello-world)
        if [ $expected_log == 'Hello world' ]; then
          echo "Strings are equal." && break
        fi
      fi
    fi
  fi
  sleep 20
  NEXT_WAIT_TIME=$((NEXT_WAIT_TIME+1))
done

#NOTE: Check that DaemonSet gets cleaned up after finishing
NEXT_WAIT_TIME=0
echo "Check that DaemonSet gets cleaned up after finishing..."
until [[ "$(kubectl get daemonset hello-world-dj 2>&1)" =~ NotFound ]] || [ $NEXT_WAIT_TIME -eq 5 ]; do
  sleep 20
  NEXT_WAIT_TIME=$((NEXT_WAIT_TIME+1))
done
