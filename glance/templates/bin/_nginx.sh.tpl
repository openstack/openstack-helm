#!/bin/bash
set -xe

COMMAND="${@:-start}"

function start () {
  envsubst < /etc/nginx/nginx.conf > /tmp/nginx.conf
  cat /tmp/nginx.conf
  nginx -t -c /tmp/nginx.conf
  exec nginx -c /tmp/nginx.conf
}

function stop () {
  nginx -s stop
}

$COMMAND
