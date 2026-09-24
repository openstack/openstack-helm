#!/bin/bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
    {
        echo "Usage: $0 <base_version> [index_file]"
        echo "  <base_version> - The base version passed to chart_version.sh."
        echo "  <index_file> - An existing Helm repo index. Charts whose version is"
        echo "                 already in it are left out of the plan. When omitted"
        echo "                 every chart is planned."
        echo
        echo "Prints one '<chart> <version>' line per chart which still needs to be"
        echo "built and published."
    } >&2
    exit 1
fi

BASE_VERSION=$1
INDEX_FILE=${2:-}

# Change directory before checking the index so that a relative index path is
# resolved against the same directory it is later read from.
cd "$(dirname "$0")/.."

# grep inside an if is exempt from set -e, so an unreadable index would quietly
# report every chart as unpublished and trigger a full republish.
if [[ -n "$INDEX_FILE" && ! -r "$INDEX_FILE" ]]; then
    echo "Index ${INDEX_FILE} is not readable" >&2
    exit 1
fi

for chart_file in */Chart.yaml; do
    chart=$(dirname "$chart_file")
    version=$(tools/chart_version.sh "$chart" "$BASE_VERSION")

    # Compare on <major>.<minor>.<patch> and ignore the +<commit_sha> build
    # metadata. The patch component already identifies the chart's content, and
    # semver gives no precedence to build metadata, so publishing a second
    # package which differs only there would leave the repo with two entries
    # helm considers to be the same version.
    if [[ -n "$INDEX_FILE" ]] &&
        grep -qF "/${chart}-${version%%+*}+" "$INDEX_FILE"; then
        continue
    fi

    echo "${chart} ${version}"
done
