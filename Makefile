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

HELM = helm
TASK = build

CHARTS = helm-toolkit ceph mariadb etcd rabbitmq
CHARTS += memcached keystone glance cinder horizon neutron nova heat
CHARTS += barbican mistral senlin magnum ingress

all: $(CHARTS)

$(CHARTS):
	@make $(TASK)-$@

init-%:
	@echo
	@echo "===== Initializing $*"
	if [ -f $*/Makefile ]; then make -C $*; fi
	if [ -f $*/requirements.yaml ]; then helm dep up $*; fi

lint-%: init-%
	$(HELM) lint $*

build-%: lint-%
	$(HELM) package $*

clean:
	@echo "Removed all .b64, _partials.tpl, and _globals.tpl files"
	$(shell rm -rf helm-toolkit/secrets/*.b64)
	$(shell rm -rf */templates/_partials.tpl)
	$(shell rm -rf */templates/_globals.tpl)

.PHONY: $(CHARTS)
