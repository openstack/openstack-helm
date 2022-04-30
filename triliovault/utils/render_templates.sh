#!/bin/bash -x
cd ../..
helm template -f triliovault/values_overrides/image_pull_secrets.yaml -f triliovault/values_overrides/conf_triliovault.yaml --debug triliovault > triliovault/utils/manifest.yaml
