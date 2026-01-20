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

{{- define "swift.bin.account_start" }}
#!/bin/bash
set -ex

export HOME=/tmp

# Wait for ring files
echo "Waiting for account ring file..."
while [ ! -f /etc/swift/account.ring.gz ]; do
    echo "Account ring file not found, waiting..."
    sleep 5
done

echo "Account ring file found"

# Create required directories
mkdir -p /var/cache/swift /var/run/swift /var/log/swift /var/lock

# Set permissions
chown -R swift:swift /etc/swift /srv/node /var/cache/swift /var/run/swift /var/log/swift /var/lock 2>/dev/null || true

# Start account services
echo "Starting account services..."
swift-account-server /etc/swift/account-server.conf &
swift-account-auditor /etc/swift/account-server.conf &
swift-account-reaper /etc/swift/account-server.conf &
swift-account-replicator /etc/swift/account-server.conf &

echo "Swift account services started"

# Wait for any process to exit
wait
{{- end }}
