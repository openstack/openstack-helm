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
  {{ .Values.keystone.scheme }}://{{ include "keystone_api_endpoint_host_admin" . }}:{{ .Values.network.port.admin }}/{{ .Values.keystone.version }} \
  {{ .Values.keystone.scheme }}://{{ include "keystone_api_endpoint_host_internal" . }}:{{ .Values.network.port.public }}/{{ .Values.keystone.version }} \
  {{ .Values.keystone.scheme }}://{{ include "keystone_api_endpoint_host_public" . }}:{{ .Values.network.port.public }}/{{ .Values.keystone.version }} \
  {{ .Values.keystone.admin_region_name }}
