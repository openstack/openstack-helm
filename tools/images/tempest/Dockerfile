FROM ubuntu:16.04

RUN set -ex ;\
    export DEBIAN_FRONTEND=noninteractive ;\
    apt-get update ;\
    apt-get upgrade -y ;\
    apt-get install netbase -y ;\
    apt-get install --no-install-recommends -y \
        python-dev \
        build-essential \
        python-pip \
        git ;\
    git clone https://opendev.org/openstack/tempest ;\
    git clone https://opendev.org/openstack/cinder-tempest-plugin ;\
    git clone https://opendev.org/openstack/heat-tempest-plugin ;\
    git clone https://opendev.org/openstack/keystone-tempest-plugin ;\
    git clone https://opendev.org/openstack/neutron-tempest-plugin ;\
    pip install -U setuptools ;\
    pip install wheel ;\
    pip install -e tempest/ \
                   cinder-tempest-plugin/ \
                   heat-tempest-plugin/ \
                   keystone-tempest-plugin/ \
                   neutron-tempest-plugin/ ;\
