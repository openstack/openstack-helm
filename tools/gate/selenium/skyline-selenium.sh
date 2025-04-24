#!/bin/bash

set -xe

export CHROMEDRIVER="${CHROMEDRIVER:="/etc/selenium/chromedriver"}"
export ARTIFACTS_DIR="${ARTIFACTS_DIR:="/tmp/artifacts/"}"

export SKYLINE_USER="admin"
export SKYLINE_PASSWORD="password"
export SKYLINE_URI="skyline.openstack.svc.cluster.local"

python3 $(readlink -f $(dirname $0))/skylineSelenium.py
