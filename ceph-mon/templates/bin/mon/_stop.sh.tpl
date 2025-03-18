#!/bin/bash

set -ex

NUMBER_OF_MONS=$(ceph mon stat | awk '$3 == "mons" {print $2}')
if [[ "${NUMBER_OF_MONS}" -gt "3" ]]; then
  if [[ ${K8S_HOST_NETWORK} -eq 0 ]]; then
      ceph mon remove "${POD_NAME}"
  else
      ceph mon remove "${NODE_NAME}"
  fi
else
  echo "doing nothing since we are running less than or equal to 3 mons"
fi
