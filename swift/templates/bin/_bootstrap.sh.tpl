{{/*
Licensed under the Apache License, Version 2.0 (the "License");
*/}}

{{- define "swift.bin.bootstrap" }}
#!/bin/bash
set -ex

echo "Swift bootstrap started"

# Source credentials
export OS_AUTH_URL={{ tuple "identity" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}
export OS_IDENTITY_API_VERSION=3
export OS_USERNAME={{ .Values.endpoints.identity.auth.admin.username }}
export OS_PASSWORD={{ .Values.endpoints.identity.auth.admin.password }}
export OS_PROJECT_NAME={{ .Values.endpoints.identity.auth.admin.project_name }}
export OS_USER_DOMAIN_NAME={{ .Values.endpoints.identity.auth.admin.user_domain_name }}
export OS_PROJECT_DOMAIN_NAME={{ .Values.endpoints.identity.auth.admin.project_domain_name }}
export OS_INTERFACE=internal

# Wait for Swift proxy to be ready
SWIFT_ENDPOINT={{ tuple "object_store" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}
echo "Waiting for Swift endpoint at ${SWIFT_ENDPOINT}..."
count=0
while ! curl -s -o /dev/null -w '%{http_code}' "${SWIFT_ENDPOINT}/healthcheck" | grep -q "200"; do
    if [ $count -ge 60 ]; then
        echo "Timeout waiting for Swift endpoint"
        exit 1
    fi
    echo "Waiting for Swift endpoint..."
    sleep 5
    count=$((count+1))
done

echo "Swift endpoint is healthy"

# Run any custom bootstrap script
{{ .Values.bootstrap.script | default "" }}

echo "Swift bootstrap complete"
{{- end }}
