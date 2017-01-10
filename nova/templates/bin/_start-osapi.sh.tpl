#!/bin/bash
set -ex 

#
# start nova-api-osapi service
#
# this helper script ensures our osapi service does not try to call iptables which requires privileged or NET_ADMIN privileges
# by stubbing in a fake iptables scripts

echo <<EOF>/tmp/iptables
#!/bin/sh
# nova-api-metadata trys to run some iptables commands
# This enables the api-only container to run without NET_ADMIN privileges
true
EOF

# make it executable and copy it over whatever iptables may be underneath in this image
chmod +x /tmp/iptables
cp -p /tmp/iptables /sbin/iptables
cp -p /tmp/iptables /sbin/iptables-restore
cp -p /tmp/iptables /sbin/iptables-save

exec nova-api --config-file /etc/nova/nova.conf