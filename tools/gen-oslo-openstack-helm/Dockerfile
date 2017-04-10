FROM debian:jessie-slim
MAINTAINER Pete Birley <pete.birley@att.com>

ENV PROJECT="keystone" \
    PROJECT_BRANCH="stable/newton" \
    PROJECT_REPO="https://git.openstack.org/openstack/keystone.git"

RUN set -x \
    && apt-get update \
    && apt-get install -y \
        build-essential \
        curl \
        git \
        libffi-dev \
        libldap2-dev \
        libpq-dev \
        libsasl2-dev \
        libssl-dev \
        python \
        python-dev \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python get-pip.py \
    && rm get-pip.py \
    && pip install \
        oslo.config \
        tox \
        crudini

COPY generate.py /opt/gen-oslo-openstack-helm/generate.py
COPY entrypoint.sh /entrypoint.sh
COPY oslo-config-generator /opt/gen-oslo-openstack-helm/oslo-config-generator

ENTRYPOINT ["/entrypoint.sh"]
