FROM ubuntu:16.04
MAINTAINER pete.birley@att.com

ARG KUBE_VERSION=v1.6.8

RUN set -x \
    && TMP_DIR=$(mktemp --directory) \
    && cd ${TMP_DIR} \
    && apt-get update \
    && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        python \
        jq \
# Install kubectl:
    && curl -sSL https://dl.k8s.io/${KUBE_VERSION}/kubernetes-client-linux-amd64.tar.gz | tar -zxv --strip-components=1 \
    && mv ${TMP_DIR}/client/bin/kubectl /usr/bin/kubectl \
    && chmod +x /usr/bin/kubectl \
    && rm -rf ${TMP_DIR}
