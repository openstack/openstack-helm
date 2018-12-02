#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright 2018 The Openstack-Helm Authors.
#
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

import os
import sys
import re
import logging
import select
import signal
import subprocess
import socket
import tempfile
import time
import threading
from datetime import datetime, timedelta

import configparser
import iso8601
import kubernetes.client
import kubernetes.config

# Create logger, console handler and formatter
logger = logging.getLogger('OpenStack-Helm Mariadb')
logger.setLevel(logging.INFO)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Set the formatter and add the handler
ch.setFormatter(formatter)
logger.addHandler(ch)

# Get the local hostname
local_hostname = socket.gethostname()
logger.info("This instance hostname: {0}".format(local_hostname))

# Get the instance number
instance_number = local_hostname.split("-")[-1]
logger.info("This instance number: {0}".format(instance_number))

# Setup k8s client credentials and check api version
kubernetes.config.load_incluster_config()
kubernetes_version = kubernetes.client.VersionApi().get_code().git_version
logger.info("Kubernetes API Version: {0}".format(kubernetes_version))
k8s_api_instance = kubernetes.client.CoreV1Api()


def check_env_var(env_var):
    """Check if an env var exists.

    Keyword arguments:
    env_var -- the env var to check for the existance of
    """
    if env_var in os.environ:
        return True
    else:
        logger.critical("environment variable \"{0}\" not set".format(env_var))
        sys.exit(1)


# Set some variables from env vars injected into the container
if check_env_var("STATE_CONFIGMAP"):
    state_configmap_name = os.environ['STATE_CONFIGMAP']
    logger.info("Will use \"{0}\" configmap for cluster state info".format(
        state_configmap_name))
if check_env_var("POD_NAMESPACE"):
    pod_namespace = os.environ['POD_NAMESPACE']
if check_env_var("DIRECT_SVC_NAME"):
    direct_svc_name = os.environ['DIRECT_SVC_NAME']
if check_env_var("MARIADB_REPLICAS"):
    mariadb_replicas = os.environ['MARIADB_REPLICAS']
if check_env_var("POD_NAME_PREFIX"):
    pod_name_prefix = os.environ['POD_NAME_PREFIX']
if check_env_var("DISCOVERY_DOMAIN"):
    discovery_domain = os.environ['DISCOVERY_DOMAIN']
if check_env_var("WSREP_PORT"):
    wsrep_port = os.environ['WSREP_PORT']
if check_env_var("MYSQL_ROOT_PASSWORD"):
    mysql_root_password = os.environ['MYSQL_ROOT_PASSWORD']

# Set some variables for tuneables
cluster_leader_ttl = 120
state_configmap_update_period = 10
default_sleep = 20


def ensure_state_configmap(pod_namespace, configmap_name, configmap_body):
    """Ensure the state configmap exists.

    Keyword arguments:
    pod_namespace -- the namespace to house the configmap
    configmap_name -- the configmap name
    configmap_body -- the configmap body
    """
    try:
        k8s_api_instance.read_namespaced_config_map(
            name=configmap_name, namespace=pod_namespace)
        return True
    except:
        k8s_api_instance.create_namespaced_config_map(
            namespace=pod_namespace, body=configmap_body)

        return False


def run_cmd_with_logging(popenargs,
                         logger,
                         stdout_log_level=logging.INFO,
                         stderr_log_level=logging.INFO,
                         **kwargs):
    """Run subprocesses and stream output to logger."""
    child = subprocess.Popen(
        popenargs, stdout=subprocess.PIPE, stderr=subprocess.PIPE, **kwargs)
    log_level = {
        child.stdout: stdout_log_level,
        child.stderr: stderr_log_level
    }

    def check_io():
        ready_to_read = select.select([child.stdout, child.stderr], [], [],
                                      1000)[0]
        for io in ready_to_read:
            line = io.readline()
            logger.log(log_level[io], line[:-1])

    while child.poll(
    ) is None:  # keep checking stdout/stderr until the child exits
        check_io()
    check_io()  # check again to catch anything after the process exits
    return child.wait()


def stop_mysqld():
    """Stop mysqld, assuming pid file in default location."""
    logger.info("Shutting down any mysqld instance if required")
    mysqld_pidfile_path = "/var/lib/mysql/{0}.pid".format(local_hostname)

    def is_pid_running(pid):
        if os.path.isdir('/proc/{0}'.format(pid)):
            return True
        return False

    def is_pid_mysqld(pid):
        with open('/proc/{0}/comm'.format(pid), "r") as mysqld_pidfile:
            comm = mysqld_pidfile.readlines()[0].rstrip('\n')
        if comm.startswith('mysqld'):
            return True
        else:
            return False

    if os.path.isfile(mysqld_pidfile_path):
        logger.info(
            "Previous pid file found for mysqld, attempting to shut it down")
        with open(mysqld_pidfile_path, "r") as mysqld_pidfile:
            mysqld_pid = int(mysqld_pidfile.readlines()[0].rstrip('\n'))
        if is_pid_running(mysqld_pid):
            if is_pid_mysqld(mysqld_pid):
                logger.info("pid from pidfile is mysqld")
                os.kill(mysqld_pid, 15)
                pid, status = os.waitpid(mysqld_pid, 0)
                logger.info("Mysqld stopped: pid = {0}, "
                            "exit status = {1}".format(pid, status))
            else:
                logger.error(
                    "pidfile process is not mysqld, removing pidfile and panic"
                )
                os.remove(mysqld_pidfile_path)
                sys.exit(1)
        else:
            logger.info(
                "Mysqld was not running with pid {0}, going to remove stale "
                "file".format(mysqld_pid))
            os.remove(mysqld_pidfile_path)
    else:
        logger.debug("No previous pid file found for mysqld")


def mysqld_write_cluster_conf(mode='run'):
    """Write out dynamic cluster config.

    Keyword arguments:
    mode -- whether we are writing the cluster config for the cluster to 'run'
            or 'bootstrap' (default 'run')
    """
    logger.info("Setting up cluster config")
    cluster_config = configparser.ConfigParser()
    cluster_config['mysqld'] = {}
    cluster_config_params = cluster_config['mysqld']
    wsrep_cluster_members = []
    for node in range(int(mariadb_replicas)):
        node_hostname = "{0}-{1}".format(pod_name_prefix, node)
        if local_hostname == node_hostname:
            wsrep_node_address = "{0}.{1}:{2}".format(
                node_hostname, discovery_domain, wsrep_port)
            cluster_config_params['wsrep_node_address'] = wsrep_node_address
            wsrep_node_name = "{0}.{1}".format(node_hostname, discovery_domain)
            cluster_config_params['wsrep_node_name'] = wsrep_node_name
        else:
            addr = "{0}.{1}:{2}".format(node_hostname, discovery_domain,
                                        wsrep_port)
            wsrep_cluster_members.append(addr)
    if wsrep_cluster_members and mode == 'run':
        cluster_config_params['wsrep_cluster_address'] = "gcomm://{0}".format(
            ",".join(wsrep_cluster_members))
    else:
        cluster_config_params['wsrep_cluster_address'] = "gcomm://"
    cluster_config_file = '/etc/mysql/conf.d/10-cluster-config.cnf'
    logger.info(
        "Writing out cluster config to: {0}".format(cluster_config_file))
    with open(cluster_config_file, 'w') as configfile:
        cluster_config.write(configfile)


# Function to setup mysqld
def mysqld_bootstrap():
    """Boostrap the db if no data found in the 'bootstrap_test_dir'"""
    logger.info("Boostrapping Mariadb")
    mysql_data_dir = '/var/lib/mysql'
    bootstrap_test_dir = "{0}/mysql".format(mysql_data_dir)
    if not os.path.isdir(bootstrap_test_dir):
        stop_mysqld()
        mysqld_write_cluster_conf(mode='bootstrap')
        run_cmd_with_logging([
            'mysql_install_db', '--user=mysql',
            "--datadir={0}".format(mysql_data_dir)
        ], logger)
        template = (
            "DELETE FROM mysql.user ;\n"
            "CREATE OR REPLACE USER 'root'@'%' IDENTIFIED BY \'{0}\' ;\n"
            "GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;\n"
            "DROP DATABASE IF EXISTS test ;\n"
            "FLUSH PRIVILEGES ;\n"
            "SHUTDOWN ;".format(mysql_root_password))
        bootstrap_sql_file = tempfile.NamedTemporaryFile(suffix='.sql').name
        with open(bootstrap_sql_file, 'w') as f:
            f.write(template)
            f.close()
        run_cmd_with_logging([
            'mysqld', '--bind-address=127.0.0.1',
            "--init-file={0}".format(bootstrap_sql_file)
        ], logger)
        os.remove(bootstrap_sql_file)
    else:
        logger.info("Skipping bootstrap as {0} directory is present".format(
            bootstrap_test_dir))


def safe_update_configmap(configmap_dict, configmap_patch):
    """Update a configmap with locking.

    Keyword arguments:
    configmap_dict -- a dict representing the configmap to be patched
    configmap_patch -- a dict containign the patch
    """
    logger.debug("Safe Patching configmap")
    #NOTE(portdirect): Explictly set the resource version we are patching to
    # ensure nothing else has modified the confimap since we read it.
    configmap_patch['metadata']['resourceVersion'] = configmap_dict[
        'metadata']['resource_version']
    try:
        api_response = k8s_api_instance.patch_namespaced_config_map(
            name=state_configmap_name,
            namespace=pod_namespace,
            body=configmap_patch)
        return True
    except kubernetes.client.rest.ApiException as error:
        logger.error("Failed to set configmap: {0}".format(error))
        return error


def set_configmap_annotation(key, value):
    """Update a configmap's annotations via patching.

    Keyword arguments:
    key -- the key to be patched
    value -- the value to give the key
    """
    logger.debug("Setting configmap annotation key={0} value={1}".format(
        key, value))
    configmap_dict = k8s_api_instance.read_namespaced_config_map(
        name=state_configmap_name, namespace=pod_namespace).to_dict()
    configmap_patch = {'metadata': {'annotations': {}}}
    configmap_patch['metadata']['annotations'][key] = value
    return safe_update_configmap(
        configmap_dict=configmap_dict, configmap_patch=configmap_patch)


def set_configmap_data(key, value):
    """Update a configmap's data via patching.

    Keyword arguments:
    key -- the key to be patched
    value -- the value to give the key
    """
    logger.debug("Setting configmap data key={0} value={1}".format(key, value))
    configmap_dict = k8s_api_instance.read_namespaced_config_map(
        name=state_configmap_name, namespace=pod_namespace).to_dict()
    configmap_patch = {'data': {}, 'metadata': {}}
    configmap_patch['data'][key] = value
    return safe_update_configmap(
        configmap_dict=configmap_dict, configmap_patch=configmap_patch)


def get_configmap_value(key, type='data'):
    """Get a configmap's key's value.

    Keyword arguments:
    key -- the key to retrive the data from
    type -- the type of data to retrive from the configmap, can either be 'data'
            or an 'annotation'. (default data)
    """
    state_configmap = k8s_api_instance.read_namespaced_config_map(
        name=state_configmap_name, namespace=pod_namespace)
    state_configmap_dict = state_configmap.to_dict()
    if type == 'data':
        state_configmap_data = state_configmap_dict['data']
    elif type == 'annotation':
        state_configmap_data = state_configmap_dict['metadata']['annotations']
    else:
        logger.error(
            "Unknown data type \"{0}\" reqested for retrival".format(type))
        return False
    if state_configmap_data and key in state_configmap_data:
        return state_configmap_data[key]
    else:
        return None


def get_cluster_state():
    """Get the current cluster state from a configmap, creating the configmap
    if it does not already exist.
    """
    logger.info("Getting cluster state")
    state = None
    while state is None:
        try:
            state = get_configmap_value(
                type='annotation',
                key='openstackhelm.openstack.org/cluster.state')
            logger.info(
                "The cluster is currently in \"{0}\" state.".format(state))
        except:
            logger.info("The cluster configmap \"{0}\" does not exist.".format(
                state_configmap_name))
            time.sleep(default_sleep)
            leader_expiry_raw = datetime.utcnow() + timedelta(
                seconds=cluster_leader_ttl)
            leader_expiry = "{0}Z".format(leader_expiry_raw.isoformat("T"))
            if check_for_active_nodes():
                # NOTE(portdirect): here we make the assumption that the 1st pod
                # in an existing statefulset is the one to adopt as leader.
                leader = "{0}-0".format("-".join(
                    local_hostname.split("-")[:-1]))
                state = "live"
                logger.info(
                    "The cluster is running already though unmanaged \"{0}\" will be declared leader in a \"{1}\" state".
                    format(leader, state))
            else:
                leader = local_hostname
                state = "new"
                logger.info(
                    "The cluster is new \"{0}\" will be declared leader in a \"{1}\" state".
                    format(leader, state))

            initial_configmap_body = {
                "apiVersion": "v1",
                "kind": "ConfigMap",
                "metadata": {
                    "name": state_configmap_name,
                    "annotations": {
                        "openstackhelm.openstack.org/cluster.state": state,
                        "openstackhelm.openstack.org/leader.node": leader,
                        "openstackhelm.openstack.org/leader.expiry":
                        leader_expiry
                    }
                },
                "data": {}
            }
            ensure_state_configmap(
                pod_namespace=pod_namespace,
                configmap_name=state_configmap_name,
                configmap_body=initial_configmap_body)
    return state


def declare_myself_cluser_leader():
    """Declare the current pod as the cluster leader."""
    logger.info("Declaring myself current cluster leader")
    leader_expiry_raw = datetime.utcnow() + timedelta(
        seconds=cluster_leader_ttl)
    leader_expiry = "{0}Z".format(leader_expiry_raw.isoformat("T"))
    set_configmap_annotation(
        key='openstackhelm.openstack.org/leader.node', value=local_hostname)
    set_configmap_annotation(
        key='openstackhelm.openstack.org/leader.expiry', value=leader_expiry)


def deadmans_leader_election():
    """Run a simplisic deadmans leader election."""
    leader_node = get_configmap_value(
        type='annotation', key='openstackhelm.openstack.org/leader.node')
    leader_expiry = get_configmap_value(
        type='annotation', key='openstackhelm.openstack.org/leader.expiry')
    if iso8601.parse_date(leader_expiry).replace(
            tzinfo=None) < datetime.utcnow().replace(tzinfo=None):
        logger.info("Current cluster leader has expired")
        declare_myself_cluser_leader()
    elif local_hostname == leader_node:
        logger.info("Renewing cluster leader lease")
        declare_myself_cluser_leader()


def get_grastate_val(key):
    """Extract data from grastate.dat.

    Keyword arguments:
    key -- the key to extract the value of
    """
    logger.debug("Reading grastate.dat key={0}".format(key))
    with open("/var/lib/mysql/grastate.dat", "r") as myfile:
        grastate_raw = map(lambda s: s.strip(), myfile.readlines())
    return [i for i in grastate_raw
            if i.startswith("{0}:".format(key))][0].split(':')[1].strip()


def set_grastate_val(key, value):
    """Set values in grastate.dat.

    Keyword arguments:
    key -- the key to set the value of
    value -- the value to set the key to
    """
    logger.debug("Updating grastate.dat key={0} value={1}".format(key, value))
    with open("/var/lib/mysql/grastate.dat", "r") as sources:
        lines = sources.readlines()
        for line_num, line_content in enumerate(lines):
            if line_content.startswith("{0}:".format(key)):
                line_content = "{0}: {1}\n".format(key, value)
            lines[line_num] = line_content
    with open("/var/lib/mysql/grastate.dat", "w") as sources:
        for line in lines:
            sources.write(line)


def update_grastate_configmap():
    """Update state configmap with grastate.dat info."""
    while not os.path.exists('/var/lib/mysql/grastate.dat'):
        time.sleep(1)
    logger.info("Updating grastate configmap")
    grastate = dict()
    grastate['version'] = get_grastate_val(key='version')
    grastate['uuid'] = get_grastate_val(key='uuid')
    grastate['seqno'] = get_grastate_val(key='seqno')
    grastate['safe_to_bootstrap'] = get_grastate_val(key='safe_to_bootstrap')
    grastate['sample_time'] = "{0}Z".format(datetime.utcnow().isoformat("T"))
    for grastate_key, grastate_value in grastate.iteritems():
        configmap_key = "{0}.{1}".format(grastate_key, local_hostname)
        if get_configmap_value(
                type='data', key=configmap_key) != grastate_value:
            set_configmap_data(key=configmap_key, value=grastate_value)


def update_grastate_on_restart():
    """Update the grastate.dat on node restart."""
    logger.info("Updating grastate info for node")
    if os.path.exists('/var/lib/mysql/grastate.dat'):
        if get_grastate_val(key='seqno') == '-1':
            logger.info(
                "Node shutdown was not clean, getting position via wsrep-recover"
            )

            def recover_wsrep_position():
                """Extract recoved wsrep position from uncleanly exited node."""
                wsrep_recover = subprocess.Popen(
                    [
                        'mysqld', '--bind-address=127.0.0.1',
                        '--wsrep_cluster_address=gcomm://', '--wsrep-recover'
                    ],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE)
                out, err = wsrep_recover.communicate()
                for item in err.split("\n"):
                    if "WSREP: Recovered position:" in item:
                        line = item.strip().split()
                        wsrep_rec_pos = line[-1].split(':')[-1]
                return wsrep_rec_pos

            set_grastate_val(key='seqno', value=recover_wsrep_position())
        else:
            logger.info("Node shutdown was clean, using grastate.dat")

        update_grastate_configmap()

    else:
        logger.info("No grastate.dat exists I am a new node")


def get_active_endpoints(endpoints_name=direct_svc_name,
                         namespace=pod_namespace):
    """Returns a list of active endpoints.

    Keyword arguments:
    endpoints_name -- endpoints to check for active backends
                      (default direct_svc_name)
    namespace -- namespace to check for endpoints (default pod_namespace)
    """
    endpoints = k8s_api_instance.read_namespaced_endpoints(
        name=endpoints_name, namespace=pod_namespace)
    endpoints_dict = endpoints.to_dict()
    addresses_index = [
        i for i, s in enumerate(endpoints_dict['subsets']) if 'addresses' in s
    ][0]
    active_endpoints = endpoints_dict['subsets'][addresses_index]['addresses']
    return active_endpoints


def check_for_active_nodes(endpoints_name=direct_svc_name,
                           namespace=pod_namespace):
    """Check K8s endpoints to see if there are active Mariadb Instances.

    Keyword arguments:
    endpoints_name -- endpoints to check for active backends
                      (default direct_svc_name)
    namespace -- namespace to check for endpoints (default pod_namespace)
    """
    logger.info("Checking for active nodes")
    active_endpoints = get_active_endpoints()
    if active_endpoints and len(active_endpoints) >= 1:
        return True
    else:
        return False


def check_if_cluster_data_is_fresh():
    """Check if the state_configmap is both current and reasonably stable."""
    logger.info("Checking to see if cluster data is fresh")
    state_configmap = k8s_api_instance.read_namespaced_config_map(
        name=state_configmap_name, namespace=pod_namespace)
    state_configmap_dict = state_configmap.to_dict()
    sample_times = dict()
    for key, value in state_configmap_dict['data'].iteritems():
        keyitems = key.split('.')
        key = keyitems[0]
        node = keyitems[1]
        if key == 'sample_time':
            sample_times[node] = value
    sample_time_ok = True
    for key, value in sample_times.iteritems():
        sample_time = iso8601.parse_date(value).replace(tzinfo=None)
        sample_cutoff_time = datetime.utcnow().replace(
            tzinfo=None) - timedelta(seconds=20)
        if not sample_time >= sample_cutoff_time:
            logger.info(
                "The data we have from the cluster is too old to make a "
                "decision for node {0}".format(key))
            sample_time_ok = False
        else:
            logger.info(
                "The data we have from the cluster is ok for node {0}".format(
                    key))
    return sample_time_ok


def check_if_i_lead():
    """Check on full restart of cluster if this node should lead the cluster
    reformation."""
    logger.info("Checking to see if I lead the cluster for reboot")
    # as we sample on the update period - we sample for a full cluster
    # leader election period as a simplistic way of ensureing nodes are
    # reliably checking in following full restart of cluster.
    count = cluster_leader_ttl / state_configmap_update_period
    counter = 0
    while counter <= count:
        if check_if_cluster_data_is_fresh():
            counter += 1
        else:
            counter = 0
        time.sleep(state_configmap_update_period)
        logger.info(
            "Cluster info has been uptodate {0} times out of the required "
            "{1}".format(counter, count))
    state_configmap = k8s_api_instance.read_namespaced_config_map(
        name=state_configmap_name, namespace=pod_namespace)
    state_configmap_dict = state_configmap.to_dict()
    seqnos = dict()
    for key, value in state_configmap_dict['data'].iteritems():
        keyitems = key.split('.')
        key = keyitems[0]
        node = keyitems[1]
        if key == 'seqno':
            seqnos[node] = value
    max_seqno = max(seqnos.values())
    max_seqno_node = sorted(
        [k for k, v in seqnos.items() if v == max_seqno])[0]
    if local_hostname == max_seqno_node:
        logger.info("I lead the cluster")
        return True
    else:
        logger.info("{0} leads the cluster".format(max_seqno_node))
        return False


def monitor_cluster():
    """Function to kick off grastate configmap updating thread"""
    while True:
        update_grastate_configmap()
        time.sleep(state_configmap_update_period)


# Setup the thread for the cluster monitor
monitor_cluster_thread = threading.Thread(target=monitor_cluster, args=())
monitor_cluster_thread.daemon = True


def launch_cluster_monitor():
    """Launch grastate configmap updating thread"""
    if not monitor_cluster_thread.isAlive():
        monitor_cluster_thread.start()


def leader_election():
    """Function to kick off leader election thread"""
    while True:
        deadmans_leader_election()
        time.sleep(cluster_leader_ttl / 2)


# Setup the thread for the leader election
leader_election_thread = threading.Thread(target=leader_election, args=())
leader_election_thread.daemon = True


def launch_leader_election():
    """Launch leader election thread"""
    if not leader_election_thread.isAlive():
        leader_election_thread.start()


def run_mysqld(cluster='existing'):
    """Launch the mysqld instance for the pod. This will also run mysql upgrade
    if we are the 1st replica, and the rest of the cluster is already running.
    This senario will be triggerd either following a rolling update, as this
    works in reverse order for statefulset. Or restart of the 1st instance, in
    which case the comand should be a no-op.

    Keyword arguments:
    cluster -- whether we going to form a cluster 'new' or joining an existing
               cluster 'existing' (default 'existing')
    """
    stop_mysqld()
    mysqld_write_cluster_conf(mode='run')
    launch_leader_election()
    launch_cluster_monitor()
    mysqld_cmd = ['mysqld']
    if cluster == 'new':
        mysqld_cmd.append('--wsrep-new-cluster')
    else:
        if int(instance_number) == 0:
            active_endpoints = get_active_endpoints()
            if active_endpoints and len(active_endpoints) == (
                    int(mariadb_replicas) - 1):
                run_cmd_with_logging([
                    'mysql_upgrade',
                    '--defaults-file=/etc/mysql/admin_user.cnf'
                ], logger)

    run_cmd_with_logging(mysqld_cmd, logger)


def mysqld_reboot():
    """Reboot a mysqld cluster."""
    declare_myself_cluser_leader()
    set_grastate_val(key='safe_to_bootstrap', value='1')
    run_mysqld(cluster='new')


def sigterm_shutdown(x, y):
    """Shutdown the instance of mysqld on shutdown signal."""
    logger.info("Got a sigterm from the container runtime, time to go.")
    stop_mysqld()


# Register the signal to the handler
signal.signal(signal.SIGTERM, sigterm_shutdown)

# Main logic loop
if get_cluster_state() == 'new':
    leader_node = get_configmap_value(
        type='annotation', key='openstackhelm.openstack.org/leader.node')
    if leader_node == local_hostname:
        set_configmap_annotation(
            key='openstackhelm.openstack.org/cluster.state', value='init')
        declare_myself_cluser_leader()
        launch_leader_election()
        mysqld_bootstrap()
        update_grastate_configmap()
        set_configmap_annotation(
            key='openstackhelm.openstack.org/cluster.state', value='live')
        run_mysqld(cluster='new')
    else:
        logger.info("Waiting for cluster to start running")
        while not get_cluster_state() == 'live':
            time.sleep(default_sleep)
        while not check_for_active_nodes():
            time.sleep(default_sleep)
        launch_leader_election()
        run_mysqld()
elif get_cluster_state() == 'init':
    logger.info("Waiting for cluster to start running")
    while not get_cluster_state() == 'live':
        time.sleep(default_sleep)
    while not check_for_active_nodes():
        time.sleep(default_sleep)
    launch_leader_election()
    run_mysqld()
elif get_cluster_state() == 'live':
    logger.info("Cluster has been running starting restore/rejoin")
    if not mariadb_replicas > 1:
        logger.info(
            "There is only a single node in this cluster, we are good to go")
        update_grastate_on_restart()
        mysqld_reboot()
    else:
        if check_for_active_nodes():
            logger.info(
                "There are currently running nodes in the cluster, we can "
                "join them")
            run_mysqld()
        else:
            logger.info("This cluster has lost all running nodes, we need to "
                        "determine the new lead node")
            update_grastate_on_restart()
            launch_leader_election()
            launch_cluster_monitor()
            if check_if_i_lead():
                logger.info("I won the ability to reboot the cluster")
                mysqld_reboot()
            else:
                logger.info(
                    "Waiting for the lead node to come online before joining "
                    "it")
                while not check_for_active_nodes():
                    time.sleep(default_sleep)
                run_mysqld()
else:
    logger.critical("Dont understand cluster state, exiting with error status")
    sys.exit(1)
