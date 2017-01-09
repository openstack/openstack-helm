#!/bin/bash
set -ex

# order of kolla_keystone_bootstrap urls
# for those of looking for a little expanation
# to a mysterious blackbox
# 
# these will feed into the keystone endpoints
# so it is important they are correct
#
# keystone_admin_url
# keystone_internal_url 
# keystone_public_url 

keystone-manage db_sync
kolla_keystone_bootstrap {{ .Values.keystone.admin_user }} {{ .Values.keystone.admin_password }} \
  {{ .Values.keystone.admin_project_name }} admin \
  {{ include "endpoint_keystone_admin" . }} \
  {{ include "endpoint_keystone_internal" . }} \
  {{ include "endpoint_keystone_internal" . }} \
  {{ .Values.keystone.admin_region_name }}

