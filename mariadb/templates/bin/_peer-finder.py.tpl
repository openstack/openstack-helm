#!/usr/bin/env python
import json
import os
import urllib2
import ssl
import socket
import sys
import time

URL = ('https://kubernetes.default.svc.cluster.local/api/v1/namespaces/{namespace}'
       '/endpoints/{service_name}')
TOKEN_FILE = '/var/run/secrets/kubernetes.io/serviceaccount/token'


def get_service_endpoints(service_name):
    url = URL.format(namespace=os.environ['NAMESPACE'], service_name=service_name)
    try:
        token = file (TOKEN_FILE, 'r').read()
    except KeyError:
        exit("Unable to open a file with token.")
    header = {'Authorization': " Bearer {}".format(token)}
    req = urllib2.Request(url=url, headers=header)

    ctx = create_ctx()
    connection = urllib2.urlopen(req, context=ctx)
    data = connection.read()

    # parse to dict
    json_acceptable_string = data.replace("'", "\"")
    output = json.loads(json_acceptable_string)

    return output


def get_ip_addresses(output, force_only_members=False):
    subsets = output['subsets'][0]
    if not 'addresses' in subsets:
        return []

    # where we are seeding, the only cluster member is the seed job
    if not force_only_members:
        for subset in subsets['addresses']:
            if subset.has_key('name'):
                if 'seed' in subset['name']:
                    return [subset['ip']]

    # otherwise use the other cluster members
    ip_addresses = [x['ip'] for x in subsets['addresses']]
    my_ip = get_my_ip_address()
    if my_ip in ip_addresses:
        ip_addresses.remove(my_ip)
    return ip_addresses


def get_my_ip_address():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(('kubernetes.default.svc.cluster.local', 0))
    return s.getsockname()[0]


def create_ctx():
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    return ctx


def print_galera_cluster_address(service_name, force_only_members):
    while True:
        output = get_service_endpoints(service_name)
        ips = get_ip_addresses(output, force_only_members)
        #print "=== OUTPUT: %s" % output
        #print "=== IPS: %s" % ips
        if len(ips):
            wsrep_cluster_address =  '--wsrep_cluster_address=gcomm://{}'.format(
                ','.join(get_ip_addresses(output)))
            print wsrep_cluster_address
            break
        time.sleep(5)


def main():
    if len(sys.argv) != 3:
        exit('peer-finder: You need to pass argument <service name> <1|0 for force cluster members>')
    service_name = sys.argv[1]
    force_only_members = int(sys.argv[2])
    print_galera_cluster_address(service_name, force_only_members)

if __name__ == '__main__':
    main()

