FROM docker.io/mariadb@sha256:d4cf9fbdf33a2940ca35c653bf2b702cbaed0bff87ade8c3e3ee9eab81b38b27
#FROM docker.io/mariadb:10.2.18

RUN set -ex ;\
    apt-get update ;\
    apt-get upgrade -y ;\
    apt-get install -y --no-install-recommends \
        python-pip ;\
    pip --no-cache-dir install --upgrade pip ;\
    hash -r ;\
    pip --no-cache-dir install --upgrade setuptools ;\
    pip --no-cache-dir install --upgrade \
      configparser \
      iso8601 \
      kubernetes ;\
    apt-get clean -y ;\
    rm -rf \
       /var/cache/debconf/* \
       /var/lib/apt/lists/* \
       /var/log/* \
       /tmp/* \
       /var/tmp/*
