{{/*
Licensed under the Apache License, Version 2.0 (the "License");
*/}}

{{- define "swift.bin.proxy_start" }}
#!/bin/bash
set -ex

export HOME=/tmp

# Wait for ring files
echo "Waiting for ring files..."
while [ ! -f /etc/swift/account.ring.gz ] || [ ! -f /etc/swift/container.ring.gz ] || [ ! -f /etc/swift/object.ring.gz ]; do
    echo "Ring files not found, waiting..."
    sleep 5
done

echo "Ring files found"
ls -la /etc/swift/*.ring.gz

# Create required directories
mkdir -p /var/cache/swift /var/run/swift /var/log/swift

# Set permissions
chown -R swift:swift /etc/swift /var/cache/swift /var/run/swift /var/log/swift 2>/dev/null || true

# Resolve DNS and add to /etc/hosts to work around eventlet DNS issues
echo "Resolving service endpoints for eventlet compatibility..."
{{- $identityHost := tuple "identity" "internal" . | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}
{{- $cacheHost := tuple "oslo_cache" "internal" . | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}

# Resolve keystone
KEYSTONE_HOST="{{ $identityHost }}"
if [ -n "$KEYSTONE_HOST" ] && [ "$KEYSTONE_HOST" != "null" ]; then
    KEYSTONE_IP=$(getent hosts "$KEYSTONE_HOST" | awk '{print $1}' | head -1)
    if [ -n "$KEYSTONE_IP" ]; then
        echo "$KEYSTONE_IP $KEYSTONE_HOST" >> /etc/hosts
        echo "Added $KEYSTONE_IP $KEYSTONE_HOST to /etc/hosts"
    fi
fi

# Resolve memcached
MEMCACHE_HOST="{{ $cacheHost }}"
if [ -n "$MEMCACHE_HOST" ] && [ "$MEMCACHE_HOST" != "null" ]; then
    MEMCACHE_IP=$(getent hosts "$MEMCACHE_HOST" | awk '{print $1}' | head -1)
    if [ -n "$MEMCACHE_IP" ]; then
        echo "$MEMCACHE_IP $MEMCACHE_HOST" >> /etc/hosts
        echo "Added $MEMCACHE_IP $MEMCACHE_HOST to /etc/hosts"
    fi
fi

echo "Starting Swift Proxy Server..."
exec swift-proxy-server /etc/swift/proxy-server.conf --verbose
{{- end }}
