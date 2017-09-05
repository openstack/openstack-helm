#!/bin/bash
set -ex
export LC_ALL=C

source variables_entrypoint.sh
source common_functions.sh

if [[ ! -e /etc/ceph/${CLUSTER}.conf ]]; then
  log "ERROR- /etc/ceph/${CLUSTER}.conf must exist; get it from your existing mon"
  exit 1
fi

if [ ${CEPH_GET_ADMIN_KEY} -eq 1 ]; then
  if [[ ! -e $ADMIN_KEYRING ]]; then
      log "ERROR- $ADMIN_KEYRING must exist; get it from your existing mon"
      exit 1
  fi
fi

# Check to see if our RGW has been initialized
if [ ! -e $RGW_KEYRING ]; then

  if [ ! -e $RGW_BOOTSTRAP_KEYRING ]; then
    log "ERROR- $RGW_BOOTSTRAP_KEYRING must exist. You can extract it from your current monitor by running 'ceph auth get client.bootstrap-rgw -o $RGW_BOOTSTRAP_KEYRING'"
    exit 1
  fi

  timeout 10 ceph ${CLI_OPTS} --name client.bootstrap-rgw --keyring $RGW_BOOTSTRAP_KEYRING health || exit 1

  # Generate the RGW key
  ceph ${CLI_OPTS} --name client.bootstrap-rgw --keyring $RGW_BOOTSTRAP_KEYRING auth get-or-create client.rgw.${RGW_NAME} osd 'allow rwx' mon 'allow rw' -o $RGW_KEYRING
  chown ceph. $RGW_KEYRING
  chmod 0600 $RGW_KEYRING
fi

log "SUCCESS"

RGW_FRONTENDS="civetweb port=$RGW_CIVETWEB_PORT"
if [ "$RGW_REMOTE_CGI" -eq 1 ]; then
  RGW_FRONTENDS="fastcgi socket_port=$RGW_REMOTE_CGI_PORT socket_host=$RGW_REMOTE_CGI_HOST"
fi

exec /usr/bin/radosgw $DAEMON_OPTS -n client.rgw.${RGW_NAME} -k $RGW_KEYRING --rgw-socket-path="" --rgw-zonegroup="$RGW_ZONEGROUP" --rgw-zone="$RGW_ZONE" --rgw-frontends="$RGW_FRONTENDS"
