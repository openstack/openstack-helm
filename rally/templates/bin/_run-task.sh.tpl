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


: ${RALLY_ENV_NAME:="openstack-helm"}

function run_rally () {
  CURRENT_TEST=$1
  rally deployment use ${RALLY_ENV_NAME}
  rally deployment check
  rally task validate /tasks/rally/${CURRENT_TEST}.yaml
  rally task start /tasks/rally/${CURRENT_TEST}.yaml
  rally task list
  rally task report --out /var/lib/rally/data/${CURRENT_TEST}.html
  rally task sla-check

}

function create_deployment () {
  listResults=$(rally deployment list)

  if [ $(echo $listResults | awk '{print $1;}') = "There"  ]
  then
    rally deployment create --fromenv --name ${RALLY_ENV_NAME}
  fi
}

create_deployment

IFS=','; for TEST in $ENABLED_TESTS; do
  run_rally $TEST
done

exit 0
