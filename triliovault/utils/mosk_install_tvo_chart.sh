#!/bin/bash -x

cd ../../
helm upgrade --install triliovault ./triliovault --namespace=openstack \
--values=./triliovault/values_overrides/image_pull_secrets.yaml 
--values=./triliovault/values_overrides/conf_triliovault.yaml \
--values=./triliovault/values_overrides/victoria-ubuntu_focal.yaml \
--values=./triliovault/values_overrides/admin_creds.yaml
