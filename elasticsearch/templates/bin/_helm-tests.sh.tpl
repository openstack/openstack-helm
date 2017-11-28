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


set -ex

function create_index () {
  index_result=$(curl -XPUT "${ELASTICSEARCH_ENDPOINT}/test_index?pretty" -H 'Content-Type: application/json' -d'
  {
    "settings" : {
      "index" : {
        "number_of_shards" : 3,
        "number_of_replicas" : 2
      }
    }
  }
  ' | python -c "import sys, json; print json.load(sys.stdin)['acknowledged']")
  if [ "$index_result" == "True" ];
  then
     echo "PASS: Test index created!"
  else
     echo "FAIL: Test index not created!";
     exit 1;
  fi
}

function insert_test_data () {
  insert_result=$(curl -XPUT "${ELASTICSEARCH_ENDPOINT}/sample_index/sample_type/123/_create?pretty" -H 'Content-Type: application/json' -d'
  {
      "name" : "Elasticsearch",
      "message" : "Test data text entry"
  }
  ' | python -c "import sys, json; print json.load(sys.stdin)['created']")
  if [ "$insert_result" == "True" ]; then
     sleep 20
     echo "PASS: Test data inserted into test index!"
  else
     echo "FAIL: Test data not inserted into test index!";
     exit 1;
  fi
}


function check_hits () {
  total_hits=$(curl -XGET "${ELASTICSEARCH_ENDPOINT}/_search?pretty" -H 'Content-Type: application/json' -d'
    {
      "query" : {
        "bool": {
          "must": [
            { "match": { "name": "Elasticsearch" }},
            { "match": { "message": "Test data text entry" }}
          ]
        }
      }
    }
    ' | python -c "import sys, json; print json.load(sys.stdin)['hits']['total']")
  if [ "$total_hits" -gt 0 ]; then
     echo "PASS: Successful hits on test data query!"
  else
     echo "FAIL: No hits on query for test data! Exiting";
     exit 1;
  fi
}

create_index
insert_test_data
check_hits
