#!/bin/bash
set -ex

# link our keystone wsgi to apaches running config
ln -s /configmaps/wsgi-keystone.conf /etc/apache2/sites-enabled/wsgi-keystone.conf

# Loading Apache2 ENV variables
source /etc/apache2/envvars
rm -rf /var/run/apache2/*
APACHE_DIR="apache2"

apache2 -DFOREGROUND
