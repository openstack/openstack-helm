#!/bin/bash
set -e

TEST_POSTFIX="cronjob-test-run"

CRONJOBS=$(kubectl get cj --no-headers --all-namespaces | awk '{print $1":"$2}')
for i in ${CRONJOBS}; do
  NS=$(echo "$i" | cut -f1 -d:)
  CJ=$(echo "$i" | cut -f2 -d:)

  # avoid scheduled runs to prevent case when our manual job is deleted by history limit.
  kubectl patch cj/"${CJ}" -n"${NS}"  -p '{"spec" : {"suspend" : true }}'
  kubectl create job -n"${NS}" --from=cj/"${CJ}" "${CJ}-${TEST_POSTFIX}"
done

echo "Waiting for all test jobs to complete."
for i in {1..30}; do
  RUNNING_JOBS=$(kubectl get jobs --all-namespaces | grep "${TEST_POSTFIX}.*0/1" ||:)
  [ -z "${RUNNING_JOBS}" ] && break
  sleep 10
done

if [ -n "${RUNNING_JOBS}" ]; then
  echo -e "Timed out waiting for cj jobs to complete:\n${RUNNING_JOBS}"
  exit 1
fi

echo "All test jobs completed."

NOT_FOUND_JOBS=""
echo "Checking that every cronjob has a corresponding test job"
for i in ${CRONJOBS}; do
  NS=$(echo "$i" | cut -f1 -d:)
  CJ=$(echo "$i" | cut -f2 -d:)
  if [ -z "$(kubectl get job -n ${NS} ${CJ}-${TEST_POSTFIX} | grep '1/1' ||:)" ]; then
      NOT_FOUND_JOBS="${NOT_FOUND_JOBS}\n$i"
  fi
done

if [ -n "${NOT_FOUND_JOBS}" ]; then
    echo -e "Some cronjobs don't have corresponding test jobs:${NOT_FOUND_JOBS}"
    kubectl get jobs --all-namespaces | grep ${TEST_POSTFIX}
    exit 1
fi

echo "Cronjobs run successfully:"
kubectl get jobs --all-namespaces | grep ${TEST_POSTFIX}

# Unsuspend cj on success assuming they all were not suspended on start
for i in ${CRONJOBS}; do
  NS=$(echo "$i" | cut -f1 -d:)
  CJ=$(echo "$i" | cut -f2 -d:)
  kubectl patch cj/"${CJ}" -n"${NS}"  -p '{"spec" : {"suspend" : false }}'
done
