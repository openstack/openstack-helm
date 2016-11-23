.PHONY: ceph mariadb all clean base64

B64_DIRS := utils/secrets
B64_EXCLUDE := $(wildcard utils/secrets/*.b64)

all: base64 utils ceph mariadb openstack

utils: build-utils

ceph: build-ceph

mariadb: build-mariadb

openstack: build-openstack
	
clean:  
	$(shell find . -name '*.b64' -exec rm {} \;)
	$(shell find . -name '_partials.tpl' -exec rm {} \;)
	echo "Removed all .b64 and _partials.tpl"

base64: 
	# rebuild all base64 values
	$(eval B64_OBJS = $(foreach dir,$(B64_DIRS),$(shell find $(dir)/* -type f $(foreach e,$(B64_EXCLUDE), -not -path "$(e)"))))
	$(foreach var,$(B64_OBJS),cat $(var) | base64 | perl -pe 'chomp if eof' > $(var).b64;)


build-%:
	if [ -f $*/Makefile ]; then make -C $*; fi
	if [ -f $*/requirements.yaml ]; then helm dep up $*; fi
	helm package $*
