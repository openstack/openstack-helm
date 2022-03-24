#!/bin/bash

set -e
RESULT=0
IFS=$'\n'
for chart in $(find $(pwd) -maxdepth 2 -name 'Chart.yaml');do
  SERVICE=$(egrep "^name:" "$chart"|awk -F ' ' '{print $2}')
  VERSION=$(egrep "^version:" "$chart"|awk -F ' ' '{print $2}')
  if grep -q "$VERSION" ./releasenotes/notes/$SERVICE.yaml ; then
    echo "$SERVICE is up to date!"
  else
    echo "$SERVICE version does not match release notes. Likely requires a release note update"
    RESULT=1
  fi
done

exit $RESULT
