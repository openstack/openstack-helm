.PHONY: ceph mariadb keystone memcached rabbitmq openstack-base openstack all clean base64

B64_DIRS := openstack-base/secrets
B64_EXCLUDE := $(wildcard openstack-base/secrets/*.b64)

CHARTS := ceph mariadb rabbitmq memcached keystone openstack
COMMON_TPL := openstack-base/templates/_common.tpl

all: openstack-base ceph mariadb rabbitmq memcached keystone openstack

openstack-base: build-openstack-base

ceph: build-ceph

mariadb: build-mariadb

keystone: build-keystone

rabbitmq: build-rabbitmq

memcached: build-memcached	

openstack: build-openstack
	
clean:  
	$(shell rm -rf openstack-base/secrets/*.b64)
	$(shell rm -rf */templates/_partials.tpl)
	$(shell rm -rf */templates/_common.tpl)
	echo "Removed all .b64, _partials.tpl, and _common.tpl files"

build-openstack-base:
	# rebuild all base64 values
	$(eval B64_OBJS = $(foreach dir,$(B64_DIRS),$(shell find $(dir)/* -type f $(foreach e,$(B64_EXCLUDE), -not -path "$(e)"))))
	$(foreach var,$(B64_OBJS),cat $(var) | base64 | perl -pe 'chomp if eof' > $(var).b64;)

	if [ -f openstack-base/Makefile ]; then make -C openstack-base; fi
	if [ -f openstack-base/requirements.yaml ]; then helm dep up openstack-base; fi
	helm lint openstack-base
	helm package openstack-base
	$(foreach var,$(CHARTS),$(shell cp $(COMMON_TPL) $(var)/templates))
	
build-%:
	if [ ! -f $*/templates/_common.tpl ]; then echo; seq -s= 30|tr -d '[:digit:]'; echo "You need to run 'make openstack-base' first to generate _common.tpl"; seq -s= 30|tr -d '[:digit:]'; exit 1; fi; 
	if [ -f $*/Makefile ]; then make -C $*; fi
	if [ -f $*/requirements.yaml ]; then helm dep up $*; fi
	helm lint $*
	helm package $*
