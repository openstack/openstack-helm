#!/bin/bash

{{/*
Copyright 2017 The Openstack-Helm Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -e

# Extract connection details
RABBIT_HOSTNAME=`echo $RABBITMQ_ADMIN_CONNECTION | awk -F'[@]' '{print $2}' \
  | awk -F'[:/]' '{print $1}'`
RABBIT_PORT=`echo $RABBITMQ_ADMIN_CONNECTION | awk -F'[@]' '{print $2}' \
  | awk -F'[:/]' '{print $2}'`

# Extract Admin User creadential
RABBITMQ_ADMIN_USERNAME=`echo $RABBITMQ_ADMIN_CONNECTION | awk -F'[@]' '{print $1}' \
  | awk -F'[//:]' '{print $4}'`
RABBITMQ_ADMIN_PASSWORD=`echo $RABBITMQ_ADMIN_CONNECTION | awk -F'[@]' '{print $1}' \
  | awk -F'[//:]' '{print $5}'`

function active_rabbit_nodes () {
  rabbitmqadmin \
    --host="${RABBIT_HOSTNAME}" \
    --port="${RABBIT_PORT}" \
    --username="${RABBITMQ_ADMIN_USERNAME}" \
    --password="${RABBITMQ_ADMIN_PASSWORD}" \
    list nodes -f bash | wc -w
}

until test "$(active_rabbit_nodes)" -ge "$RABBIT_REPLICA_COUNT"; do
    echo "Waiting for number of nodes in cluster to match number of desired pods ($RABBIT_REPLICA_COUNT)"
    sleep 10
done
