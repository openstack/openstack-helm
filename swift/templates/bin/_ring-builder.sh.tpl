{{/*
Licensed under the Apache License, Version 2.0 (the "License");
*/}}

{{- define "swift.bin.ring_builder" }}
#!/bin/bash
set -ex

export HOME=/tmp

cd /etc/swift

PARTITION_POWER={{ .Values.ring.partition_power }}
REPLICAS={{ .Values.ring.replicas }}
MIN_PART_HOURS={{ .Values.ring.min_part_hours }}

# Get the storage service IP (for Kubernetes, use the storage service)
STORAGE_IP=${SWIFT_STORAGE_IP:-"127.0.0.1"}

echo "Building Swift rings with partition_power=$PARTITION_POWER, replicas=$REPLICAS, min_part_hours=$MIN_PART_HOURS"
echo "Storage IP: $STORAGE_IP"

# Create ring builder files if they don't exist
if [ ! -f account.builder ]; then
    swift-ring-builder account.builder create $PARTITION_POWER $REPLICAS $MIN_PART_HOURS
fi

if [ ! -f container.builder ]; then
    swift-ring-builder container.builder create $PARTITION_POWER $REPLICAS $MIN_PART_HOURS
fi

if [ ! -f object.builder ]; then
    swift-ring-builder object.builder create $PARTITION_POWER $REPLICAS $MIN_PART_HOURS
fi

# Add devices from values
{{- range $index, $device := .Values.ring.devices }}
DEVICE_NAME="{{ $device.name }}"
DEVICE_WEIGHT="{{ $device.weight }}"

# Check if device already exists in account ring
if ! swift-ring-builder account.builder search --ip $STORAGE_IP --device $DEVICE_NAME 2>/dev/null | grep -q "$DEVICE_NAME"; then
    swift-ring-builder account.builder add \
        --region 1 --zone 1 --ip $STORAGE_IP --port 6202 \
        --device $DEVICE_NAME --weight $DEVICE_WEIGHT || true
fi

# Check if device already exists in container ring
if ! swift-ring-builder container.builder search --ip $STORAGE_IP --device $DEVICE_NAME 2>/dev/null | grep -q "$DEVICE_NAME"; then
    swift-ring-builder container.builder add \
        --region 1 --zone 1 --ip $STORAGE_IP --port 6201 \
        --device $DEVICE_NAME --weight $DEVICE_WEIGHT || true
fi

# Check if device already exists in object ring
if ! swift-ring-builder object.builder search --ip $STORAGE_IP --device $DEVICE_NAME 2>/dev/null | grep -q "$DEVICE_NAME"; then
    swift-ring-builder object.builder add \
        --region 1 --zone 1 --ip $STORAGE_IP --port 6200 \
        --device $DEVICE_NAME --weight $DEVICE_WEIGHT || true
fi
{{- end }}

# Show ring status
echo "Account Ring:"
swift-ring-builder account.builder

echo "Container Ring:"
swift-ring-builder container.builder

echo "Object Ring:"
swift-ring-builder object.builder

# Rebalance rings
swift-ring-builder account.builder rebalance || true
swift-ring-builder container.builder rebalance || true
swift-ring-builder object.builder rebalance || true

# Copy ring files to shared location
cp /etc/swift/*.ring.gz /etc/swift-rings/ 2>/dev/null || true
cp /etc/swift/*.builder /etc/swift-rings/ 2>/dev/null || true

echo "Ring files created successfully"
ls -la /etc/swift/*.ring.gz /etc/swift/*.builder
{{- end }}
