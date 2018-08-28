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

# Create datasources for congress service
# neutronv2, glancev2, keystonev3
datasource_list={{ include "helm-toolkit.utils.joinListWithSpace" .Values.policy.datasource_services | quote }}
configure_service() {
   service=$1
   service_enabled=`openstack service list | grep $(echo $service | sed 's/v[0-9]$//g') || true`
   datasource_exist=`openstack congress datasource list | awk '{print $4}' |grep $service || true`
   if [ -z "$datasource_exist" ] && [ ! -z "$service_enabled" ]
   then
       openstack congress datasource create $service "$service" \
           --config poll_time={{.Values.policy.poll_time}} \
           --config username=$OS_USERNAME \
           --config tenant_name=$OS_PROJECT_NAME \
           --config password=$OS_PASSWORD \
           --config auth_url=$OS_AUTH_URL
   fi
}

for ds in $datasource_list
do
  configure_service $ds
done
