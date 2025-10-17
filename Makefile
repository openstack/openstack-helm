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
PYTHON := python3
TASK  := build
HELM_DOCS := tools/helm-docs
UNAME_OS := $(shell uname -s)
UNAME_ARCH := $(shell uname -m)
# We generate CHANGELOG.md files by default which
# requires reno>=4.1.0 installed.
# To skip generating it use the following:
# make all SKIP_CHANGELOG=1
SKIP_CHANGELOG ?= 0

PKG_ARGS =
ifdef VERSION
	PKG_ARGS += --version $(VERSION)
endif

ifdef PACKAGE_DIR
	PKG_ARGS += --destination $(PACKAGE_DIR)
endif

BASE_VERSION ?= 2025.2.0

CHART_DIRS := $(subst /,,$(dir $(wildcard */Chart.yaml)))
CHARTS := $(sort helm-toolkit $(CHART_DIRS))

.PHONY: $(CHARTS)

all: $(CHARTS)

charts:
	@echo $(CHART_DIRS)

$(CHARTS):
	@if [ -d $@ ]; then \
		echo; \
		echo "===== Processing [$@] chart ====="; \
		make $(TASK)-$@; \
	fi

HELM_DOCS_VERSION ?= 1.14.2
.PHONY: helm-docs ## Download helm-docs locally if necessary
helm-docs: $(HELM_DOCS)
$(HELM_DOCS):
	{ \
		curl -fsSL -o tools/helm-docs.tar.gz https://github.com/norwoodj/helm-docs/releases/download/v$(HELM_DOCS_VERSION)/helm-docs_$(HELM_DOCS_VERSION)_$(UNAME_OS)_$(UNAME_ARCH).tar.gz && \
		tar -zxf tools/helm-docs.tar.gz -C tools helm-docs && \
		rm -f tools/helm-docs.tar.gz && \
		chmod +x tools/helm-docs; \
	}

init-%:
	if [ -f $*/Makefile ]; then make -C $*; fi
	if grep -qE "^dependencies:" $*/Chart.yaml; then $(HELM) dep up $*; fi

lint-%: init-%
	if [ -d $* ]; then $(HELM) lint $*; fi

# reno required for changelog generation
%/CHANGELOG.md:
	if [ -d $* ]; then $(PYTHON) tools/changelog.py --charts $*; fi

build-%: lint-% $(if $(filter-out 1,$(SKIP_CHANGELOG)),%/CHANGELOG.md)
	if [ -d $* ]; then \
		$(HELM) package $* --version $$(tools/chart_version.sh $* $(BASE_VERSION)) $(PKG_ARGS); \
	fi

# This is used exclusively with helm3 building in the gate to publish
package-%: init-%
	if [ -d $* ]; then $(HELM) package $* $(PKG_ARGS); fi

clean:
	@echo "Clean all build artifacts"
	rm -f */templates/_partials.tpl */templates/_globals.tpl
	rm -f *tgz */charts/*tgz */requirements.lock
	rm -rf */charts */tmpcharts

pull-all-images:
	@./tools/deployment/common/pull-images.sh

pull-images:
	@./tools/deployment/common/pull-images.sh $(filter-out $@,$(MAKECMDGOALS))

dev-deploy:
	@./tools/gate/devel/start.sh $(filter-out $@,$(MAKECMDGOALS))

%:
	@:
