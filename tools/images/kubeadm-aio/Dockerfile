# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#https://github.com/kubernetes/ingress-nginx/tree/master/images/ubuntu-slim
FROM gcr.io/google_containers/ubuntu-slim:0.14
MAINTAINER pete.birley@att.com

ENV KUBE_VERSION="v1.8.1" \
    CNI_VERSION="v0.6.0" \
    HELM_VERSION="v2.7.0" \
    container="docker" \
    DEBIAN_FRONTEND="noninteractive" \
    CNI_BIN_DIR="/opt/cni/bin" \
    CHARTS="calico,flannel,tiller,kube-dns"

RUN set -ex ;\
    apt-get update ;\
    apt-get upgrade -y ;\
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        python-pip \
        gawk ;\
    pip --no-cache-dir install --upgrade pip ;\
    pip --no-cache-dir install setuptools ;\
    pip --no-cache-dir install kubernetes ;\
    pip --no-cache-dir install ansible ;\
    for BINARY in kubectl kubeadm; do \
      curl -sSL -o /usr/bin/${BINARY} \
        https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/${BINARY} ;\
      chmod +x /usr/bin/${BINARY} ;\
    done ;\
    mkdir -p /opt/assets/usr/bin ;\
    curl -sSL -o /opt/assets/usr/bin/kubelet \
      https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubelet ;\
    chmod +x /opt/assets/usr/bin/kubelet ;\
    mkdir -p /opt/assets${CNI_BIN_DIR} ;\
    curl -sSL https://github.com/containernetworking/plugins/releases/download/$CNI_VERSION/cni-plugins-amd64-$CNI_VERSION.tgz | \
      tar -zxv --strip-components=1 -C /opt/assets${CNI_BIN_DIR} ;\
    TMP_DIR=$(mktemp -d) ;\
    curl -sSL https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip-components=1 -C ${TMP_DIR} ;\
    mv ${TMP_DIR}/helm /usr/bin/helm ;\
    rm -rf ${TMP_DIR} ;\
    apt-get purge -y --auto-remove \
        curl ;\
    rm -rf /var/lib/apt/lists/* /tmp/* /root/.cache

COPY ./ /tmp/source
RUN set -ex ;\
    cp -rfav /tmp/source/tools/images/kubeadm-aio/assets/* / ;\
    IFS=','; for CHART in $CHARTS; do \
      mv -v /tmp/source/${CHART} /opt/charts/; \
    done ;\
    rm -rf /tmp/source

ENTRYPOINT ["/entrypoint.sh"]
