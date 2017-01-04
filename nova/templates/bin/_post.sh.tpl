#!/bin/bash
set -ex
export HOME=/tmp

ansible localhost -vvv -m kolla_keystone_service -a "service_name=nova \
service_type=compute \
description='Openstack Compute' \
endpoint_region={{ .Values.keystone.nova_region_name }} \
url='{{ include "endpoint_nova_api_internal" . }}' \
interface=admin \
region_name={{ .Values.keystone.admin_region_name }} \
auth='{{ include "keystone_auth" .}}'" \
-e "{'openstack_nova_auth':{{ include "keystone_auth" .}}}"

ansible localhost -vvv -m kolla_keystone_service -a "service_name=nova \
service_type=compute \
description='Openstack Compute' \
endpoint_region={{ .Values.keystone.nova_region_name }} \
url='{{ include "endpoint_nova_api_internal" . }}' \
interface=internal \
region_name={{ .Values.keystone.admin_region_name }} \
auth='{{ include "keystone_auth" .}}'" \
-e "{'openstack_nova_auth':{{ include "keystone_auth" .}}}"

ansible localhost -vvv -m kolla_keystone_service -a "service_name=nova \
service_type=compute \
description='Openstack Compute' \
endpoint_region={{ .Values.keystone.nova_region_name }} \
url='{{ include "endpoint_nova_api_internal" . }}' \
interface=public \
region_name={{ .Values.keystone.admin_region_name }} \
auth='{{ include "keystone_auth" .}}'" \
-e "{'openstack_nova_auth':{{ include "keystone_auth" .}}}"

ansible localhost -vvv -m kolla_keystone_user -a "project=service \
user={{ .Values.keystone.nova_user }} \
password={{ .Values.keystone.nova_password }} \
role=admin \
region_name={{ .Values.keystone.nova_region_name }} \
auth='{{ include "keystone_auth" .}}'" \
-e "{'openstack_nova_auth':{{ include "keystone_auth" .}}}"

cat <<EOF>/tmp/openrc
export OS_USERNAME={{.Values.keystone.admin_user}}
export OS_PASSWORD={{.Values.keystone.admin_password}}
export OS_PROJECT_DOMAIN_NAME={{.Values.keystone.domain_name}}
export OS_USER_DOMAIN_NAME={{.Values.keystone.domain_name}}
export OS_PROJECT_NAME={{.Values.keystone.admin_project_name}}
export OS_AUTH_URL={{include "endpoint_keystone_internal" .}}
export OS_AUTH_STRATEGY=keystone
export OS_REGION_NAME={{.Values.keystone.admin_region_name}}
export OS_INSECURE=1
EOF

. /tmp/openrc
env
openstack --debug role create _member_ --or-show
