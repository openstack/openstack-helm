.PHONY: ceph bootstrap mariadb etcd postgresql keystone memcached rabbitmq helm-toolkit openstack neutron nova cinder heat maas all clean

B64_DIRS := helm-toolkit/secrets
B64_EXCLUDE := $(wildcard helm-toolkit/secrets/*.b64)

CHARTS := ceph mariadb etcd postgresql rabbitmq memcached keystone glance horizon neutron nova cinder heat maas openstack
TOOLKIT_TPL := helm-toolkit/templates/_globals.tpl

all: helm-toolkit ceph bootstrap mariadb etcd postgresql rabbitmq memcached keystone glance horizon neutron nova cinder heat maas openstack

helm-toolkit: build-helm-toolkit

#ceph: nolint-build-ceph
ceph: build-ceph

bootstrap: build-bootstrap

mariadb: build-mariadb

etcd: build-etcd

postgresql: build-postgresql

keystone: build-keystone

cinder: build-cinder

horizon: build-horizon

rabbitmq: build-rabbitmq

glance: build-glance

neutron: build-neutron

nova: build-nova

heat: build-heat

maas: build-maas

memcached: build-memcached

openstack: build-openstack

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
