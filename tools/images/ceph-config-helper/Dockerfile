FROM docker.io/ubuntu:xenial
MAINTAINER pete.birley@att.com

ARG KUBE_VERSION=v1.10.3
ARG CEPH_RELEASE=luminous

ADD https://download.ceph.com/keys/release.asc /etc/apt/ceph-release.asc
RUN set -ex ;\
    export DEBIAN_FRONTEND=noninteractive ;\
    apt-key add /etc/apt/ceph-release.asc ;\
    rm -f /etc/apt/ceph-release.asc ;\
    echo deb http://download.ceph.com/debian-${CEPH_RELEASE}/ xenial main | tee /etc/apt/sources.list.d/ceph.list ;\
    TMP_DIR=$(mktemp --directory) ;\
    cd ${TMP_DIR} ;\
    apt-get update ;\
    apt-get dist-upgrade -y ;\
    apt-get install --no-install-recommends -y \
        apt-transport-https \
        ca-certificates \
        ceph \
        curl \
        gcc \
        python \
        python-dev \
        jq ;\
    curl -sSL https://bootstrap.pypa.io/get-pip.py | python ;\
    pip --no-cache-dir install --upgrade \
      crush \
      rgwadmin \
      six \
      python-openstackclient \
      python-swiftclient ;\
    curl -sSL https://dl.k8s.io/${KUBE_VERSION}/kubernetes-client-linux-amd64.tar.gz | tar -zxv --strip-components=1 ;\
    mv ${TMP_DIR}/client/bin/kubectl /usr/bin/kubectl ;\
    chmod +x /usr/bin/kubectl ;\
    rm -rf ${TMP_DIR} ;\
    apt-get purge -y --auto-remove \
        python-dev \
        gcc ;\
    rm -rf /var/lib/apt/lists/*
