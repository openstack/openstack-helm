#!/bin/sh
set -xe

COMMAND="${@:-start}"

start () {
  envsubst '${SHORTNAME} ${POD_IP} ${PORT}' < /etc/nginx/nginx.conf > /tmp/nginx.conf
  cat /tmp/nginx.conf
  nginx -t -c /tmp/nginx.conf
  exec nginx -c /tmp/nginx.conf
}

stop () {
  nginx -s stop
}

$COMMAND
