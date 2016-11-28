EXCLUDE := templates/* charts/* Chart.yaml requirement* values.yaml Makefile utils/* openstack-base/Chart.yaml
FILES := $(shell find * -type f $(foreach e,$(EXCLUDE), -not -path "$(e)") )

templates/_common.tpl: Makefile $(FILES)
	echo Generating $(CURDIR)/$@
	rm -f $@
	for i in $(FILES); do  printf '{{ define "'$$i'" }}' >> $@; cat $$i >> $@; printf "{{ end }}\n" >> $@; done
