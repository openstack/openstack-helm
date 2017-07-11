FROM ubuntu:16.04
MAINTAINER pete.birley@att.com

ENV HELM_VERSION=v2.5.0 \
    KUBE_VERSION=v1.6.7 \
    CNI_VERSION=v0.5.2 \
    container="docker" \
    DEBIAN_FRONTEND="noninteractive"

RUN set -x \
    && TMP_DIR=$(mktemp --directory) \
    && cd ${TMP_DIR} \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        dbus \
# Add Kubernetes repo
    && curl -sSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        docker.io \
        iptables \
        kubectl \
        kubelet \
        kubernetes-cni \
# Install Kubeadm without running postinstall script as it expects systemd to be running.
    && apt-get download kubeadm \
    && dpkg --unpack kubeadm*.deb \
    && mv /var/lib/dpkg/info/kubeadm.postinst /opt/kubeadm.postinst \
    && dpkg --configure kubeadm \
    && apt-get install -yf kubeadm \
    && mkdir -p /etc/kubernetes/manifests \
# Install kubectl:
    && curl -sSL https://dl.k8s.io/${KUBE_VERSION}/kubernetes-client-linux-amd64.tar.gz | tar -zxv --strip-components=1 \
    && mv ${TMP_DIR}/client/bin/kubectl /usr/bin/kubectl \
    && chmod +x /usr/bin/kubectl \
# Install kubelet & kubeadm binaries:
# (portdirect) We do things in this weird way to let us use the deps and systemd
# units from the packages in the .deb repo.
    && curl -sSL https://dl.k8s.io/${KUBE_VERSION}/kubernetes-server-linux-amd64.tar.gz | tar -zxv --strip-components=1 \
    && mv ${TMP_DIR}/server/bin/kubelet /usr/bin/kubelet \
    && chmod +x /usr/bin/kubelet \
    && mv ${TMP_DIR}/server/bin/kubeadm /usr/bin/kubeadm \
    && chmod +x /usr/bin/kubeadm \
# Install CNI:
    && CNI_BIN_DIR=/opt/cni/bin \
    && mkdir -p ${CNI_BIN_DIR} \
    && cd ${CNI_BIN_DIR} \
    && curl -sSL https://github.com/containernetworking/cni/releases/download/$CNI_VERSION/cni-amd64-$CNI_VERSION.tgz | tar -zxv --strip-components=1 \
    && cd ${TMP_DIR} \
# Move kubelet binary as we will run containerised
    && mv /usr/bin/kubelet /usr/bin/kubelet-real \
# Install helm binary
    && curl -sSL https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip-components=1 \
    && mv ${TMP_DIR}/helm /usr/bin/helm \
# Install openstack-helm dev utils
    && apt-get install -y --no-install-recommends \
        make \
        git \
        vim \
        jq \
# Install utils for PVC provisioners
        nfs-common \
        ceph-common \
        kmod \
# Tweak Systemd units and targets for running in a container
    && find /lib/systemd/system/sysinit.target.wants/ ! -name 'systemd-tmpfiles-setup.service' -type l -exec rm -fv {} + \
    && rm -fv \
        /lib/systemd/system/multi-user.target.wants/* \
        /etc/systemd/system/*.wants/* \
        /lib/systemd/system/local-fs.target.wants/* \
        /lib/systemd/system/sockets.target.wants/*udev* \
        /lib/systemd/system/sockets.target.wants/*initctl* \
        /lib/systemd/system/basic.target.wants/* \
# Clean up apt cache
    && rm -rf /var/lib/apt/lists/* \
# Clean up tmp dir
    && cd / \
    && rm -rf ${TMP_DIR}

# Load assets into place, setup startup target & units
COPY ./assets/ /
RUN set -x \
    && ln -s /usr/lib/systemd/system/container-up.target /etc/systemd/system/default.target \
    && mkdir -p /etc/systemd/system/container-up.target.wants \
    && ln -s /usr/lib/systemd/system/kubeadm-aio.service /etc/systemd/system/container-up.target.wants/kubeadm-aio.service

VOLUME /sys/fs/cgroup

CMD /kubeadm-aio
