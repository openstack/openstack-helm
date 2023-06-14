#!/usr/bin/env python

{{/*
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

"""
Health probe script for OpenStack agents that uses RPC/unix domain socket for
communication. Sends message to agent through rpc call method and expects a
reply. It is expected to receive a failure from the agent's RPC server as the
method does not exist.

Script returns failure to Kubernetes only when
  a. agent is not reachable or
  b. agent times out sending a reply.

sys.stderr.write() writes to pod's events on failures.

Usage example for Neutron L3 agent:
# python health-probe.py --config-file /etc/neutron/neutron.conf \
#  --config-file /etc/neutron/l3_agent.ini --agent-queue-name l3_agent

Usage example for Neutron metadata agent:
# python health-probe.py --config-file /etc/neutron/neutron.conf \
#  --config-file /etc/neutron/metadata_agent.ini
"""

import httplib2
from http import client as httplib
import json
import os
import psutil
import signal
import socket
import sys

from oslo_config import cfg
from oslo_context import context
from oslo_log import log
import oslo_messaging

rpc_timeout = int(os.getenv('RPC_PROBE_TIMEOUT', '60'))
rpc_retries = int(os.getenv('RPC_PROBE_RETRIES', '2'))
rabbit_port = 5672
tcp_established = "ESTABLISHED"
log.logging.basicConfig(level=log.{{ .Values.health_probe.logging.level }})


def _get_hostname(use_fqdn):
    if use_fqdn:
        return socket.getfqdn()
    return socket.gethostname()

def check_agent_status(transport):
    """Verify agent status. Return success if agent consumes message"""
    try:
        use_fqdn = cfg.CONF.use_fqdn
        target = oslo_messaging.Target(
            topic=cfg.CONF.agent_queue_name,
            server=_get_hostname(use_fqdn))
        if hasattr(oslo_messaging, 'get_rpc_client'):
            client = oslo_messaging.get_rpc_client(transport, target,
                                                   timeout=rpc_timeout,
                                                   retry=rpc_retries)
        else:
            client = oslo_messaging.RPCClient(transport, target,
                                              timeout=rpc_timeout,
                                              retry=rpc_retries)
        client.call(context.RequestContext(),
                    'pod_health_probe_method_ignore_errors')
    except oslo_messaging.exceptions.MessageDeliveryFailure:
        # Log to pod events
        sys.stderr.write("Health probe unable to reach message bus")
        sys.exit(0)  # return success
    except oslo_messaging.rpc.client.RemoteError as re:
        message = getattr(re, "message", str(re))
        if ("Endpoint does not support RPC method" in message) or \
                ("Endpoint does not support RPC version" in message):
            sys.exit(0)  # Call reached the agent
        else:
            sys.stderr.write("Health probe unable to reach agent")
            sys.exit(1)  # return failure
    except oslo_messaging.exceptions.MessagingTimeout:
        sys.stderr.write("Health probe timed out. Agent is down or response "
                         "timed out")
        sys.exit(1)  # return failure
    except Exception as ex:
        message = getattr(ex, "message", str(ex))
        sys.stderr.write("Health probe caught exception sending message to "
                         "agent: %s" % message)
        sys.exit(0)
    except:
        sys.stderr.write("Health probe caught exception sending message to"
                         " agent")
        sys.exit(0)


def sriov_readiness_check():
    """Checks the sriov configuration on the sriov nic's"""
    return_status = 1
    with open('/etc/neutron/plugins/ml2/sriov_agent.ini') as nic:
        for phy in nic:
            if "physical_device_mappings" in phy:
                phy_dev = phy.split('=', 1)[1]
                phy_dev1 = phy_dev.rstrip().split(',')
                if not phy_dev1:
                    sys.stderr.write("No Physical devices"
                                     " configured as SRIOV NICs")
                    sys.exit(1)
                for intf in phy_dev1:
                    phy, dev = intf.split(':')
                    try:
                        with open('/sys/class/net/%s/device/'
                                  'sriov_numvfs' % dev) as f:
                            for line in f:
                                numvfs = line.rstrip('\n')
                                if numvfs:
                                    return_status = 0
                    except IOError:
                        sys.stderr.write("IOError:No sriov_numvfs config file")
    sys.exit(return_status)


def get_rabbitmq_ports():
    "Get RabbitMQ ports"

    rabbitmq_ports = set()

    try:
        transport_url = oslo_messaging.TransportURL.parse(cfg.CONF)
        for host in transport_url.hosts:
            rabbitmq_ports.add(host.port)
    except Exception as ex:
        message = getattr(ex, "message", str(ex))
        sys.stderr.write("Health probe caught exception reading "
                         "RabbitMQ ports: %s" % message)
        sys.exit(0)  # return success

    return rabbitmq_ports


def tcp_socket_state_check(agentq):
    """Check if the tcp socket to rabbitmq is in Established state"""
    rabbit_sock_count = 0
    parentId = 0
    if agentq == "l3_agent":
        proc = "neutron-l3-agen"
    elif agentq == "dhcp_agent":
        proc = "neutron-dhcp-ag"
    elif agentq == "q-agent-notifier-tunnel-update":
        proc = "neutron-openvsw"
    else:
        proc = "neutron-metadat"

    rabbitmq_ports = get_rabbitmq_ports()

    for p in psutil.process_iter():
        try:
            with p.oneshot():
                if proc in " ".join(p.cmdline()):
                    if parentId == 0:
                        parentId = p.pid
                    else:
                        if p.ppid() == parentId:
                            continue
                    pcon = p.connections()
                    for con in pcon:
                        try:
                            port = con.raddr[1]
                            status = con.status
                        except IndexError:
                            continue
                        if port in rabbitmq_ports and\
                                status == tcp_established:
                            rabbit_sock_count = rabbit_sock_count + 1
        except psutil.Error:
            continue

    if rabbit_sock_count == 0:
        sys.stderr.write("RabbitMQ sockets not Established")
        # Do not kill the pod if RabbitMQ is not reachable/down
        if not cfg.CONF.liveness_probe:
            sys.exit(1)


class UnixDomainHTTPConnection(httplib.HTTPConnection):
    """Connection class for HTTP over UNIX domain socket."""

    def __init__(self, host, port=None, strict=None, timeout=None,
                 proxy_info=None):
        httplib.HTTPConnection.__init__(self, host, port, strict)
        self.timeout = timeout
        self.socket_path = cfg.CONF.metadata_proxy_socket

    def connect(self):
        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        if self.timeout:
            self.sock.settimeout(self.timeout)
        self.sock.connect(self.socket_path)


def test_socket_liveness():
    """Test if agent can respond to message over the socket"""
    cfg.CONF.register_cli_opt(cfg.BoolOpt('liveness-probe', default=False,
                                          required=False))
    cfg.CONF.register_cli_opt(cfg.BoolOpt('use-fqdn', default=False,
                                          required=False))
    cfg.CONF(sys.argv[1:])

    if "ovn_metadata_agent.ini" not in ','.join(sys.argv):
        agentq = "metadata_agent"
        tcp_socket_state_check(agentq)

    try:
        metadata_proxy_socket = cfg.CONF.metadata_proxy_socket
    except cfg.NoSuchOptError:
        cfg.CONF.register_opt(cfg.StrOpt(
            'metadata_proxy_socket',
            default='/var/lib/neutron/openstack-helm/metadata_proxy'))

    headers = {'X-Forwarded-For': '169.254.169.254',
               'X-Neutron-Router-ID': 'pod-health-probe-check-ignore-errors'}

    h = httplib2.Http(timeout=30)

    try:
        resp, content = h.request(
            'http://169.254.169.254',
            method='GET',
            headers=headers,
            connection_type=UnixDomainHTTPConnection)
    except socket.error as se:
        msg = "Socket error: Health probe failed to connect to " \
              "Neutron Metadata agent: "
        if se.strerror:
            sys.stderr.write(msg + se.strerror)
        elif getattr(se, "message", False):
            sys.stderr.write(msg + se.message)
        sys.exit(1)  # return failure
    except Exception as ex:
        message = getattr(ex, "message", str(ex))
        sys.stderr.write("Health probe caught exception sending message to "
                         "Neutron Metadata agent: %s" % message)
        sys.exit(0)  # return success

    if resp.status >= 500:  # Probe expects HTTP error code 404
        msg = "Health probe failed: Neutron Metadata agent failed to" \
              " process request: "
        sys.stderr.write(msg + str(resp.__dict__))
        sys.exit(1)  # return failure


def test_rpc_liveness():
    """Test if agent can consume message from queue"""
    oslo_messaging.set_transport_defaults(control_exchange='neutron')

    rabbit_group = cfg.OptGroup(name='oslo_messaging_rabbit',
                                title='RabbitMQ options')
    cfg.CONF.register_group(rabbit_group)
    cfg.CONF.register_cli_opt(cfg.StrOpt('agent-queue-name'))
    cfg.CONF.register_cli_opt(cfg.BoolOpt('liveness-probe', default=False,
                                          required=False))
    cfg.CONF.register_cli_opt(cfg.BoolOpt('use-fqdn', default=False,
                                          required=False))

    cfg.CONF(sys.argv[1:])

    try:
        transport = oslo_messaging.get_rpc_transport(cfg.CONF)
    except Exception as ex:
        message = getattr(ex, "message", str(ex))
        sys.stderr.write("Message bus driver load error: %s" % message)
        sys.exit(0)  # return success

    if not cfg.CONF.transport_url or \
            not cfg.CONF.agent_queue_name:
        sys.stderr.write("Both message bus URL and agent queue name are "
                         "required for Health probe to work")
        sys.exit(0)  # return success

    try:
        cfg.CONF.set_override('rabbit_max_retries', 2,
                              group=rabbit_group)  # 3 attempts
    except cfg.NoSuchOptError as ex:
        cfg.CONF.register_opt(cfg.IntOpt('rabbit_max_retries', default=2),
                              group=rabbit_group)

    agentq = cfg.CONF.agent_queue_name
    tcp_socket_state_check(agentq)

    check_agent_status(transport)

def check_pid_running(pid):
    if psutil.pid_exists(int(pid)):
       return True
    else:
       return False

if __name__ == "__main__":

    if "liveness-probe" in ','.join(sys.argv):
        pidfile = "/tmp/liveness.pid"  #nosec
    else:
        pidfile = "/tmp/readiness.pid"  #nosec
    data = {}
    if os.path.isfile(pidfile):
        with open(pidfile,'r') as f:
            data = json.load(f)
        if check_pid_running(data['pid']):
            if data['exit_count'] > 1:
                # Third time in, kill the previous process
                os.kill(int(data['pid']), signal.SIGTERM)
            else:
                data['exit_count'] = data['exit_count'] + 1
                with open(pidfile, 'w') as f:
                    json.dump(data, f)
                sys.exit(0)
    data['pid'] = os.getpid()
    data['exit_count'] = 0
    with open(pidfile, 'w') as f:
        json.dump(data, f)

    if "sriov_agent.ini" in ','.join(sys.argv):
        sriov_readiness_check()
    elif "metadata_agent.ini" not in ','.join(sys.argv):
        test_rpc_liveness()
    else:
        test_socket_liveness()

    sys.exit(0)  # return success
