#!/bin/bash
{{/*
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

{{- $envAll := . }}

set -e
COMMAND="${@:-start}"

function initiate_keystore () {
  elasticsearch-keystore create
  {{- if .Values.conf.elasticsearch.snapshots.enabled }}
  {{- range $client, $settings := .Values.storage.s3.clients -}}
  {{- $access_key := printf "%s_S3_ACCESS_KEY" ( $client | replace "-" "_" | upper) }}
  {{- $secret_key := printf "%s_S3_SECRET_KEY" ( $client | replace "-" "_" | upper) }}
  echo ${{$access_key}} | elasticsearch-keystore add -xf s3.client.{{ $client }}.access_key
  echo ${{$secret_key}} | elasticsearch-keystore add -xf s3.client.{{ $client }}.secret_key
  {{- end }}
  {{- end }}

  {{- if .Values.manifests.certificates }}
  {{- $alias := .Values.secrets.tls.elasticsearch.elasticsearch.internal }}
  JAVA_KEYTOOL_PATH=/usr/share/elasticsearch/jdk/bin/keytool
  TRUSTSTORE_PATH=/usr/share/elasticsearch/config/elasticsearch-java-truststore
  ${JAVA_KEYTOOL_PATH} -importcert -alias {{$alias}} -keystore ${TRUSTSTORE_PATH} -trustcacerts -noprompt -file ${JAVA_KEYSTORE_CERT_PATH} -storepass ${ELASTICSEARCH_PASSWORD}
  ${JAVA_KEYTOOL_PATH} -storepasswd -keystore ${TRUSTSTORE_PATH} -new ${ELASTICSEARCH_PASSWORD} -storepass ${ELASTICSEARCH_PASSWORD}
  {{- end }}
}

function start () {
  initiate_keystore
  exec /usr/local/bin/docker-entrypoint.sh elasticsearch
}

function stop () {
  kill -TERM 1
}

function wait_to_join() {
  # delay 5 seconds before the first check
  sleep 5
  joined=$(curl -s ${CACERT_OPTION} -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" "${ELASTICSEARCH_ENDPOINT}/_cat/nodes" | grep -w $NODE_NAME || true )
  i=0
  while [ -z "$joined" ]; do
    sleep 5
    joined=$(curl -s ${CACERT_OPTION} -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" "${ELASTICSEARCH_ENDPOINT}/_cat/nodes" | grep -w $NODE_NAME || true )
    i=$((i+1))
    # Waiting for up to 60 minutes
    if [ $i -gt 720 ]; then
      break
    fi
  done
}

function allocate_data_node () {
  echo "Node ${NODE_NAME} has started. Waiting to rejoin the cluster."
  wait_to_join
  echo "Re-enabling Replica Shard Allocation"
  curl -s ${CACERT_OPTION} -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" -XPUT -H 'Content-Type: application/json' \
    "${ELASTICSEARCH_ENDPOINT}/_cluster/settings" -d "{
    \"persistent\": {
      \"cluster.routing.allocation.enable\": null
    }
  }"
}

function start_master_node () {
  initiate_keystore
  if [ ! -f {{ $envAll.Values.conf.elasticsearch.config.path.data }}/cluster-bootstrap.txt ];
  then
    {{ if empty $envAll.Values.conf.elasticsearch.config.cluster.initial_master_nodes -}}
    {{- $_ := set $envAll.Values "__eligible_masters" ( list ) }}
    {{- range $podInt := until ( atoi (print $envAll.Values.pod.replicas.master ) ) }}
    {{- $eligibleMaster := printf "elasticsearch-master-%s" (toString $podInt) }}
    {{- $__eligible_masters := append $envAll.Values.__eligible_masters $eligibleMaster }}
    {{- $_ := set $envAll.Values "__eligible_masters" $__eligible_masters }}
    {{- end -}}
    {{- $masters := include "helm-toolkit.utils.joinListWithComma" $envAll.Values.__eligible_masters -}}
    echo {{$masters}} >> {{ $envAll.Values.conf.elasticsearch.config.path.data }}/cluster-bootstrap.txt
    exec /usr/local/bin/docker-entrypoint.sh elasticsearch -Ecluster.initial_master_nodes={{$masters}}
    {{- end }}
  else
    exec /usr/local/bin/docker-entrypoint.sh elasticsearch
  fi
}

function start_data_node () {
  initiate_keystore
  allocate_data_node &
  /usr/local/bin/docker-entrypoint.sh elasticsearch &
  function drain_data_node () {

    # Implement the Rolling Restart Protocol Described Here:
    # https://www.elastic.co/guide/en/elasticsearch/reference/7.x/restart-cluster.html#restart-cluster-rolling

    echo "Disabling Replica Shard Allocation"
    curl -s ${CACERT_OPTION} -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" -XPUT -H 'Content-Type: application/json' \
      "${ELASTICSEARCH_ENDPOINT}/_cluster/settings" -d "{
      \"persistent\": {
        \"cluster.routing.allocation.enable\": \"primaries\"
      }
    }"

    # If version < 7.6 use _flush/synced; otherwise use _flush
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-synced-flush-api.html#indices-synced-flush-api

    version=$(curl -s ${CACERT_OPTION} -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" "${ELASTICSEARCH_ENDPOINT}/" | jq -r .version.number)

    if [[ $version =~ "7.1" ]]; then
      action="_flush/synced"
    else
      action="_flush"
    fi

    curl -s ${CACERT_OPTION} -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" -XPOST "${ELASTICSEARCH_ENDPOINT}/$action"

    # TODO: Check the response of synced flush operations to make sure there are no failures.
    # Synced flush operations that fail due to pending indexing operations are listed in the response body,
    # although the request itself still returns a 200 OK status. If there are failures, reissue the request.
    # (The only side effect of not doing so is slower start up times. See flush documentation linked above)

    echo "Node ${NODE_NAME} is ready to shutdown"

    echo "Killing Elasticsearch background processes"
    jobs -p | xargs -t -r kill -TERM
    wait

    # remove the trap handler
    trap - TERM EXIT HUP INT

    echo "Node ${NODE_NAME} shutdown is complete"
    exit 0
  }
  trap drain_data_node TERM EXIT HUP INT
  wait

}

$COMMAND
