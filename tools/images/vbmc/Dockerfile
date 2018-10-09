FROM centos:7
MAINTAINER pete.birley@att.com

ARG PROJECT=nova
ARG UID=42424
ARG GID=42424

RUN set -ex ;\
    yum -y upgrade ;\
    yum -y install \
      epel-release \
      centos-release-openstack-newton \
      centos-release-qemu-ev ;\
    yum -y install \
      ceph-common \
      git \
      libcgroup-tools \
      libguestfs \
      libvirt \
      libvirt-daemon \
      libvirt-daemon-config-nwfilter \
      libvirt-daemon-driver-lxc \
      libvirt-daemon-driver-nwfilter \
      libvirt-devel \
      openvswitch \
      python-devel \
      qemu-kvm ;\
    yum -y group install \
      "Development Tools" ;\
    yum clean all ;\
    rm -rf /var/cache/yum ;\
    curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py ;\
    python /tmp/get-pip.py ;\
    rm -f /tmp/get-pip.py ;\
    TMP_DIR=$(mktemp -d) ;\
    git clone https://github.com/openstack/virtualbmc ${TMP_DIR} ;\
    pip install -U ${TMP_DIR} ;\
    rm -rf ${TMP_DIR} ;\
    groupadd -g ${GID} ${PROJECT} ;\
    useradd -u ${UID} -g ${PROJECT} -M -d /var/lib/${PROJECT} -s /usr/sbin/nologin -c "${PROJECT} user" ${PROJECT} ;\
    mkdir -p /etc/${PROJECT} /var/log/${PROJECT} /var/lib/${PROJECT} /var/cache/${PROJECT} ;\
    chown ${PROJECT}:${PROJECT} /etc/${PROJECT} /var/log/${PROJECT} /var/lib/${PROJECT} /var/cache/${PROJECT} ;\
    usermod -a -G qemu ${PROJECT}
