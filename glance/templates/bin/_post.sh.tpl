#!/bin/bash
set -ex
export HOME=/tmp

ansible localhost -vvv -m kolla_keystone_service -a "service_name=glance \
service_type=image \
description='Openstack Image' \
endpoint_region='{{ .Values.keystone.glance_region_name }}' \
url='{{ include "helm-toolkit.endpoint_glance_api_internal" . }}' \
interface=admin \
region_name='{{ .Values.keystone.admin_region_name }}' \
auth='{{ include "helm-toolkit.keystone_auth" . }}'" \
-e "{'openstack_glance_auth': {{ include "helm-toolkit.keystone_auth" . }}}"

ansible localhost -vvv -m kolla_keystone_service -a "service_name=glance \
service_type=image \
description='Openstack Image' \
endpoint_region='{{ .Values.keystone.glance_region_name }}' \
url='{{ include "helm-toolkit.endpoint_glance_api_internal" . }}' \
interface=internal \
region_name='{{ .Values.keystone.admin_region_name }}' \
auth='{{ include "helm-toolkit.keystone_auth" . }}'" \
-e "{ 'openstack_glance_auth': {{ include "helm-toolkit.keystone_auth" . }} }"

ansible localhost -vvv -m kolla_keystone_service -a "service_name=glance \
service_type=image \
description='Openstack Image' \
endpoint_region='{{ .Values.keystone.glance_region_name }}' \
url='{{ include "helm-toolkit.endpoint_glance_api_internal" . }}' \
interface=public \
region_name='{{ .Values.keystone.admin_region_name }}' \
auth='{{ include "helm-toolkit.keystone_auth" . }}'" \
-e "{ 'openstack_glance_auth': {{ include "helm-toolkit.keystone_auth" . }} }"

ansible localhost -vvv -m kolla_keystone_user -a "project=service \
user={{ .Values.keystone.glance_user }} \
password={{ .Values.keystone.glance_password }} \
role=admin \
region_name={{ .Values.keystone.admin_region_name }} \
auth='{{ include "helm-toolkit.keystone_auth" . }}'" \
-e "{ 'openstack_glance_auth': {{ include "helm-toolkit.keystone_auth" . }} }"
