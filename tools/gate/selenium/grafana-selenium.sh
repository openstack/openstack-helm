#!/bin/bash

set -xe

export CHROMEDRIVER="${CHROMEDRIVER:="/etc/selenium/chromedriver"}"
export ARTIFACTS_DIR="${ARTIFACTS_DIR:="/tmp/artifacts/"}"

export GRAFANA_USER="admin"
export GRAFANA_PASSWORD="password"
export GRAFANA_URI="grafana.openstack-helm.org"

python3 $(readlink -f $(dirname $0))/grafanaSelenium.py
