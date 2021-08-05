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
OPTIONS="-w "%{http_code}" --output /dev/stderr --silent -X POST -u ${INFLUXDB_USER}:${INFLUXDB_PASSWORD}"

status_code=$(curl ${OPTIONS} ${INFLUXDB_URL}query --data-urlencode "q=CREATE DATABASE monasca")
if [ $status_code -lt 200 ] || ([ $status_code -gt 299 ] && [ $status_code -ne 409 ])
then
   exit 1
fi

status_code=$(curl ${OPTIONS} ${INFLUXDB_URL}query --data-urlencode "q=CREATE RETENTION POLICY persister_all ON monasca DURATION 90d REPLICATION 1 DEFAULT")
if [ $status_code -lt 200 ] || ([ $status_code -gt 299 ] && [ $status_code -ne 409 ])
then
   exit 1
fi

status_code=$(curl ${OPTIONS} ${INFLUXDB_URL}query --data-urlencode "q=CREATE USER \"${INFLUXDB_API_USER}\" WITH PASSWORD '${INFLUXDB_API_PASSWORD}'")
if [ $status_code -lt 200 ] || ([ $status_code -gt 299 ] && [ $status_code -ne 409 ])
then
   exit 1
fi

status_code=$(curl ${OPTIONS} ${INFLUXDB_URL}query --data-urlencode "q=GRANT ALL TO \"${INFLUXDB_API_USER}\"")
if [ $status_code -lt 200 ] || ([ $status_code -gt 299 ] && [ $status_code -ne 409 ])
then
   exit 1
fi

status_code=$(curl ${OPTIONS} ${INFLUXDB_URL}query --data-urlencode "q=CREATE USER \"${INFLUXDB_PERSISTER_USER}\" WITH PASSWORD '${INFLUXDB_PERSISTER_PASSWORD}'")
if [ $status_code -lt 200 ] || ([ $status_code -gt 299 ] && [ $status_code -ne 409 ])
then
   exit 1
fi

status_code=$(curl ${OPTIONS} ${INFLUXDB_URL}query --data-urlencode "q=GRANT ALL ON monasca TO \"${INFLUXDB_PERSISTER_USER}\"")
if [ $status_code -lt 200 ] || ([ $status_code -gt 299 ] && [ $status_code -ne 409 ])
then
   exit 1
fi