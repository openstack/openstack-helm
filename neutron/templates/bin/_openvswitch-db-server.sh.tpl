#!/bin/bash
set -ex

mkdir -p "/run/openvswitch"
if [[ ! -e "/run/openvswitch/conf.db" ]]; then
  ovsdb-tool create "/run/openvswitch/conf.db"
fi

umask 000    
exec /usr/sbin/ovsdb-server /run/openvswitch/conf.db -vconsole:emer -vconsole:err -vconsole:info --remote=punix:/run/openvswitch/db.sock
