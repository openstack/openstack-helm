#!/bin/bash

{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*/}}

set -ex
export HOME=/tmp

echo "Test: list queues"
openstack queue list

QUEUE_NAME="test-queue-$(uuidgen | cut -d'-' -f1)"

echo "Test: create queue"
openstack queue create ${QUEUE_NAME}

echo "Test: post messages"
openstack message post ${QUEUE_NAME} --message '{"body":"Hello World 1"}'
openstack message post ${QUEUE_NAME} --message '{"body":"Hello World 2"}'

echo "Test: list messages"
openstack message list ${QUEUE_NAME}

echo "Test: get a single message"
MESSAGE_ID=$(openstack message list ${QUEUE_NAME} -f value -c id | head -1)
openstack message get ${QUEUE_NAME} ${MESSAGE_ID}

echo "Test: claim messages"
CLAIM_ID=$(openstack claim create ${QUEUE_NAME} --ttl 30 --grace 30 -f value -c id)
openstack claim get ${QUEUE_NAME} ${CLAIM_ID}

echo "Test: delete messages"
openstack message delete ${QUEUE_NAME} ${MESSAGE_ID}

echo "Test: delete queue"
openstack queue delete ${QUEUE_NAME}

exit 0
