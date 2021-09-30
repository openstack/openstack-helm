#!/bin/bash
set -x

APPLICATION=$1
RELEASE_GROUP=${2:-${APPLICATION}}
NAMESPACE=${3:-openstack}
: ${HELM_TESTS_TRIES:=2}
timeout=${OSH_TEST_TIMEOUT:-900}

run_tests() {
  # Delete the test pod if it still exists
  kubectl delete pods -l application=${APPLICATION},release_group=${RELEASE_GROUP},component=test --namespace=${NAMESPACE} --ignore-not-found
  helm test ${APPLICATION} --timeout ${timeout}s --namespace=${NAMESPACE}
}

for i in $(seq 1 ${HELM_TESTS_TRIES}); do
  echo "Run helm tests for ${APPLICATION}. Try #${i}"
  run_tests
  RC=$?
  [ ${RC} -eq "0" ] && break
done
exit ${RC}
