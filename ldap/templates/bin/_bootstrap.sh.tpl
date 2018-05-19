#!/bin/bash
set -xe

{{- $url := tuple "ldap" "internal" . | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}
{{- $port := tuple "ldap" "internal" "ldap" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
LDAPHOST="{{ .Values.endpoints.ldap.scheme }}://{{ $url }}:{{ $port }}"
ADMIN="cn={{ .Values.secrets.identity.admin }},{{ tuple .Values.openldap.domain . | include "splitdomain" }}"
ldapadd -x -D $ADMIN -H $LDAPHOST -w {{ .Values.openldap.password }} -f /etc/sample_data.ldif
