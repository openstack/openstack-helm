#!/bin/bash

EXCLUDES="helm-toolkit doc tests tools logs tmp roles playbooks releasenotes zuul.d python-files"
DIRS=`ls -d */ | cut -f1 -d'/'`

for EX in $EXCLUDES; do
  DIRS=`echo $DIRS | sed "s/\b$EX\b//g"`
done

for DIR in $DIRS; do
  PYFILES=$(helm template $DIR | yq 'select(.data != null) | .data | to_entries | map(select(.key | test(".*\\.py"))) | select(length > 0) | values[] | {(.key) : (.value)}' | jq -s add)
  PYKEYS=$(echo "$PYFILES" | jq -r 'select(. != null) | keys[]')
  for KEY in $PYKEYS; do
    echo "$PYFILES" | jq -r --arg KEY "$KEY" '.[$KEY]' > ./python-files/"$DIR-$KEY"
  done
done
