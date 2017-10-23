#!/bin/bash
set -x
for CHART_DIR in ./*/ ; do
  if [ -e ${CHART_DIR}values.yaml ]; then
    for IMAGE in $(cat ${CHART_DIR}values.yaml | yq '.images.tags | map(.) | join(" ")' | tr -d '"'); do
      docker inspect $IMAGE >/dev/null|| docker pull $IMAGE
    done
  fi
done
