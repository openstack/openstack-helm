#!/bin/bash
{{/*
Copyright 2019 The Openstack-Helm Authors.

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

function create_topic () {
    ./opt/kafka/bin/kafka-topics.sh \
        --create --topic $1 \
        --partitions $2 \
        --replication-factor $3 \
        --bootstrap-server $KAFKA_BROKERS
}

function describe_topic () {
    ./opt/kafka/bin/kafka-topics.sh \
        --describe --topic $1 \
        --bootstrap-server $KAFKA_BROKERS
}

function produce_message () {
    echo $2 | \
    ./opt/kafka/bin/kafka-console-producer.sh \
        --topic $1 \
        --broker-list $KAFKA_BROKERS
}

function consume_messages () {
    ./opt/kafka/bin/kafka-console-consumer.sh \
        --topic $1 \
        --timeout-ms 500 \
        --from-beginning \
        --bootstrap-server $KAFKA_BROKERS
}

function delete_partition_messages () {
    ./opt/kafka/bin/kafka-delete-records.sh \
        --offset-json-file $1 \
        --bootstrap-server $KAFKA_BROKERS
}

function delete_topic () {
    ./opt/kafka/bin/kafka-topics.sh \
        --delete --topic $1 \
        --bootstrap-server $KAFKA_BROKERS
}

set -e

TOPIC="kafka-test"
PARTITION_COUNT=3
PARTITION_REPLICAS=2

echo "Creating topic $TOPIC"
create_topic $TOPIC $PARTITION_COUNT $PARTITION_REPLICAS
describe_topic $TOPIC

echo "Producing 5 messages"
for i in {1..5}; do
    MESSAGE="Message #$i"
    produce_message $TOPIC "$MESSAGE"
done

echo -e "\nConsuming messages (A \"TimeoutException\" is expected, else this would consume forever)"
consume_messages $TOPIC

echo "Producing 5 more messages"
for i in {6..10}; do
    MESSAGE="Message #$i"
    produce_message $TOPIC "$MESSAGE"
done

echo -e "\nCreating partition offset reset json file"
tee /tmp/partition_offsets.json << EOF
{
"partitions": [
    {
        "topic": "$TOPIC",
        "partition": 0,
        "offset": -1
    }, {
        "topic": "$TOPIC",
        "partition": 1,
        "offset": -1
    }, {
        "topic": "$TOPIC",
        "partition": 2,
        "offset": -1
    }
],
"version": 1
}
EOF

echo "Resetting $TOPIC partitions (deleting messages)"
delete_partition_messages /tmp/partition_offsets.json

echo "Deleting topic $TOPIC"
delete_topic $TOPIC

if [ $(describe_topic $TOPIC | wc -l) -eq 0 ]; then
    echo "Topic $TOPIC was deleted successfully."
    exit 0
else
    echo "Topic $TOPIC was not successfully deleted."
    exit 1
fi
