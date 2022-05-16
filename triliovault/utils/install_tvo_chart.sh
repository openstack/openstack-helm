#!/bin/bash -x

cd ../../
helm upgrade --install triliovault ./triliovault --namespace=triliovault --values=./triliovault/values_overrides/image_pull_secrets.yaml --values=./triliovault/values_overrides/conf_triliovault.yaml --values=./triliovault/values_overrides/train-ubuntu_bionic.yaml
