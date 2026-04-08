#!/bin/bash

set -xe

export CHROMEDRIVER="${CHROMEDRIVER:="/etc/selenium/chromedriver"}"
export ARTIFACTS_DIR="${ARTIFACTS_DIR:="/tmp/artifacts/"}"

export NAGIOS_USER="nagiosadmin"
export NAGIOS_PASSWORD="password"
export NAGIOS_URI="nagios.openstack-helm.org"

python3 $(readlink -f $(dirname $0))/nagiosSelenium.py
