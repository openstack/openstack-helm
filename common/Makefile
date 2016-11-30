EXCLUDE := templates/* charts/* Chart.yaml requirement* values.yaml Makefile utils/* common/Chart.yaml
SECRETS := $(shell find secrets -type f $(foreach e,$(EXCLUDE), -not -path "$(e)") )

templates/_secrets.tpl: Makefile $(SECRETS)
	echo Generating $(CURDIR)/$@
	rm -f $@
	for i in $(SECRETS); do  printf '{{ define "'$$i'" }}' >> $@; cat $$i >> $@; printf "{{ end }}\n" >> $@; done
