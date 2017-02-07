#!/bin/bash

for chart in *.tgz; do
  echo "Running helm install --dry-run --debug on $chart";
  helm install --dry-run --debug local/$chart;
done
