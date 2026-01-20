{{/*
Licensed under the Apache License, Version 2.0 (the "License");
*/}}

{{- define "swift.bin.swift_test" }}
#!/bin/bash
set -ex

export HOME=/tmp

echo "===== Swift Functional Test ====="

# Get authentication token
echo "Getting Keystone token..."
TOKEN=$(openstack token issue -f value -c id)
echo "Token obtained successfully"

# Get Swift endpoint
SWIFT_URL=$(openstack endpoint list --service swift --interface public -f value -c URL | head -1)
echo "Swift URL: $SWIFT_URL"

# Test Swift stat
echo ""
echo "Testing swift stat..."
swift stat

# Create test container
CONTAINER="test-container-$(date +%s)"
echo ""
echo "Creating container: $CONTAINER"
swift post $CONTAINER

# List containers
echo ""
echo "Listing containers..."
swift list

# Upload a test file
echo "Hello from OpenStack Swift!" > /tmp/testfile.txt
echo ""
echo "Uploading test file..."
swift upload $CONTAINER /tmp/testfile.txt --object-name hello.txt

# List objects in container
echo ""
echo "Listing objects in $CONTAINER..."
swift list $CONTAINER

# Download and verify
echo ""
echo "Downloading test file..."
swift download $CONTAINER hello.txt -o /tmp/downloaded.txt
cat /tmp/downloaded.txt

# Cleanup
echo ""
echo "Cleaning up..."
swift delete $CONTAINER hello.txt
swift delete $CONTAINER

echo ""
echo "===== Swift Test Complete ====="
{{- end }}
