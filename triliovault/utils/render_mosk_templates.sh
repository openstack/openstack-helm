#!/bin/bash -x
cd ../..
helm template -f triliovault/values_overrides/admin_creds.yaml \
-f triliovault/values_overrides/image_pull_secrets.yaml \
-f triliovault/values_overrides/conf_triliovault.yaml \
-f triliovault/values_overrides/ceph.yaml \
-f triliovault/values_overrides/tls_public_endpoint.yaml \
--debug triliovault > triliovault/utils/manifest.yaml
