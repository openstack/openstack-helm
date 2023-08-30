#!/usr/bin/env python

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Health probe script for OpenStack service that uses RPC/unix domain socket for
communication. Check's the RPC tcp socket status on the process and send
message to service through rpc call method and expects a reply.
Use nova's ping method that is designed just for such simple purpose.

Script returns failure to Kubernetes only when
  a. TCP socket for the RPC communication are not established.
  b. service is not reachable or
  c. service times out sending a reply.

sys.stderr.write() writes to pod's events on failures.

Usage example for Nova Compute:
# python health-probe.py --config-file /etc/nova/nova.conf \
#  --service-queue-name compute

"""

import json
import os
import psutil
import re
import signal
import socket
import sys

from oslo_config import cfg
from oslo_context import context
from oslo_log import log
import oslo_messaging

rpc_timeout = int(os.getenv('RPC_PROBE_TIMEOUT', '60'))
rpc_retries = int(os.getenv('RPC_PROBE_RETRIES', '2'))

tcp_established = "ESTABLISHED"


def _get_hostname(topic, use_fqdn):
    if use_fqdn and topic == "compute":
        return socket.getfqdn()
    return socket.gethostname()


def check_service_status(transport):
    """Verify service status. Return success if service consumes message"""
    try:
        service_queue_name = cfg.CONF.service_queue_name
        use_fqdn = cfg.CONF.use_fqdn
        target = oslo_messaging.Target(
            topic=service_queue_name,
            server=_get_hostname(service_queue_name, use_fqdn),
            namespace='baseapi',
            version="1.1")
        if hasattr(oslo_messaging, 'get_rpc_client'):
            client = oslo_messaging.get_rpc_client(transport, target,
                                                   timeout=rpc_timeout,
                                                   retry=rpc_retries)
        else:
            client = oslo_messaging.RPCClient(transport, target,
                                              timeout=rpc_timeout,
                                              retry=rpc_retries)
        client.call(context.RequestContext(),
                    'ping',
                    arg=None)
    except oslo_messaging.exceptions.MessageDeliveryFailure:
        # Log to pod events
        sys.stderr.write("Health probe unable to reach message bus")
        sys.exit(0)  # return success
    except oslo_messaging.rpc.client.RemoteError as re:
        message = getattr(re, "message", str(re))
        if ("Endpoint does not support RPC method" in message) or \
                ("Endpoint does not support RPC version" in message):
            sys.exit(0)  # Call reached the service
        else:
            sys.stderr.write("Health probe unable to reach service")
            sys.exit(1)  # return failure
    except oslo_messaging.exceptions.MessagingTimeout:
        sys.stderr.write("Health probe timed out. Agent is down or response "
                         "timed out")
        sys.exit(1)  # return failure
    except Exception as ex:
        message = getattr(ex, "message", str(ex))
        sys.stderr.write("Health probe caught exception sending message to "
                         "service: %s" % message)
        sys.exit(0)
    except:
        sys.stderr.write("Health probe caught exception sending message to"
                         " service")
        sys.exit(0)


def tcp_socket_status(process, ports):
    """Check the tcp socket status on a process"""
    for p in psutil.process_iter():
        try:
            with p.oneshot():
                if process in " ".join(p.cmdline()):
                    pcon = p.connections()
                    for con in pcon:
                        try:
                            rport = con.raddr[1]
                            status = con.status
                        except IndexError:
                            continue
                        if rport in ports and status == tcp_established:
                            return 1
        except psutil.Error:
            continue
    return 0


def configured_port_in_conf():
    """Get the rabbitmq/Database port configured in config file"""

    rabbit_ports = set()
    database_ports = set()

    try:
        transport_url = oslo_messaging.TransportURL.parse(cfg.CONF)
        for host in transport_url.hosts:
            rabbit_ports.add(host.port)
    except Exception as ex:
        message = getattr(ex, "message", str(ex))
        sys.stderr.write("Health probe caught exception reading "
                         "RabbitMQ ports: %s" % message)
        sys.exit(0)  # return success

    try:
        with open(sys.argv[2]) as conf_file:
            for line in conf_file:
                if re.match(r'^\s*connection\s*=', line):
                    service = line.split(':', 3)[3].split('/')[1].rstrip('\n')
                    if service == "nova":
                        database_ports.add(
                            int(line.split(':', 3)[3].split('/')[0]))
    except IOError:
        sys.stderr.write("Nova Config file not present")
        sys.exit(1)

    return rabbit_ports, database_ports


def test_tcp_socket(service):
    """Check tcp socket to rabbitmq/db is in Established state"""
    dict_services = {
        "compute": "nova-compute",
        "conductor": "nova-conductor",
        "scheduler": "nova-scheduler"
    }
    r_ports, d_ports = configured_port_in_conf()

    if service in dict_services:
        proc = dict_services[service]
        transport = oslo_messaging.TransportURL.parse(cfg.CONF)
        if r_ports and tcp_socket_status(proc, r_ports) == 0:
            sys.stderr.write("RabbitMQ socket not established for service "
                             "%s with transport %s" % (proc, transport))
            # Do not kill the pod if RabbitMQ is not reachable/down
            if not cfg.CONF.liveness_probe:
                sys.exit(1)

        # let's do the db check
        if service != "compute":
            if d_ports and tcp_socket_status(proc, d_ports) == 0:
                sys.stderr.write("Database socket not established for service "
                                 "%s with transport %s" % (proc, transport))
                # Do not kill the pod if database is not reachable/down
                # there could be no socket as well as typically connections
                # get closed after an idle timeout
                # Just log it to pod events
                if not cfg.CONF.liveness_probe:
                    sys.exit(1)


def test_rpc_liveness():
    """Test if service can consume message from queue"""
    oslo_messaging.set_transport_defaults(control_exchange='nova')

    rabbit_group = cfg.OptGroup(name='oslo_messaging_rabbit',
                                title='RabbitMQ options')
    cfg.CONF.register_group(rabbit_group)
    cfg.CONF.register_cli_opt(cfg.StrOpt('service-queue-name'))
    cfg.CONF.register_cli_opt(cfg.BoolOpt('liveness-probe', default=False,
                                          required=False))
    cfg.CONF.register_cli_opt(cfg.BoolOpt('use-fqdn', default=False,
                                          required=False))

    cfg.CONF(sys.argv[1:])

    log.logging.basicConfig(level=log.{{ .Values.health_probe.logging.level }})

    try:
        transport = oslo_messaging.get_rpc_transport(cfg.CONF)
    except Exception as ex:
        message = getattr(ex, "message", str(ex))
        sys.stderr.write("Message bus driver load error: %s" % message)
        sys.exit(0)  # return success

    if not cfg.CONF.transport_url or \
            not cfg.CONF.service_queue_name:
        sys.stderr.write("Both message bus URL and service's queue name are "
                         "required for health probe to work")
        sys.exit(0)  # return success

    try:
        cfg.CONF.set_override('rabbit_max_retries', 2,
                              group=rabbit_group)  # 3 attempts
    except cfg.NoSuchOptError as ex:
        cfg.CONF.register_opt(cfg.IntOpt('rabbit_max_retries', default=2),
                              group=rabbit_group)

    service = cfg.CONF.service_queue_name
    test_tcp_socket(service)

    check_service_status(transport)

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
            file_content = f.read().strip()
            if file_content:
                data = json.loads(file_content)

    if 'pid' in data and check_pid_running(data['pid']):
        if 'exit_count' in data and data['exit_count'] > 1:
            # Third time in, kill the previous process
            os.kill(int(data['pid']), signal.SIGTERM)
        else:
            data['exit_count'] = data.get('exit_count', 0) + 1
            with open(pidfile, 'w') as f:
                json.dump(data, f)
            sys.exit(0)
    data['pid'] = os.getpid()
    data['exit_count'] = 0
    with open(pidfile, 'w') as f:
        json.dump(data, f)

    test_rpc_liveness()

    sys.exit(0)  # return success
