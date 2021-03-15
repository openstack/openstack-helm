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

#!/bin/bash

set -e

function create_s3_user () {
  echo "Creating s3 user and key pair"
  radosgw-admin user create \
    --uid=${S3_USERNAME} \
    --display-name=${S3_USERNAME} \
    --key-type=s3 \
    --access-key ${S3_ACCESS_KEY} \
    --secret-key ${S3_SECRET_KEY}
}

function update_s3_user () {
  # Retrieve old access keys, if they exist
  old_access_keys=$(radosgw-admin user info --uid=${S3_USERNAME} \
    | jq -r '.keys[].access_key' || true)
  if [[ ! -z ${old_access_keys} ]]; then
    for access_key in $old_access_keys; do
      # If current access key is the same as the key supplied, do nothing.
      if [ "$access_key" == "${S3_ACCESS_KEY}" ]; then
        echo "Current user and key pair exists."
        continue
      else
        # If keys differ, remove previous key
        radosgw-admin key rm --uid=${S3_USERNAME} --key-type=s3 --access-key=$access_key
      fi
    done
  fi
  # Perform one more additional check to account for scenarios where multiple
  # key pairs existed previously, but one existing key was the supplied key
  current_access_key=$(radosgw-admin user info --uid=${S3_USERNAME} \
    | jq -r '.keys[].access_key' || true)
  # If the supplied key does not exist, modify the user
  if [[ -z ${current_access_key} ]]; then
    # Modify user with new access and secret keys
    echo "Updating existing user's key pair"
    radosgw-admin user modify \
      --uid=${S3_USERNAME}\
      --access-key ${S3_ACCESS_KEY} \
      --secret-key ${S3_SECRET_KEY}
  fi
}

{{- range $client, $config := .Values.storage.s3.clients -}}
{{- if $config.create_user | default false }}

S3_USERNAME=${{ printf "%s_S3_USERNAME" ($client | replace "-" "_" | upper)  }}
S3_ACCESS_KEY=${{ printf "%s_S3_ACCESS_KEY" ($client | replace "-" "_" | upper)  }}
S3_SECRET_KEY=${{ printf "%s_S3_SECRET_KEY" ($client | replace "-" "_" | upper)  }}

user_exists=$(radosgw-admin user info --uid=${S3_USERNAME} || true)
if [[ -z ${user_exists} ]]; then
  echo "Creating $S3_USERNAME"
  create_s3_user > /dev/null 2>&1
else
  echo "Updating $S3_USERNAME"
  update_s3_user > /dev/null 2>&1
fi

{{- end }}
{{- end }}
