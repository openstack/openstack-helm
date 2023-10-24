#!/bin/bash
set -ex
set -o pipefail

# This test case aims to prove that updating a subhcart's configuration for
# the OpenStack Umbrella Helm chart results in no other subcharts' components
# being updated.

# This test case is proven by:
# 1. getting the list of DaemonSets, Deployment, StatefulSets after an installation
# 2. performing a helm upgrade with modifying a config specific to one subchart
# 3. getting the list of DaemonSets, Deployment, StatefulSets after the upgrade
# 4. Verifying the expected subchart application changes
# 5. Verifying no other applications are changed

validate_only_expected_application_changes () {
  local app_name="$1"
  local config_change="$2"

  before_apps_list="$(mktemp)"
  after_apps_list="$(mktemp)"

  kubectl get daemonsets,deployments,statefulsets \
    --namespace openstack \
    --no-headers \
    --output custom-columns=Kind:.kind,Name:.metadata.name,Generation:.status.observedGeneration \
    > "$before_apps_list"

  kubectl delete jobs \
    --namespace openstack \
    -l "application=$app_name" \
    --wait

  helm upgrade openstack ./openstack \
    --namespace openstack \
    --reuse-values \
    ${config_change} \
    --wait

  ./tools/deployment/common/wait-for-pods.sh openstack

  kubectl get daemonsets,deployments,statefulsets \
    --namespace openstack \
    --no-headers \
    --output custom-columns=Kind:.kind,Name:.metadata.name,Generation:.status.observedGeneration \
    > "$after_apps_list"

  # get list of apps that exist in after list, but not in before list
  changed_apps="$(comm -13 "$before_apps_list" "$after_apps_list")"

  if ! echo "$changed_apps" | grep "$app_name" ; then
    echo "Expected $app_name application to update"
    exit 1
  fi

  # use awk to find applications not matching app_name and pretty format as Kind/Name
  unexpected_changed_apps="$(echo "$changed_apps" | awk -v appname="$app_name" '$0 !~ appname { print $1 "/" $2 }')"
  if [ "x$unexpected_changed_apps" != "x" ]; then
    echo "Applications changed unexpectedly: $unexpected_changed_apps"
    exit 1
  fi
}

validate_only_expected_application_changes "glance" "--set glance.conf.logging.logger_glance.level=WARN"
validate_only_expected_application_changes "heat" "--set heat.conf.logging.logger_heat.level=WARN"
validate_only_expected_application_changes "keystone" "--set keystone.conf.logging.logger_keystone.level=WARN"
validate_only_expected_application_changes "libvirt" "--set libvirt.conf.libvirt.log_level=2"
validate_only_expected_application_changes "mariadb" "--set mariadb.conf.database.config_override=[mysqld]\nlog_warnings=3"
validate_only_expected_application_changes "memcached" "--set memcached.conf.memcached.stats_cachedump.enabled=false"
validate_only_expected_application_changes "neutron" "--set neutron.conf.logging.logger_neutron.level=WARN"
validate_only_expected_application_changes "nova" "--set nova.conf.logging.logger_nova.level=WARN"
validate_only_expected_application_changes "openvswitch" "--set openvswitch.pod.user.nova.uid=42425"
validate_only_expected_application_changes "placement" "--set placement.conf.logging.logger_placement.level=WARN"
validate_only_expected_application_changes "rabbitmq" "--set rabbitmq.conf.rabbitmq.log.file.level=info"
