#!/bin/bash

set -xe

export CHROMEDRIVER="${CHROMEDRIVER:="/etc/selenium/chromedriver"}"
export ARTIFACTS_DIR="${ARTIFACTS_DIR:="/tmp/artifacts/"}"

export PROMETHEUS_USER="admin"
export PROMETHEUS_PASSWORD="changeme"
export PROMETHEUS_URI="prometheus.osh-infra.svc.cluster.local"

python3 tools/gate/selenium/prometheusSelenium.py
