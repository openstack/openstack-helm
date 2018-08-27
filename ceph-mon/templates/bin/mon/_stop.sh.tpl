#!/bin/bash

set -ex

NUMBER_OF_MONS=$(ceph mon stat | awk '$3 == "mons" {print $2}')
if [ "${NUMBER_OF_MONS}" -gt "1" ]; then
  if [[ ${K8S_HOST_NETWORK} -eq 0 ]]; then
      ceph mon remove "${POD_NAME}"
  else
      ceph mon remove "${NODE_NAME}"
  fi
else
  echo "we are the last mon, not removing"
fi
