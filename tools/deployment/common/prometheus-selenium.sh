#!/bin/bash

export PROMETHEUS_USER="admin"
export PROMETHEUS_PASSWORD="changeme"
export PROMETHEUS_URI="prometheus.osh-infra.svc.cluster.local"
python tools/gate/selenium/prometheusSelenium.py
