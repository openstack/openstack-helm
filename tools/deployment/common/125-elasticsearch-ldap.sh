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

ELASTICSEARCH_ENDPOINT="elasticsearch-logging.osh-infra"

#NOTE: Create index with specified LDAP user
function create_index () {
  index_result=$(curl -K- <<< "--user $1:$2" \
  -XPUT "${ELASTICSEARCH_ENDPOINT}/$1_index?pretty" -H 'Content-Type: application/json' -d'
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
     echo "$1's index successfully created!";
  else
     echo "$1's index not created!";
     exit 1;
  fi
}

#NOTE: Insert test data with specified LDAP user
function insert_test_data () {
  insert_result=$(curl -K- <<< "--user $1:$2" \
  -XPUT "${ELASTICSEARCH_ENDPOINT}/$1_index/sample_type/123/_create?pretty" -H 'Content-Type: application/json' -d'
  {
      "name" : "Elasticsearch",
      "message" : "Test data text entry"
  }
  ' | python -c "import sys, json; print json.load(sys.stdin)['result']")
  if [ "$insert_result" == "created" ]; then
     sleep 20
     echo "Test data inserted into $1's index!";
  else
     echo "Test data not inserted into $1's index!";
     exit 1;
  fi
}

#NOTE: Check hits on test data in specified LDAP user's index
function check_hits () {
  total_hits=$(curl -K- <<< "--user $1:$2" \
  "${ELASTICSEARCH_ENDPOINT}/_search?pretty" -H 'Content-Type: application/json' -d'
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
     echo "Successful hits on test data query on $1's index!"
  else
     echo "No hits on query for test data on $1's index!";
     exit 1;
  fi
}

create_index bob password
create_index alice password

insert_test_data bob password
insert_test_data alice password

check_hits bob password
check_hits alice password
