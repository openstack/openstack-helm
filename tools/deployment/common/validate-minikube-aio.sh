#!/bin/bash

set -ex
cd /tmp
DIFF=$(diff loaded_images images_after_installation)
if [ ! -z ${DIFF} ]; then
  echo -e "Looks like minikube-aio does not contain all images required for minikube installation:\n${DIFF}"
  exit 1
fi
