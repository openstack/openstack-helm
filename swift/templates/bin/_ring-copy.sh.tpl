{{/*
Licensed under the Apache License, Version 2.0 (the "License");
*/}}

{{- define "swift.bin.ring_copy" }}
#!/bin/bash
set -ex

echo "=== Swift Copy rings from shared storage ==="

for base in account container object; do
  if [[ ! -f /etc/swift/${base}.ring.gz ]]; then
    echo "Ring file /etc/swift/${base}.ring.gz not found in /etc/swift, attempting to copy from shared storage."
    cp /etc/swift-rings/${base}.ring.gz /etc/swift/
    echo "Copied ${base}.ring.gz from shared storage."
  fi
  if [[ ! -f /etc/swift/${base}.builder ]]; then
    echo "Builder file /etc/swift/${base}.builder not found in /etc/swift, attempting to copy from shared storage."
    cp /etc/swift-rings/${base}.builder /etc/swift/
    echo "Copied ${base}.builder from shared storage."
  fi
done
{{- end }}
