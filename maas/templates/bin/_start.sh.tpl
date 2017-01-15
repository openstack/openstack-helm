#!/bin/bash
set -ex

if ! find "/etc/postgresql" -mindepth 1 -print -quit | grep -q .; then
    pg_createcluster 9.5 main
fi

cp -r /etc/postgresql/9.5/main/*.conf /var/lib/postgresql/9.5/main/
pg_ctlcluster 9.5 main start

echo 'running postinst'

chmod 755 /var/lib/dpkg/info/maas-region-controller.postinst
/bin/sh /var/lib/dpkg/info/maas-region-controller.postinst configure
