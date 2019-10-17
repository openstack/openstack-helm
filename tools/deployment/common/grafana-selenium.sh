#!/bin/bash

set -xe

export CHROMEDRIVER="${CHROMEDRIVER:="/etc/selenium/chromedriver"}"
export ARTIFACTS_DIR="${ARTIFACTS_DIR:="/tmp/artifacts/"}"

export GRAFANA_USER="admin"
export GRAFANA_PASSWORD="password"
export GRAFANA_URI="grafana.osh-infra.svc.cluster.local"

python3 tools/gate/selenium/grafanaSelenium.py
