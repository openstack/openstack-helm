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

# Git args
GIT_REPO                   ?= https://github.com/stackanetes/kubernetes-entrypoint.git
GIT_REF                    ?= master
GIT_CLONE_DIR               = src

# Image args
IMAGE_REGISTRY             ?= docker.io
IMAGE_NAME                 ?= kubernetes-entrypoint
IMAGE_PREFIX               ?= openstackhelm
IMAGE_TAG                  ?= $(GIT_REF)
IMAGE_LABELS               ?=
# Overrides above image args if specified.
IMAGE                      ?= ${IMAGE_REGISTRY}/${IMAGE_PREFIX}/${IMAGE_NAME}$(if $(IMAGE_TAG),:$(IMAGE_TAG),)

# Build args
BINARY_INSTALL_PATH        ?=

# Extra args to pass to Docker build
DOCKER_BUILD_OPTS          ?=

.PHONY: all
all: clean checkout binary image push

# Remove source code
.PHONY: clean
clean:
	rm -rf $(GIT_CLONE_DIR)

# Checkout source code
.PHONY: checkout
checkout:
	git clone $(GIT_REPO) $(GIT_CLONE_DIR)
	cd $(GIT_CLONE_DIR); git checkout $(GIT_REF) .

# Build binary
.PHONY: binary
binary:
	cd $(GIT_CLONE_DIR); go build

# Internal variables
_BINARY_PATH               := $(GIT_CLONE_DIR)/kubernetes-entrypoint
_BINARY_INSTALL_PATH_ARG   := $(if $(BINARY_INSTALL_PATH),--build-arg BINARY_INSTALL_PATH="${BINARY_INSTALL_PATH}" ,)
_IMAGE_LABELS_ARG          := $(if $(IMAGE_LABELS),--label="${IMAGE_LABELS}" ,)

# Build image
.PHONY: image
image:
	docker build\
	  --build-arg BINARY_PATH=$(_BINARY_PATH)\
	  $(_BINARY_INSTALL_PATH_ARG)\
	  $(_IMAGE_LABELS_ARG)\
	  -t $(IMAGE)\
	  $(DOCKER_BUILD_OPTS)\
	  .

# Push image
.PHONY: push
push:
	docker push $(IMAGE)
