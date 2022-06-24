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

set -ex

python='python'
if [[ $(which python3) ]]; then
    python='python3'
fi

function create_test_index () {
  index_result=$(curl ${CACERT_OPTION} -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
  -XPUT "${ELASTICSEARCH_ENDPOINT}/test_index?pretty" -H 'Content-Type: application/json' -d'
  {
    "settings" : {
      "index" : {
        "number_of_shards" : 3,
        "number_of_replicas" : 2
      }
    }
  }
  ' | $python -c "import sys, json; print(json.load(sys.stdin)['acknowledged'])")
  if [ "$index_result" == "True" ];
  then
    echo "PASS: Test index created!";
  else
    echo "FAIL: Test index not created!";
    exit 1;
  fi
}

function remove_test_index () {
  echo "Deleting index created for service testing"
  curl ${CACERT_OPTION} -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
  -XDELETE "${ELASTICSEARCH_ENDPOINT}/test_index"
}

remove_test_index || true
create_test_index
remove_test_index
