{{/*
Copyright 2017 The Openstack-Helm Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

[{{ .Values.conf.glance.glance_store.glance.store.default_swift_reference }}]
{{- if eq .Values.storage "radosgw" }}
auth_version = 1
auth_address = {{ tuple "ceph_object_store" "public" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}
user = {{ .Values.endpoints.ceph_object_store.auth.user.username }}:swift
key = {{ .Values.endpoints.ceph_object_store.auth.user.password }}
{{- else }}
user = {{ .Values.endpoints.identity.auth.user.project_name }}:{{ .Values.endpoints.identity.auth.user.username }}
key = {{ .Values.endpoints.identity.auth.user.password }}
auth_address = {{ tuple "identity" "internal" "api" . | include "helm-toolkit.endpoints.keystone_endpoint_uri_lookup" }}
user_domain_name = {{ .Values.endpoints.identity.auth.user.user_domain_name }}
project_domain_name = {{ .Values.endpoints.identity.auth.user.project_domain_name }}
auth_version = 3
{{- end -}}
