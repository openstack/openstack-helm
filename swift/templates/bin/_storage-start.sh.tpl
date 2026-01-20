{{/*
Licensed under the Apache License, Version 2.0 (the "License");
*/}}

{{- define "swift.bin.storage_start" }}
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
mkdir -p /var/cache/swift /var/run/swift /var/log/swift /var/lock

# Set permissions
chown -R swift:swift /etc/swift /srv/node /var/cache/swift /var/run/swift /var/log/swift /var/lock 2>/dev/null || true

# Start rsync daemon
echo "Starting rsync daemon..."
rsync --daemon --config=/etc/swift/rsyncd.conf

# Start account services
echo "Starting account services..."
swift-account-server /etc/swift/account-server.conf &
swift-account-auditor /etc/swift/account-server.conf &
swift-account-reaper /etc/swift/account-server.conf &
swift-account-replicator /etc/swift/account-server.conf &

# Start container services
echo "Starting container services..."
swift-container-server /etc/swift/container-server.conf &
swift-container-auditor /etc/swift/container-server.conf &
swift-container-replicator /etc/swift/container-server.conf &
swift-container-updater /etc/swift/container-server.conf &

# Start object services
echo "Starting object services..."
swift-object-server /etc/swift/object-server.conf &
swift-object-auditor /etc/swift/object-server.conf &
swift-object-replicator /etc/swift/object-server.conf &
swift-object-updater /etc/swift/object-server.conf &

echo "All Swift storage services started"

# Wait for any process to exit
wait
{{- end }}
