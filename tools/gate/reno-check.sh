#!/bin/bash

set -e

RESULT=0

while read -r line; do
  SERVICE=$(echo $line | awk '{ print $1 }' FS=':' | awk '{ print $2 }' FS='/')
  VERSION=$(echo $line | awk '{ print $3 }' FS=':' | xargs)
  if grep -q "$VERSION" ./releasenotes/notes/$SERVICE.yaml ; then
    echo "$SERVICE is up to date!"
  else
    echo "$SERVICE version does not match release notes. Likely requires a release note update"
    RESULT=1
  fi
done < <(grep -r --include Chart.yaml "version:" .)

exit $RESULT
