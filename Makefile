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

.PHONY: ceph bootstrap mariadb etcd keystone memcached rabbitmq helm-toolkit neutron nova cinder heat all clean

B64_DIRS := helm-toolkit/secrets
B64_EXCLUDE := $(wildcard helm-toolkit/secrets/*.b64)

CHARTS := ceph mariadb etcd rabbitmq memcached keystone glance horizon neutron nova cinder heat
TOOLKIT_TPL := helm-toolkit/templates/_globals.tpl

all: helm-toolkit ceph bootstrap mariadb etcd rabbitmq memcached keystone glance horizon neutron nova cinder heat

helm-toolkit: build-helm-toolkit

#ceph: nolint-build-ceph
ceph: build-ceph

bootstrap: build-bootstrap

mariadb: build-mariadb

etcd: build-etcd

keystone: build-keystone

cinder: build-cinder

horizon: build-horizon

rabbitmq: build-rabbitmq

glance: build-glance

neutron: build-neutron

nova: build-nova

heat: build-heat

memcached: build-memcached

clean:
	$(shell rm -rf helm-toolkit/secrets/*.b64)
	$(shell rm -rf */templates/_partials.tpl)
	$(shell rm -rf */templates/_globals.tpl)
	echo "Removed all .b64, _partials.tpl, and _globals.tpl files"

build-%:
	if [ -f $*/Makefile ]; then make -C $*; fi
	if [ -f $*/requirements.yaml ]; then helm dep up $*; fi
	helm lint $*
	helm package $*
