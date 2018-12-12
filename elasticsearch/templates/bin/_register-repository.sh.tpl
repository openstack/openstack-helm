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

{{ $envAll := . }}

set -ex

{{ range $repository := $envAll.Values.conf.elasticsearch.snapshots.repositories }}
result=$(curl -K- <<< "--user ${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}" \
  "${ELASTICSEARCH_HOST}/_snapshot/{{$repository.name}}" \
  -H 'Content-Type: application/json' -d'
  {
    "type": "s3",
    "settings": {
      "endpoint": "'"$RGW_HOST"'",
      "protocol": "http",
      "bucket": "'"$S3_BUCKET"'",
      "access_key": "'"$S3_ACCESS_KEY"'",
      "secret_key": "'"$S3_SECRET_KEY"'"
    }
  }' | python -c "import sys, json; print json.load(sys.stdin)['acknowledged']")
if [ "$result" == "True" ];
then
   echo "Snapshot repository {{$repository.name}} created!";
else
   echo "Snapshot repository {{$repository.name}} not created!";
   exit 1;
fi
{{ end }}
