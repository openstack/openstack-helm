#!/bin/bash

export KIBANA_USER="admin"
export KIBANA_PASSWORD="changeme"
export KIBANA_LOGSTASH_URI="kibana.osh-infra.svc.cluster.local/app/kibana#/discover?_g=()&_a=(columns:!(_source),index:'logstash-*',interval:auto,query:(match_all:()),sort:!('@timestamp',desc))"
export KIBANA_KERNEL_URI="kibana.osh-infra.svc.cluster.local/app/kibana#/discover?_g=()&_a=(columns:!(_source),index:'kernel-*',interval:auto,query:(match_all:()),sort:!('@timestamp',desc))"
export KIBANA_JOURNAL_URI="kibana.osh-infra.svc.cluster.local/app/kibana#/discover?_g=()&_a=(columns:!(_source),index:'journal-*',interval:auto,query:(match_all:()),sort:!('@timestamp',desc))"
python tools/gate/selenium/kibanaSelenium.py
