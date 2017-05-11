FROM ubuntu:16.04
MAINTAINER pete.birley@att.com

ARG HELM_VERSION=v2.3.0

ENV container="docker" \
    DEBIAN_FRONTEND="noninteractive"

RUN set -x \
    && cd /tmp \
    && apt-get update \
    && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
# Add Kubernetes repo
    && curl -sSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y \
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
# Install kubelet binary
    && curl -sSL https://dl.k8s.io/v1.6.2/kubernetes-server-linux-amd64.tar.gz | tar -zxv --strip-components=1 \
    && mv /tmp/server/bin/kubelet /usr/bin/kubelet \
    && chmod +x /usr/bin/kubelet \
# Move kubelet binary as we will run containerised
    && mv /usr/bin/kubelet /usr/bin/kubelet-real \
# Install helm binary
    && curl -sSL https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip-components=1 \
    && mv /tmp/helm /usr/bin/helm \
# Install openstack-helm dev utils
    && apt-get install -y \
        make \
        git \
        vim \
# Install nfs utils for development PVC provisioner
        nfs-common \
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
    && rm -rf /tmp/*

# Load assets into place, setup startup target & units
COPY ./assets/ /
RUN set -x \
    && ln -s /usr/lib/systemd/system/container-up.target /etc/systemd/system/default.target \
    && mkdir -p /etc/systemd/system/container-up.target.wants \
    && ln -s /usr/lib/systemd/system/kubeadm-aio.service /etc/systemd/system/container-up.target.wants/kubeadm-aio.service

VOLUME /sys/fs/cgroup

CMD /kubeadm-aio
