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
HELM := helm
TASK := build

PKG_ARGS =
ifdef VERSION
	PKG_ARGS += --version $(VERSION)
endif

ifdef PACKAGE_DIR
	PKG_ARGS += --destination $(PACKAGE_DIR)
endif

CHART_DIRS := $(subst /,,$(dir $(wildcard */Chart.yaml)))
CHARTS := $(sort helm-toolkit $(CHART_DIRS))

.PHONY: $(CHARTS)

all: $(CHARTS)

$(CHARTS):
	@echo
	@echo "===== Processing [$@] chart ====="
	@make $(TASK)-$@

init-%:
	if [ -f $*/Makefile ]; then make -C $*; fi
	if grep -qE "^dependencies:" $*/Chart.yaml; then $(HELM) dep up $*; fi

lint-%: init-%
	if [ -d $* ]; then $(HELM) lint $*; fi

build-%: lint-%
	if [ -d $* ]; then $(HELM) package $* $(PKG_ARGS); fi

clean:
	@echo "Removed .b64, _partials.tpl, and _globals.tpl files"
	rm -f helm-toolkit/secrets/*.b64
	rm -f */templates/_partials.tpl
	rm -f */templates/_globals.tpl
	rm -f *tgz */charts/*tgz
	rm -f */requirements.lock
	-rm -rf */charts */tmpcharts

pull-all-images:
	@./tools/pull-images.sh

pull-images:
	@./tools/pull-images.sh $(filter-out $@,$(MAKECMDGOALS))

%:
	@:
