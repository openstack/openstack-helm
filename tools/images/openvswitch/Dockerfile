FROM k8s.gcr.io/debian-iptables-amd64:v10
MAINTAINER pete.birley@att.com

ARG OVS_VERSION=2.8.1

RUN set -ex ;\
    export DEBIAN_FRONTEND=noninteractive ;\
    apt-get update ;\
    apt-get upgrade -y ;\
    apt-get install --no-install-recommends -y \
        bash ;\
    apt-get install --no-install-recommends -y \
        build-essential \
        curl \
        libatomic1 \
        libssl1.1 \
        openssl \
        uuid-runtime \
        graphviz \
        autoconf \
        automake \
        bzip2 \
        debhelper \
        dh-autoreconf \
        libssl-dev \
        libtool \
        python-all \
        python-six \
        python-twisted-conch \
        python-zopeinterface ;\
    TMP_DIR=$(mktemp -d) ;\
    curl -sSL http://openvswitch.org/releases/openvswitch-${OVS_VERSION}.tar.gz | tar xz -C ${TMP_DIR} --strip-components=1 ;\
    cd ${TMP_DIR} ;\
      ./boot.sh ;\
      ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc ;\
      make ;\
      make install ;\
      cd / ;\
    rm -rf ${TMP_DIR} ;\
    apt-get purge --auto-remove -y \
        build-essential \
        curl \
        graphviz \
        autoconf \
        automake \
        bzip2 \
        debhelper \
        dh-autoreconf \
        libssl-dev \
        libtool \
        python-all \
        python-six \
        python-twisted-conch \
        python-zopeinterface  ;\
    clean-install \
        iproute2 ;\
