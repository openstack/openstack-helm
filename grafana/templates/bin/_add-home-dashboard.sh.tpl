#!/bin/bash

# Copyright 2020 The Openstack-Helm Authors.
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
home_dashboard_id=[]
counter=0

#Loop until home_dashboard_id value is not null. If null sleep for 15s. Retry for 5 times.
until [ $home_dashboard_id != "[]" ]
do
    echo "Waiting for Home Dashboard to load in Grafana"
    sleep 15s
    home_dashboard_id=$(curl -K- <<< "--user ${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}" -XGET "${GRAFANA_URI}api/search?query=OSH%20Home" | sed 's/\[{.id":"*\([0-9a-zA-Z]*\)*,*.*}[]]/\1/')
    echo $home_dashboard_id
    if [ $counter -ge 5 ]; then
      echo "Exiting.. Exceeded the wait."
      break
    fi
    counter=$((counter + 1));
done

if [ $home_dashboard_id != "[]" ]
then
#Set Customized Home Dashboard id as Org preference
  curl -K- <<< "--user ${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}" \
   -XPUT "${GRAFANA_URI}api/org/preferences"  -H "Content-Type: application/json" \
   -d "{\"homeDashboardId\": $home_dashboard_id}"
  echo "Successful"
fi