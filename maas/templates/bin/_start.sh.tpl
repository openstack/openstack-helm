#!/bin/bash
set -ex

if ! find "/etc/postgresql" -mindepth 1 -print -quit | grep -q .; then
    pg_createcluster 9.5 main

    #allow external connections to postgresql
    sed -i '/#listen_addresses/s/^#//g' /etc/postgresql/9.5/main/postgresql.conf
    sed -i '/^listen_addresses/ s/localhost/*/' /etc/postgresql/9.5/main/postgresql.conf
    sed -i '$ a host all all 0.0.0.0/0 md5' /etc/postgresql/9.5/main/pg_hba.conf
    sed -i '$ a host all all ::/0 md5' /etc/postgresql/9.5/main/pg_hba.conf
fi

cp -r /etc/postgresql/9.5/main/*.conf /var/lib/postgresql/9.5/main/
pg_ctlcluster 9.5 main start

echo 'running postinst'

chmod 755 /var/lib/dpkg/info/maas-region-controller.postinst
/bin/sh /var/lib/dpkg/info/maas-region-controller.postinst configure

maas-region createadmin --username={{ .Values.credentials.admin_username }} --password={{ .Values.credentials.admin_password }} --email={{ .Values.credentials.admin_email }} || true
