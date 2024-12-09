#!/bin/bash
#set -x

if [ "x$1" == "x" ]; then
  CHART_DIRS="$(echo ./*/)"
else
  CHART_DIRS="$(echo ./$1/)"
fi

for CHART_DIR in ${CHART_DIRS} ; do
#   echo $CHART_DIR
  if [ -e ${CHART_DIR}values.yaml ]; then
    for IMAGE in $(cat ${CHART_DIR}values.yaml | yq '.images.tags | map(.) | join(" ")' | tr -d '"'); do
    #   sudo docker inspect $IMAGE >/dev/null|| sudo docker pull $IMAGE
      echo $IMAGE
    done
  fi
done