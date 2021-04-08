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

{{ $envAll := . }}

set -ex

function verify_snapshot_repository() {
  curl ${CACERT_OPTION} -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
    -XPOST "${ELASTICSEARCH_ENDPOINT}/_snapshot/$1/_verify"
}

repositories=$(curl ${CACERT_OPTION} -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
                "${ELASTICSEARCH_ENDPOINT}/_snapshot" | jq -r 'keys | @sh')

repositories=$(echo $repositories | sed "s/'//g") # Strip single quotes from jq output

for repository in $repositories; do
  error=$(verify_snapshot_repository $repository | jq -r '.error' )
  if [ $error == "null" ]; then
    echo "$repository is verified."
  else
    echo "Error for $repository: $(echo $error | jq -r)"
    exit 1;
  fi
done
