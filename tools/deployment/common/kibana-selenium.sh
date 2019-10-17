#!/bin/bash

set -xe

export CHROMEDRIVER="${CHROMEDRIVER:="/etc/selenium/chromedriver"}"
export ARTIFACTS_DIR="${ARTIFACTS_DIR:="/tmp/artifacts/"}"

export KIBANA_USER="admin"
export KIBANA_PASSWORD="changeme"
export KIBANA_URI="kibana.osh-infra.svc.cluster.local"

export KERNEL_QUERY="discover?_g=()&_a=(columns:!(_source),index:'kernel-*',interval:auto,query:(match_all:()),sort:!('@timestamp',desc))"
export JOURNAL_QUERY="discover?_g=()&_a=(columns:!(_source),index:'journal-*',interval:auto,query:(match_all:()),sort:!('@timestamp',desc))"
export LOGSTASH_QUERY="discover?_g=()&_a=(columns:!(_source),index:'logstash-*',interval:auto,query:(match_all:()),sort:!('@timestamp',desc))"

python3 tools/gate/selenium/kibanaSelenium.py
