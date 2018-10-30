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

FROM docker.io/ubuntu:xenial
MAINTAINER pete.birley@att.com

ARG UBUNTU_URL=http://archive.ubuntu.com/ubuntu/
ARG ALLOW_UNAUTHENTICATED=false
ARG PIP_INDEX_URL=https://pypi.python.org/simple/
ARG PIP_TRUSTED_HOST=pypi.python.org
ENV PIP_INDEX_URL=${PIP_INDEX_URL}
ENV PIP_TRUSTED_HOST=${PIP_TRUSTED_HOST}

COPY ./tools/images/kubeadm-aio/sources.list /etc/apt/
RUN sed -i \
        -e "s|%%UBUNTU_URL%%|${UBUNTU_URL}|g" \
        /etc/apt/sources.list ;\
    echo "APT::Get::AllowUnauthenticated \"${ALLOW_UNAUTHENTICATED}\";" > /etc/apt/apt.conf.d/allow-unathenticated

ARG GOOGLE_KUBERNETES_REPO_URL=https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64
ENV GOOGLE_KUBERNETES_REPO_URL ${GOOGLE_KUBERNETES_REPO_URL}

ARG GOOGLE_HELM_REPO_URL=https://storage.googleapis.com/kubernetes-helm
ENV GOOGLE_HELM_REPO_URL ${GOOGLE_HELM_REPO_URL}

ARG KUBE_VERSION="v1.10.9"
ENV KUBE_VERSION ${KUBE_VERSION}

ARG CNI_VERSION="v0.6.0"
ENV CNI_VERSION ${CNI_VERSION}

ARG CNI_REPO_URL=https://github.com/containernetworking/plugins/releases/download/$CNI_VERSION
ENV CNI_REPO_URL ${CNI_REPO_URL}

ARG HELM_VERSION="v2.11.0"
ENV HELM_VERSION ${HELM_VERSION}

ARG CHARTS="calico,flannel,tiller,kube-dns,kubernetes-keystone-webhook"
ENV CHARTS ${CHARTS}

ARG HTTP_PROXY=""
ENV HTTP_PROXY ${HTTP_PROXY}
ENV http_proxy ${HTTP_PROXY}

ARG HTTPS_PROXY=""
ENV HTTPS_PROXY ${HTTPS_PROXY}
ENV https_proxy ${HTTPS_PROXY}

ARG NO_PROXY="127.0.0.1,localhost,.svc.cluster.local"
ENV NO_PROXY ${NO_PROXY}
ENV no_proxy ${NO_PROXY}

ENV container="docker" \
    DEBIAN_FRONTEND="noninteractive" \
    CNI_BIN_DIR="/opt/cni/bin"

RUN set -ex ;\
    apt-get update ;\
    apt-get upgrade -y ;\
    apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        jq \
        python-pip \
        gawk ;\
    pip --no-cache-dir install --upgrade pip ;\
    hash -r ;\
    pip --no-cache-dir install --upgrade setuptools ;\
    # NOTE(srwilkers): Pinning ansible to 2.5.5, as pip installs 2.6 by default.
    # 2.6 introduces a new command flag (init) for the docker_container module
    # that is incompatible with what we have currently. 2.5.5 ensures we match
    # what's deployed in the gates
    pip --no-cache-dir install --upgrade \
      requests \
      kubernetes \
      "ansible==2.5.5" ;\
    for BINARY in kubectl kubeadm; do \
      curl -sSL -o /usr/bin/${BINARY} \
        ${GOOGLE_KUBERNETES_REPO_URL}/${BINARY} ;\
      chmod +x /usr/bin/${BINARY} ;\
    done ;\
    mkdir -p /opt/assets/usr/bin ;\
    curl -sSL -o /opt/assets/usr/bin/kubelet \
      ${GOOGLE_KUBERNETES_REPO_URL}/kubelet ;\
    chmod +x /opt/assets/usr/bin/kubelet ;\
    mkdir -p /opt/assets${CNI_BIN_DIR} ;\
    curl -sSL ${CNI_REPO_URL}/cni-plugins-amd64-$CNI_VERSION.tgz | \
      tar -zxv --strip-components=1 -C /opt/assets${CNI_BIN_DIR} ;\
    TMP_DIR=$(mktemp -d) ;\
    curl -sSL ${GOOGLE_HELM_REPO_URL}/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip-components=1 -C ${TMP_DIR} ;\
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
