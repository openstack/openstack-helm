#!/bin/bash
set -ex

keystone-manage --config-file=/etc/keystone/keystone.conf db_sync

keystone-manage --config-file=/etc/keystone/keystone.conf bootstrap \
    --bootstrap-username {{ .Values.keystone.admin_user }} \
    --bootstrap-password {{ .Values.keystone.admin_password }} \
    --bootstrap-project-name {{ .Values.keystone.admin_project_name }} \
    --bootstrap-admin-url {{ include "endpoint_keystone_admin" . }} \
    --bootstrap-public-url {{ include "endpoint_keystone_internal" . }} \
    --bootstrap-internal-url {{ include "endpoint_keystone_internal" . }} \
    --bootstrap-region-id {{ .Values.keystone.admin_region_name }}
