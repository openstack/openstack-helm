# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /bin/bash

LIBVIRT_VERSION            ?= 1.3.1-1ubuntu10.24
DISTRO                     ?= ubuntu
DISTRO_RELEASE             ?= xenial
CEPH_RELEASE               ?= mimic

DOCKER_REGISTRY            ?= docker.io
IMAGE_NAME                 ?= libvirt
IMAGE_PREFIX               ?= openstackhelm
IMAGE_TAG                  ?= $(DISTRO)-$(DISTRO_RELEASE)-$(LIBVIRT_VERSION)
LABEL                      ?= putlabelshere

IMAGE := ${DOCKER_REGISTRY}/${IMAGE_PREFIX}/${IMAGE_NAME}:${IMAGE_TAG}

# Build libvirt Docker image for this project
.PHONY: images
images: build_$(IMAGE_NAME)

# Make targets intended for use by the primary targets above.
.PHONY: build_$(IMAGE_NAME)
build_$(IMAGE_NAME):
	docker build \
	--network=host \
	--force-rm \
	--file=./Dockerfile.${DISTRO}.xenial \
	--build-arg LIBVIRT_VERSION="${LIBVIRT_VERSION}" \
	--build-arg CEPH_RELEASE="${CEPH_RELEASE}" \
	--label $(LABEL) \
	-t $(IMAGE) \
	.
