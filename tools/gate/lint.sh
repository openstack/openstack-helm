#!/bin/bash

set -e

HELM_DATA_YAML=../openstack-helm-infra/roles/build-helm-packages/defaults/main.yml
HELM_VERSION=$(yq -r '.version.helm' ${HELM_DATA_YAML})
HELM_REPO_URL=$(yq -r '.url.helm_repo' ${HELM_DATA_YAML})
LINT_DIR=.yamllint

rm -rf */charts/helm-toolkit
mkdir ${LINT_DIR}
cp -r * ${LINT_DIR}
rm -rf ${LINT_DIR}/*/templates
wget -qO ${LINT_DIR}/helm.tgz ${HELM_REPO_URL}/helm-${HELM_VERSION}-linux-amd64.tar.gz
tar xzf ${LINT_DIR}/helm.tgz -C ${LINT_DIR} --strip-components=1 linux-amd64/helm

for i in */; do
    # avoid helm-toolkit to symlink on itself
    [ -d "$i/templates" -a "$i" != "helm-toolkit/" ] || continue
    mkdir -p $i/charts
    ln -s ../../../openstack-helm-infra/helm-toolkit $i/charts/helm-toolkit
    ${LINT_DIR}/helm template $i --output-dir ${LINT_DIR} 2>&1 > /dev/null
done
rm -rf */charts/helm-toolkit

find .yamllint -type f -exec sed -i 's/%%%.*/XXX/g' {} +

set +e
shopt -s globstar extglob
# lint all y*mls except for templates with the first config
yamllint -c yamllint.conf ${LINT_DIR}/*{,/!(templates)/**}/*.y*ml yamllint*.conf
result=$?
# lint templates with the second config
yamllint -c yamllint-templates.conf ${LINT_DIR}/*/templates/*.yaml
exit $(($?|$result))
