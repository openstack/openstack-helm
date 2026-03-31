#!/bin/bash
set -xe

{{- $url := tuple "ldap" "internal" . | include "helm-toolkit.endpoints.hostname_fqdn_endpoint_lookup" }}
{{- $port := tuple "ldap" "internal" "ldap" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
LDAPHOST="{{ .Values.endpoints.ldap.scheme }}://{{ $url }}:{{ $port }}"
ADMIN="cn={{ .Values.secrets.identity.admin }},{{ tuple .Values.openldap.domain . | include "splitdomain" }}"
PASSWORD="{{ .Values.openldap.password }}"

# Wait for LDAP server to be ready
retries=0
max_retries=60
until ldapsearch -x -H $LDAPHOST -b "" -s base "(objectclass=*)" namingContexts 2>/dev/null | grep -q namingContexts; do
  retries=$((retries + 1))
  if [ $retries -ge $max_retries ]; then
    echo "ERROR: LDAP server not reachable after $max_retries attempts"
    exit 1
  fi
  echo "Waiting for LDAP server to be ready... ($retries/$max_retries)"
  sleep 5
done

ldapadd -x -c -D $ADMIN -H $LDAPHOST -w $PASSWORD -f /etc/sample_data.ldif
