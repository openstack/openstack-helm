#!/bin/bash

set -xe

export CHROMEDRIVER="${CHROMEDRIVER:="/etc/selenium/chromedriver"}"
export ARTIFACTS_DIR="${ARTIFACTS_DIR:="/tmp/artifacts/"}"

export NAGIOS_USER="nagiosadmin"
export NAGIOS_PASSWORD="password"
export NAGIOS_URI="nagios.osh-infra.svc.cluster.local"

python3 tools/gate/selenium/nagiosSelenium.py
