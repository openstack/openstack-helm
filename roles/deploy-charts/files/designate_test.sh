#!/bin/bash

#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
set -xe

export OS_CLOUD=openstack_helm
ZONE=osh-test.example.

# Query PowerDNS from the designate-mdns pod, whose venv has dnspython.
# Prints the rcode, then the answer.
pdns_query() {
  local pod
  pod=$(kubectl get pods -n osh -l application=designate,component=mdns -o name | head -1)
  kubectl exec -n osh "$pod" -c designate-mdns -- python -c '
import os, sys, dns.message, dns.query, dns.rcode
q = dns.message.make_query(sys.argv[1], sys.argv[2])
r = dns.query.udp(q, os.environ["POWERDNS_SERVICE_HOST"], timeout=5)
print(dns.rcode.to_text(r.rcode()))
for rrset in r.answer:
    print(rrset)
' "$1" "$2"
}

# Waits for a zone or recordset status: wait_status <status> <command...>
wait_status() {
  local want=$1 status
  shift
  for _ in $(seq 60); do
    status=$("$@" -f value -c status)
    [ "$status" = "$want" ] && return 0
    [ "$status" = ERROR ] && return 1
    sleep 5
  done
  return 1
}

openstack zone create --email admin@example.org "$ZONE"

# ACTIVE once the worker has created the zone on PowerDNS and seen its serial
# there, i.e. after PowerDNS transferred the zone from designate-mdns.
wait_status ACTIVE openstack zone show "$ZONE"
pdns_query "$ZONE" SOA | grep -F "ns.osh.svc.cluster.local."

# A record change reaches PowerDNS through the worker's NOTIFY.
openstack recordset create --type A --record 192.0.2.10 "$ZONE" www
wait_status ACTIVE openstack recordset show "$ZONE" "www.$ZONE"
pdns_query "www.$ZONE" A | grep -F "192.0.2.10"

openstack zone delete "$ZONE"
for _ in $(seq 60); do
  openstack zone show "$ZONE" >/dev/null 2>&1 || break
  sleep 5
done
if openstack zone show "$ZONE" >/dev/null 2>&1; then exit 1; fi
# PowerDNS no longer serves the zone.
for _ in $(seq 30); do
  [ "$(pdns_query "$ZONE" SOA | head -1)" = REFUSED ] && exit 0
  sleep 5
done
exit 1
