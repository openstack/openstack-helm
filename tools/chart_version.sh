#!/bin/bash

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <chart_dir> <base_version>"
    echo "  <chart_dir> - The chart directory."
    echo "  <base_version> - The base version. For example 2024.2.0."
    echo "                   Will be modified to 2024.2.<patch>+<commit_sha>"
    exit 1
fi

CHART_DIR=$1
BASE_VERSION=$2
MAJOR=$(echo $BASE_VERSION | cut -d. -f1);
MINOR=$(echo $BASE_VERSION | cut -d. -f2);

if git show-ref --tags $BASE_VERSION --quiet; then
    PATCH=$(git log --oneline ${BASE_VERSION}.. $CHART_DIR | wc -l)
else
    PATCH=$(git log --oneline $CHART_DIR | wc -l)
fi
OSH_COMMIT_SHA=$(git rev-parse --short HEAD);
OSH_INFRA_COMMIT_SHA=$(cd ../openstack-helm-infra; git rev-parse --short HEAD);

echo "${MAJOR}.${MINOR}.${PATCH}+${OSH_COMMIT_SHA}-${OSH_INFRA_COMMIT_SHA}"
