{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

{{- define "swift.bin.object_start" }}
#!/bin/bash
set -ex

export HOME=/tmp

# Wait for ring files
echo "Waiting for object ring file..."
while [ ! -f /etc/swift/object.ring.gz ]; do
    echo "Object ring file not found, waiting..."
    sleep 5
done

echo "Object ring file found"

# Create required directories
mkdir -p /var/cache/swift /var/run/swift /var/log/swift /var/lock

# Set permissions
chown -R swift:swift /etc/swift /srv/node /var/cache/swift /var/run/swift /var/log/swift /var/lock 2>/dev/null || true

# Start rsync daemon (object replication uses rsync)
echo "Starting rsync daemon..."
rsync --daemon --config=/etc/swift/rsyncd.conf

# Start object services
echo "Starting object services..."
swift-object-server /etc/swift/object-server.conf &
swift-object-auditor /etc/swift/object-server.conf &
swift-object-replicator /etc/swift/object-server.conf &
swift-object-updater /etc/swift/object-server.conf &
swift-object-reconstructor /etc/swift/object-server.conf 2>/dev/null &

echo "Swift object services started"

# Wait for any process to exit
wait
{{- end }}
