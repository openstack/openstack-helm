#!/bin/bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <chart_dir> <base_version>"
    echo "  <chart_dir> - The chart directory."
    echo "  <base_version> - The base version must be <major>.<minor>.<patch>"
    echo "                   For example 2026.1.0"
    echo "                   Will be modified to 2026.1.<patch>+<commit_sha>"
    echo "                   where <patch> is the number of commits which"
    echo "                   touched the chart since the tag equal to"
    echo "                   <base_version> and <commit_sha> is the last of"
    echo "                   those commits. If no such tag exists, <patch>"
    echo "                   will be taken from <base_version>."
    exit 1
fi

CHART_DIR=${1%/}
BASE_VERSION=$2
MAJOR=$(echo "$BASE_VERSION" | cut -d. -f1)
MINOR=$(echo "$BASE_VERSION" | cut -d. -f2)
PATCH=$(echo "$BASE_VERSION" | cut -d. -f3)

# The version must be a function of the chart's own history and nothing else.
# Deriving it from HEAD instead makes it depend on which commit the publishing
# job happens to run at, and the post pipeline uses Zuul's supercedent manager,
# which drops queue items when changes land faster than that job runs.
#
# helm-toolkit is vendored into every chart that depends on it, so those charts
# have to get a new version when helm-toolkit moves.
VERSION_PATHS=("$CHART_DIR")
if [[ "$CHART_DIR" != "helm-toolkit" ]] &&
    grep -Eq 'name:[[:space:]]*helm-toolkit' "${CHART_DIR}/Chart.yaml"; then
    VERSION_PATHS+=("helm-toolkit")
fi

if git show-ref --tags "$BASE_VERSION" --quiet; then
    # if there is tag $BASE_VERSION, then we count the number of commits since
    # the tag which touched the chart
    PATCH=$(git log --oneline "${BASE_VERSION}.." -- "${VERSION_PATHS[@]}" | wc -l | xargs)
fi

# --abbrev is pinned so that the version of an unchanged chart doesn't drift as
# the repository grows and git widens the default abbreviation.
COMMIT_SHA=$(git log -1 --abbrev=9 --format=%h -- "${VERSION_PATHS[@]}")
: "${COMMIT_SHA:?no commit touching ${VERSION_PATHS[*]} found}"

echo "${MAJOR}.${MINOR}.${PATCH}+${COMMIT_SHA}"
