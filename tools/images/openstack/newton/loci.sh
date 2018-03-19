#!/bin/bash
set -ex
OPENSTACK_VERSION="newton-eol"
IMAGE_TAG="newton"

sudo docker run -d \
  --name docker-in-docker \
  --privileged=true \
  --net=host \
  -v /var/lib/docker \
  -v ${HOME}/.docker/config.json:/root/.docker/config.json:ro\
  docker.io/docker:17.07.0-dind \
  dockerd \
    --pidfile=/var/run/docker.pid \
    --host=unix:///var/run/docker.sock \
    --storage-driver=overlay2
sudo docker exec docker-in-docker apk update
sudo docker exec docker-in-docker apk add git

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --network host \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT=requirements \
    --build-arg PROJECT_REF=stable/newton \
    --tag docker.io/openstackhelm/requirements:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/requirements:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=keystone \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="apache ldap" \
    --build-arg PIP_PACKAGES="pycrypto python-openstackclient" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/keystone:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/keystone:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=heat \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="apache" \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg DIST_PACKAGES="curl" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/heat:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/heat:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=barbican \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/barbican:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/barbican:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=glance \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="glance ceph" \
    --build-arg PIP_PACKAGES="pycrypto python-swiftclient" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/glance:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/glance:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=cinder \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="cinder lvm ceph qemu" \
    --build-arg PIP_PACKAGES="pycrypto python-swiftclient" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/cinder:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/cinder:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=neutron \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="neutron linuxbridge openvswitch" \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/neutron:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/neutron:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=neutron \
    --build-arg FROM=docker.io/ubuntu:18.04 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="neutron linuxbridge openvswitch" \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg DIST_PACKAGES="ethtool lshw" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/neutron:${IMAGE_TAG}-sriov-1804
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/neutron:${IMAGE_TAG}-sriov-1804

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=nova \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="nova ceph linuxbridge openvswitch configdrive qemu apache" \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/nova:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/nova:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=horizon \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="horizon apache" \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/horizon:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/horizon:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=senlin \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="senlin" \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/senlin:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/senlin:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=congress \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="congress" \
    --build-arg PIP_PACKAGES="pycrypto python-congressclient" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/congress:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/congress:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=magnum \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="magnum" \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/magnum:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/magnum:${IMAGE_TAG}

sudo docker exec docker-in-docker docker build --force-rm --pull --no-cache \
    https://git.openstack.org/openstack/loci.git \
    --build-arg PROJECT=ironic \
    --build-arg FROM=gcr.io/google_containers/ubuntu-slim:0.14 \
    --build-arg PROJECT_REF=${OPENSTACK_VERSION} \
    --build-arg PROFILES="ironic ipxe ipmi qemu tftp" \
    --build-arg PIP_PACKAGES="pycrypto" \
    --build-arg DIST_PACKAGES="iproute2" \
    --build-arg WHEELS=openstackhelm/requirements:${IMAGE_TAG} \
    --tag docker.io/openstackhelm/ironic:${IMAGE_TAG}
sudo docker exec docker-in-docker docker push docker.io/openstackhelm/ironic:${IMAGE_TAG}
