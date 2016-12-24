#!/bin/bash
set -ex

# Loading Apache2 ENV variables
source /etc/apache2/envvars
rm -rf /var/run/apache2/*
APACHE_DIR="apache2"

# Compress Horizon's assets.
/var/lib/kolla/venv/bin/manage.py collectstatic --noinput 
/var/lib/kolla/venv/bin/manage.py compress --force
rm -rf /tmp/_tmp_.secret_key_store.lock /tmp/.secret_key_store

# wsgi/horizon-http needs open files here, including secret_key_store
chown -R horizon /var/lib/kolla/venv/lib/python2.7/site-packages/openstack_dashboard/local/

apache2 -DFOREGROUND

