
# # include .env

# VARS:=$(shell sed -ne 's/ *\#.*$$//; /./ s/=.*$$// p' .env)
# $(foreach v,$(VARS),$(eval $(shell echo export $(v)="$($(v))")))
path:=`pwd`
default: build
.PHONY: fmt lint test cover build consumer start

dl-offline-pkg:
	@echo ${path}
	@cd ${path}
	@chmod +x "${path}/images/offline.sh"
	@pwd
	@sh "${path}/images/offline.sh"