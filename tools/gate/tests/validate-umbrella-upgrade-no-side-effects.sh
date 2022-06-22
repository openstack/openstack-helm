#!/bin/bash
set -ex

# This test confirms that upgrading a OpenStack Umbrella Helm release using
# --reuse-values does not result in any unexpected pods from being recreated.
# Ideally, no pods would be created if the upgrade has no configuration change.
# Unfortunately, some jobs have hooks defined such that each Helm release deletes
# and recreates jobs. These jobs are ignored in this test.
# This test aims to validate no Deployment, DaemonSet, or StatefulSet pods are
# changed by verifying the Observed Generation remains the same.

# This test case is proven by:
# 1. getting the list of DaemonSets, Deployment, StatefulSets after an installation
# 2. performing a helm upgrade with --reuse-values
# 3. getting the list of DaemonSets, Deployment, StatefulSets after the upgrade
# 4. Verifying the list is empty since no applications should have changed

before_apps_list="$(mktemp)"
after_apps_list="$(mktemp)"

kubectl get daemonsets,deployments,statefulsets \
  --namespace openstack \
  --no-headers \
  --output custom-columns=Kind:.kind,Name:.metadata.name,Generation:.status.observedGeneration \
  > "$before_apps_list"

helm upgrade openstack ./openstack \
  --namespace openstack \
  --reuse-values \
  --wait

kubectl get daemonsets,deployments,statefulsets \
  --namespace openstack \
  --no-headers \
  --output custom-columns=Kind:.kind,Name:.metadata.name,Generation:.status.observedGeneration \
  > "$after_apps_list"

# get list of apps that exist in after list, but not in before list
changed_apps="$(comm -13 "$before_apps_list" "$after_apps_list")"

if [ "x$changed_apps" != "x" ]; then
  echo "Applications changed unexpectedly: $changed_apps"
  exit 1
fi
