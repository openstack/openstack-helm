# Copyright 2018 The Openstack-Helm Authors.
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

# Git args
GIT_REPO                   ?= https://github.com/stackanetes/kubernetes-entrypoint.git
GIT_REF                    ?= master
_GIT_CLONE_SUBDIR          := src
_GIT_CLONE_MOUNT_DIR       := /go/src/github.com/stackanetes/kubernetes-entrypoint

# Image args
IMAGE_REGISTRY             ?= docker.io
IMAGE_NAME                 ?= kubernetes-entrypoint
IMAGE_PREFIX               ?= openstackhelm
IMAGE_TAG                  ?= $(GIT_REF)
IMAGE_LABELS               ?=
# Overrides above image args if specified.
IMAGE                      ?= ${IMAGE_REGISTRY}/${IMAGE_PREFIX}/${IMAGE_NAME}$(if $(IMAGE_TAG),:$(IMAGE_TAG),)
IMAGE_DOCKER_BUILD_OPTS    ?=
IMAGE_BINARY_INSTALL_PATH  ?=

# Go args
GO_IMAGE                   ?= docker.io/golang:1.10
GO_BUILD_OPTS              ?=

# Binary args
_BINARY_SUBDIR             := out
_BINARY_PATH               := $(_BINARY_SUBDIR)/kubernetes-entrypoint

.PHONY: all
all: clean checkout binary image push

# Remove source code and binary
.PHONY: clean
clean:
	rm -rf $(_GIT_CLONE_SUBDIR)

# Checkout source code
.PHONY: checkout
checkout:
	git clone $(GIT_REPO) $(_GIT_CLONE_SUBDIR)
	cd $(_GIT_CLONE_SUBDIR); git checkout $(GIT_REF) .

# Build binary
.PHONY: binary
binary:
	docker run\
  	-v "$(shell pwd)/$(_GIT_CLONE_SUBDIR)":$(_GIT_CLONE_MOUNT_DIR)\
		`# Run as current user, not root, to avoid sudo usage in clean target`\
		-v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro\
		-u $(shell id -u ${USER}):$(shell id -g ${USER})\
		-w $(_GIT_CLONE_MOUNT_DIR)\
		$(GO_IMAGE)\
		go build -o "$(_BINARY_PATH)" $(GO_BUILD_OPTS)

# Internal variables
_BINARY_INSTALL_PATH_ARG   := $(if $(IMAGE_BINARY_INSTALL_PATH),--build-arg BINARY_INSTALL_PATH="${IMAGE_BINARY_INSTALL_PATH}" ,)
_IMAGE_LABELS_ARG          := $(if $(IMAGE_LABELS),--label="${IMAGE_LABELS}" ,)

# Build image
.PHONY: image
image:
	docker build\
	  --build-arg BINARY_PATH=/$(_GIT_CLONE_SUBDIR)/$(_BINARY_PATH)\
	  $(_BINARY_INSTALL_PATH_ARG)\
	  $(_IMAGE_LABELS_ARG)\
	  -t $(IMAGE)\
	  $(IMAGE_DOCKER_BUILD_OPTS)\
	  .

# Push image
.PHONY: push
push:
	docker push $(IMAGE)
