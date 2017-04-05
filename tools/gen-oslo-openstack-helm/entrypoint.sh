#!/bin/bash
set -xe

git clone --depth 1 --branch ${PROJECT_BRANCH} ${PROJECT_REPO} /tmp/${PROJECT}
cd /tmp/${PROJECT}
tox -egenconfig

source .tox/genconfig/bin/activate

python /opt/gen-oslo-openstack-helm/generate.py \
  --config-file config-generator/${PROJECT}.conf \
  --helm_chart ${PROJECT} \
  --helm_namespace ${PROJECT}
