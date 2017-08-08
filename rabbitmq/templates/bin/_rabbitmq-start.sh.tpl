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

set -eux
set -o pipefail
cp /etc/rabbitmq/erlang.cookie /var/lib/rabbitmq/.erlang.cookie
chmod 600 /var/lib/rabbitmq/.erlang.cookie
# This should be called after rabbitmq-server is started but in current design we don't have
# any other way of doing this. PreStart could not be used here as it's:
# - executed just after container creation (not after entrypoint)
# - Currently, there are (hopefully rare) scenarios where PostStart hooks may not be delivered.
# Startup marker is used by liveness and readiness probes.
date +%s > /tmp/rabbit-startup-marker
exec /usr/lib/rabbitmq/bin/rabbitmq-server
