FROM centos:7
MAINTAINER pete.birley@att.com

RUN set -ex ;\
    yum -y upgrade ;\
    yum -y install \
      epel-release \
      centos-release-openstack-newton \
      centos-release-qemu-ev ;\
    yum -y install \
      ceph-common \
      git \
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
    useradd --user-group --create-home --home-dir /var/lib/nova nova ;\
    chmod 755 /var/lib/nova ;\
    usermod -a -G qemu nova
