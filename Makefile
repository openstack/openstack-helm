.PHONY: ceph bootstrap mariadb keystone memcached rabbitmq common openstack all clean 

B64_DIRS := common/secrets
B64_EXCLUDE := $(wildcard common/secrets/*.b64)

CHARTS := ceph mariadb rabbitmq GLANCE memcached keystone glance openstack
COMMON_TPL := common/templates/_globals.tpl

all: common bootstrap mariadb rabbitmq memcached keystone glance openstack

common: build-common

ceph: build-ceph

bootstrap: build-bootstrap

mariadb: build-mariadb

keystone: build-keystone

rabbitmq: build-rabbitmq

glance: build-glance

memcached: build-memcached	

openstack: build-openstack
	
clean:  
	$(shell rm -rf common/secrets/*.b64)
	$(shell rm -rf */templates/_partials.tpl)
	$(shell rm -rf */templates/_globals.tpl)
	echo "Removed all .b64, _partials.tpl, and _globals.tpl files"

build-%:
	if [ -f $*/Makefile ]; then make -C $*; fi
	if [ -f $*/requirements.yaml ]; then helm dep up $*; fi
	helm lint $*
	helm package $*
