#!/bin/bash
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
