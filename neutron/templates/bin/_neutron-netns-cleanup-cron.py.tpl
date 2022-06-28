#!/usr/bin/env python

import sys
import os
import time
import socket
from neutron.common import config
from oslo_config import cfg
from oslo_concurrency import processutils
from neutron.agent.linux import dhcp
from neutron.agent.l3 import namespaces
from neutron.agent.l3 import dvr_snat_ns
from neutron.agent.l3 import dvr_fip_ns
from neutron.cmd.netns_cleanup import setup_conf
from neutron.cmd.netns_cleanup import unplug_device
from neutron.cmd.netns_cleanup import eligible_for_deletion
from neutron.conf.agent import common as agent_config
from neutron.agent.linux import ip_lib
from keystoneauth1.identity import v3
from keystoneauth1 import session
from neutronclient.neutron import client as neutron_client
NS_PREFIXES = {'l3': [namespaces.NS_PREFIX, dvr_snat_ns.SNAT_NS_PREFIX,
                      dvr_fip_ns.FIP_NS_PREFIX]}
DHCP_NS_PREFIX = dhcp.NS_PREFIX

def get_neutron_creds():
    opts = {'auth_url': os.getenv('OS_AUTH_URL', 'https://keystone-api.openstack.svc.cluster.local:5000/v3'),
        'password': os.getenv('OS_PASSWORD','nopassword'),
        'project_domain_name': os.getenv('OS_PROJECT_DOMAIN_NAME', 'default'),
        'project_name': os.getenv('OS_PROJECT_NAME', 'admin'),
        'user_domain_name': os.getenv('OS_USER_DOMAIN_NAME', 'default'),
        'username': os.getenv('OS_USERNAME', 'admin'),
        'cafile' : os.getenv('OS_CACERT','/var/lib/neutron/openstack-helm/openstack-helm.crt'),
        'insecure' : os.getenv('NEUTRON_CLEANUP_INSECURE', 'true'),
        'debug': os.getenv('NEUTRON_CLEANUP_DEBUG', 'true'),
        'wait': os.getenv('NEUTRON_CLEANUP_TIMEOUT', '600')}
    return opts

def ldestroy_namespace(conf, namespace):
    try:
        ip = ip_lib.IPWrapper(namespace=namespace)
        if ip.netns.exists(namespace):
            cmd = ['ip', 'netns', 'pids', namespace]
            output = processutils.execute(*cmd, run_as_root=True, root_helper=conf.AGENT.root_helper)
            for pid in output[0].splitlines():
                utils.kill_process(pid, signal.SIGTERM, run_as_root=True, root_helper=conf.AGENT.root_helper)
            for device in ip.get_devices():
                unplug_device(device)
        ip.garbage_collect_namespace()
    except Exception as e:
        sys.stderr.write("Error - unable to destroy namespace: {} : {}\n".format(namespace, e))

def net_list(neutron_get):
    hosts = dict()
    net_list = neutron_get.list_networks()
    if net_list['networks']:
        for item in net_list['networks']:
            net_id=item['id']
            dhcp_agents = neutron_get.list_dhcp_agent_hosting_networks(net_id)['agents']
            agents = list()
            if dhcp_agents:
                 for agent in dhcp_agents:
                     agents.append(agent['host'].split('.')[0])
            hosts[net_id] = agents
    return hosts

def sort_ns(all_ns, dhcp_prefix):
    dhcp_ns = list()
    not_dhcp_ns = list()
    for ns in  all_ns:
        if ns[:len(dhcp_prefix)] == dhcp_prefix:
            dhcp_ns.append(ns)
        else:
            not_dhcp_ns.append(ns)
    return dhcp_ns, not_dhcp_ns

def del_bad_dhcp(dhcp_ns, dhcp_hosts, conf, dhcp_prefix, debug):
    for ns in dhcp_ns:
        cut_ns_name = ns[len(dhcp_prefix):]
        if cut_ns_name in dhcp_hosts:
            if hostname not in dhcp_hosts[cut_ns_name]:
                ldestroy_namespace(conf, ns)
                if debug:
                    sys.stderr.write("DEBUG: {} host {} deleted {} because host wrong\n"
                                     .format(sys.argv[0], hostname, ns))
            else:
                if debug:
                    sys.stderr.write("DEBUG: {} host {} {} looks ok\n"
                                     .format(sys.argv[0], hostname, ns))
        else:
            ldestroy_namespace(conf, ns)
            if debug:
                sys.stderr.write("DEBUG: {} host {} deleted {} because no related network found\n"
                                 .format(sys.argv[0], hostname, ns))

def del_bad_not_dhcp(not_dhcp_ns, conf, debug):
    for ns in not_dhcp_ns:
        if eligible_for_deletion(conf, ns, conf.force):
            ldestroy_namespace(conf, ns)
            if debug:
                sys.stderr.write("DEBUG: {} host {} deleted {} because no IP addr\n"
                                 .format(sys.argv[0], hostname, ns))

if __name__ == "__main__":

    conf = setup_conf()
    cfg.CONF(sys.argv[1:])
    opts = get_neutron_creds()
    debug = False
    verify= False
    if opts.pop('debug') in ('true', '1', 'True'):
        debug = True
    insecure = opts.pop('insecure')
    cafile = opts.pop('cafile')
    if insecure in ('false', '0', 'False'):
        verify = cafile
    timeout = int(opts.pop('wait'))
    conf()
    config.setup_logging()
    agent_config.setup_privsep()
    auth = v3.Password(**opts)
    hostname = socket.gethostname().split('.')[0]

    while True:
        try:
            all_ns = ip_lib.list_network_namespaces()
            sess = session.Session(auth=auth, verify=verify)
            neutron_get = neutron_client.Client('2.0', session=sess)
            dhcp_hosts = net_list(neutron_get)
            if all_ns:
                dhcp_ns, not_dhcp_ns = sort_ns(all_ns, DHCP_NS_PREFIX)
                if dhcp_ns:
                    del_bad_dhcp(dhcp_ns, dhcp_hosts, conf, DHCP_NS_PREFIX, debug)
                else:
                    if debug:
                        sys.stderr.write("DEBUG: {} host {} no dhcp ns found\n"
                                         .format(sys.argv[0], hostname))
                if not_dhcp_ns:
                    del_bad_not_dhcp(not_dhcp_ns, conf, debug)
                else:
                    if debug:
                        sys.stderr.write("DEBUG: {} host {} no not_dhcp ns found\n"
                                         .format(sys.argv[0], hostname))
            else:
                if debug:
                    sys.stderr.write("DEBUG: {} host {} no ns found at all\n"
                                     .format(sys.argv[0], hostname))
        except Exception as ex:
            sys.stderr.write(
                "Cleaning network namespaces caught an exception %s"
                % str(ex))
            time.sleep(30)
        except:
            sys.stderr.write(
                "Cleaning network namespaces caught an exception")
            time.sleep(30)
        time.sleep(timeout)