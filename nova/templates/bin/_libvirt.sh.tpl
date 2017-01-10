#!/bin/bash
set -ex

if [[ -f /var/run/libvirtd.pid ]]; then
   test -d /proc/$(< /var/run/libvirtd.pid) && \
   ( echo "Libvirtd daemon is running" && exit 10 )
fi

rm -f /var/run/libvirtd.pid

if [[ -c /dev/kvm ]]; then
    chmod 660 /dev/kvm
    chown root:kvm /dev/kvm
fi


sleep 30

{{- if .Values.ceph.enabled }}
cat > /tmp/secret.xml <<EOF
<secret ephemeral='no' private='no'>
  <uuid>{{ .Values.ceph.secret_uuid }}</uuid>
  <usage type='ceph'>
    <name>client.{{ .Values.ceph.cinder_user }} secret</name>
  </usage>
</secret>
EOF

virsh secret-define --file /tmp/secret.xml
virsh secret-set-value --secret {{ .Values.ceph.secret_uuid }} --base64 {{ .Values.ceph.cinder_keyring }}
rm /tmp/secret.xml
{{- end }}


exec libvirtd -v --listen
