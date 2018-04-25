#!/bin/bash
set -xe

{{- $url := tuple "ldap" "internal" . | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}
{{- $port := tuple "ldap" "internal" "ldap" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
LDAPHOST="ldap://{{ $url }}:{{ $port }}"
ADMIN="cn={{ .Values.endpoints.ldap.auth.username }},{{ tuple .Values.endpoints.ldap.auth.domainname . | include "splitdomain" }}"
ldapadd -x -D $ADMIN -H $LDAPHOST -w {{ .Values.endpoints.ldap.auth.password }} -f /etc/sample_data.ldif
