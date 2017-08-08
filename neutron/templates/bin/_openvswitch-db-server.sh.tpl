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

mkdir -p "/run/openvswitch"
if [[ ! -e "/run/openvswitch/conf.db" ]]; then
  ovsdb-tool create "/run/openvswitch/conf.db"
fi

umask 000
exec /usr/sbin/ovsdb-server /run/openvswitch/conf.db -vconsole:emer -vconsole:err -vconsole:info --remote=punix:/run/openvswitch/db.sock
