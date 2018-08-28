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


datasource_list={{ include "helm-toolkit.utils.joinListWithSpace" .Values.policy.datasource_services | quote }}
random_string=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1`

if [ ! -z "$datasource_list" ]
  then
    # Try to create policy and rule with every enabled datasource "neutronv2, glancev2"
    # Datasources should be created during installation step via _ds_create.sh.tpl script
    for ds in $datasource_list
      do
          policy_name="${ds}_policy_${random_string}"
          openstack congress policy create $policy_name

          openstack congress policy rule create $policy_name "
             ${policy_name}_rule(id) :-
              ${ds}(id)"

          openstack congress policy delete $policy_name
    done
  else
    echo "No datasource enabled."
    exit 1

fi
