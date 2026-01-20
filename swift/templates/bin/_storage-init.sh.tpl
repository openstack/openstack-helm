{{/*
Licensed under the Apache License, Version 2.0 (the "License");
*/}}

{{- define "swift.bin.storage_init" }}
#!/bin/bash
set -e

export HOME=/tmp

echo "=== Swift Storage Validation ==="

# Create swift user if it doesn't exist
getent group swift >/dev/null || groupadd -r swift
getent passwd swift >/dev/null || useradd -r -g swift -d /var/lib/swift -s /sbin/nologin swift

# Create required directories
mkdir -p /var/cache/swift /var/run/swift /var/lock /var/log/swift

# Validate storage devices from values.yaml
ERRORS=0
{{- range $device := .Values.ring.devices }}
DEVICE_NAME="{{ $device.name }}"
STOREDIR="/srv/node/${DEVICE_NAME}"

echo "Checking device: $DEVICE_NAME at $STOREDIR"

if [ ! -d "$STOREDIR" ]; then
    echo "ERROR: Storage directory $STOREDIR does not exist!"
    echo "       Please mount your storage device to $STOREDIR before deploying Swift."
    ERRORS=$((ERRORS + 1))
    continue
fi

# Check if it's a mountpoint or at least writable
if ! touch "$STOREDIR/.swift_test" 2>/dev/null; then
    echo "ERROR: Storage directory $STOREDIR is not writable!"
    ERRORS=$((ERRORS + 1))
    continue
fi
rm -f "$STOREDIR/.swift_test"

echo "  ✓ $STOREDIR is valid and writable"
{{- end }}

if [ $ERRORS -gt 0 ]; then
    echo ""
    echo "=========================================="
    echo "STORAGE VALIDATION FAILED"
    echo "=========================================="
    echo ""
    echo "Swift requires pre-mounted storage devices."
    echo "Please prepare your storage before deploying:"
    echo ""
    echo "For production (real disks):"
    echo "  mkfs.xfs /dev/sdX"
    echo "  mkdir -p /srv/node/sdX"
    echo "  mount /dev/sdX /srv/node/sdX"
    echo ""
    echo "For testing (loop devices):"
    echo "  truncate -s 1G /var/lib/swift/sdb1.img"
    echo "  losetup /dev/loop0 /var/lib/swift/sdb1.img"
    echo "  mkfs.xfs /dev/loop0"
    echo "  mkdir -p /srv/node/sdb1"
    echo "  mount /dev/loop0 /srv/node/sdb1"
    echo ""
    exit 1
fi

# Set permissions
chown -R swift:swift /srv/node /var/cache/swift /var/run/swift /var/lock /var/log/swift
chmod -R 755 /srv/node /var/cache/swift

echo ""
echo "=== Storage directories ==="
ls -la /srv/node/

echo ""
echo "=== Mount points ==="
mount | grep /srv/node || echo "(No dedicated mounts found - using directory storage)"

echo ""
echo "Storage validation complete - all devices ready"
{{- end }}
