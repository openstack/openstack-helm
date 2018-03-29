FROM docker.io/ubuntu:xenial
MAINTAINER pete.birley@att.com

ARG KUBE_VERSION=v1.9.6
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
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        python \
        jq ;\
    curl -sSL https://dl.k8s.io/${KUBE_VERSION}/kubernetes-client-linux-amd64.tar.gz | tar -zxv --strip-components=1 ;\
    mv ${TMP_DIR}/client/bin/kubectl /usr/bin/kubectl ;\
    chmod +x /usr/bin/kubectl ;\
    rm -rf ${TMP_DIR}
