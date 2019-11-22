#!/bin/bash

set -xe

export CHROMEDRIVER="${CHROMEDRIVER:="/etc/selenium/chromedriver"}"
export ARTIFACTS_DIR="${ARTIFACTS_DIR:="/tmp/artifacts/"}"

export PROMETHEUS_USER="admin"
export PROMETHEUS_PASSWORD="changeme"

export PROMETHEUS_URI="prometheus-one.osh-infra.svc.cluster.local"
python3 tools/gate/selenium/prometheusSelenium.py
mv ${ARTIFACTS_DIR}/Prometheus_Command_Line_Flags.png ${ARTIFACTS_DIR}/Prometheus_One_Command_Line_Flags.png
mv ${ARTIFACTS_DIR}Prometheus_Dashboard.png ${ARTIFACTS_DIR}/Prometheus_One_Dashboard.png
mv ${ARTIFACTS_DIR}/Prometheus_Runtime_Info.png ${ARTIFACTS_DIR}/Prometheus_One_Runtime_Info.png

export PROMETHEUS_URI="prometheus-two.osh-infra.svc.cluster.local"
python3 tools/gate/selenium/prometheusSelenium.py
mv ${ARTIFACTS_DIR}/Prometheus_Command_Line_Flags.png ${ARTIFACTS_DIR}/Prometheus_Two_Command_Line_Flags.png
mv ${ARTIFACTS_DIR}/Prometheus_Dashboard.png ${ARTIFACTS_DIR}/Prometheus_Two_Dashboard.png
mv ${ARTIFACTS_DIR}/Prometheus_Runtime_Info.png ${ARTIFACTS_DIR}/Prometheus_Two_Runtime_Info.png

export PROMETHEUS_URI="prometheus-three.osh-infra.svc.cluster.local"
python3 tools/gate/selenium/prometheusSelenium.py
mv ${ARTIFACTS_DIR}/Prometheus_Command_Line_Flags.png ${ARTIFACTS_DIR}/Prometheus_Three_Command_Line_Flags.png
mv ${ARTIFACTS_DIR}/Prometheus_Dashboard.png ${ARTIFACTS_DIR}/Prometheus_Three_Dashboard.png
mv ${ARTIFACTS_DIR}/Prometheus_Runtime_Info.png ${ARTIFACTS_DIR}/Prometheus_Three_Runtime_Info.png

export PROMETHEUS_URI="prometheus-federate.osh-infra.svc.cluster.local"
python3 tools/gate/selenium/prometheusSelenium.py
mv ${ARTIFACTS_DIR}/Prometheus_Command_Line_Flags.png ${ARTIFACTS_DIR}/Prometheus_Federated_Command_Line_Flags.png
mv ${ARTIFACTS_DIR}/Prometheus_Dashboard.png ${ARTIFACTS_DIR}/Prometheus_Federated_Dashboard.png
mv ${ARTIFACTS_DIR}/Prometheus_Runtime_Info.png ${ARTIFACTS_DIR}/Prometheus_Federated_Runtime_Info.png
