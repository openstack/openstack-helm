#!/bin/bash
set -ex
export HOME=/tmp

ansible localhost -vvv -m kolla_keystone_service -a "service_name=neutron \
service_type=network \
description='Openstack Networking' \
endpoint_region={{ .Values.keystone.neutron_region_name }} \
url='{{ include "helm-toolkit.endpoint_neutron_api_internal" . }}' \
interface=admin \
region_name={{ .Values.keystone.admin_region_name }} \
auth='{{ include "helm-toolkit.keystone_auth" .}}'" \
-e "{'openstack_neutron_auth':{{ include "helm-toolkit.keystone_auth" .}}}"

ansible localhost -vvv -m kolla_keystone_service -a "service_name=neutron \
service_type=network \
description='Openstack Networking' \
endpoint_region={{ .Values.keystone.neutron_region_name }} \
url='{{ include "helm-toolkit.endpoint_neutron_api_internal" . }}' \
interface=internal \
region_name={{ .Values.keystone.admin_region_name }} \
auth='{{ include "helm-toolkit.keystone_auth" .}}'" \
-e "{'openstack_neutron_auth':{{ include "helm-toolkit.keystone_auth" .}}}"

ansible localhost -vvv -m kolla_keystone_service -a "service_name=neutron \
service_type=network \
description='Openstack Networking' \
endpoint_region={{ .Values.keystone.neutron_region_name }} \
url='{{ include "helm-toolkit.endpoint_neutron_api_internal" . }}' \
interface=public \
region_name={{ .Values.keystone.admin_region_name }} \
auth='{{ include "helm-toolkit.keystone_auth" .}}'" \
-e "{'openstack_neutron_auth':{{ include "helm-toolkit.keystone_auth" .}}}"

ansible localhost -vvv -m kolla_keystone_user -a "project=service \
user={{ .Values.keystone.neutron_user }} \
password={{ .Values.keystone.neutron_password }} \
role=admin \
region_name={{ .Values.keystone.neutron_region_name }} \
auth='{{ include "helm-toolkit.keystone_auth" .}}'" \
-e "{'openstack_neutron_auth':{{ include "helm-toolkit.keystone_auth" .}}}"
