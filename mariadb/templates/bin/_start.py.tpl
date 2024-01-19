#!/usr/bin/python3

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

import errno
import logging
import os
import secrets
import select
import signal
import subprocess  # nosec
import socket
import sys
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

# Setup secrets generator
secretsGen = secrets.SystemRandom()

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
if check_env_var("PRIMARY_SERVICE_NAME"):
    primary_service_name = os.environ['PRIMARY_SERVICE_NAME']
    logger.info("Will use \"{0}\" service as primary".format(
        primary_service_name))
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
if check_env_var("MARIADB_PORT"):
    mariadb_port = int(os.environ['MARIADB_PORT'])
if check_env_var("MYSQL_DBADMIN_USERNAME"):
    mysql_dbadmin_username = os.environ['MYSQL_DBADMIN_USERNAME']
if check_env_var("MYSQL_DBADMIN_PASSWORD"):
    mysql_dbadmin_password = os.environ['MYSQL_DBADMIN_PASSWORD']
if check_env_var("MYSQL_DBSST_USERNAME"):
    mysql_dbsst_username = os.environ['MYSQL_DBSST_USERNAME']
if check_env_var("MYSQL_DBSST_PASSWORD"):
    mysql_dbsst_password = os.environ['MYSQL_DBSST_PASSWORD']
if check_env_var("MYSQL_DBAUDIT_USERNAME"):
    mysql_dbaudit_username = os.environ['MYSQL_DBAUDIT_USERNAME']
else:
    mysql_dbaudit_username = ''
if check_env_var("MYSQL_DBAUDIT_PASSWORD"):
    mysql_dbaudit_password = os.environ['MYSQL_DBAUDIT_PASSWORD']

mysql_x509 = os.getenv('MARIADB_X509', "")

if mysql_dbadmin_username == mysql_dbsst_username:
    logger.critical(
        "The dbadmin username should not match the sst user username")
    sys.exit(1)

# Set some variables for tuneables
if check_env_var("CLUSTER_LEADER_TTL"):
    cluster_leader_ttl = int(os.environ['CLUSTER_LEADER_TTL'])
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

def ensure_primary_service(pod_namespace, service_name, service_body):
    """Ensure the primary service exists.

    Keyword arguments:
    pod_namespace -- the namespace to house the service
    service_name -- the service name
    service_body -- the service body
    """
    try:
        k8s_api_instance.read_namespaced_service(
            name=service_name, namespace=pod_namespace)
        return True
    except:
        k8s_api_instance.create_namespaced_service(
            namespace=pod_namespace, body=service_body)

        return False



def run_cmd_with_logging(popenargs,
                         logger,
                         stdout_log_level=logging.INFO,
                         stderr_log_level=logging.INFO,
                         **kwargs):
    """Run subprocesses and stream output to logger."""
    child = subprocess.Popen(  # nosec
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

    if not os.path.isfile(mysqld_pidfile_path):
        logger.debug("No previous pid file found for mysqld")
        return
    logger.info("Previous pid file found for mysqld, attempting to shut it down")
    if os.stat(mysqld_pidfile_path).st_size == 0:
        logger.info(
            "{0} file is empty, removing it".format(mysqld_pidfile_path))
        os.remove(mysqld_pidfile_path)
        return
    with open(mysqld_pidfile_path, "r") as mysqld_pidfile:
        mysqld_pid = int(mysqld_pidfile.readlines()[0].rstrip('\n'))
    if not is_pid_running(mysqld_pid):
        logger.info(
            "Mysqld was not running with pid {0}, going to remove stale "
            "file".format(mysqld_pid))
        os.remove(mysqld_pidfile_path)
        return
    if not is_pid_mysqld(mysqld_pid):
        logger.error(
            "pidfile process is not mysqld, removing pidfile and panic")
        os.remove(mysqld_pidfile_path)
        sys.exit(1)

    logger.info("pid from pidfile is mysqld")
    os.kill(mysqld_pid, 15)
    try:
        pid, status = os.waitpid(mysqld_pid, 0)
    except OSError as err:
        # The process has already exited
        if err.errno == errno.ECHILD:
            return
        else:
            raise
    logger.info("Mysqld stopped: pid = {0}, "
                "exit status = {1}".format(pid, status))


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
    """Bootstrap the db if no data found in the 'bootstrap_test_dir'"""
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
        if not mysql_dbaudit_username:
            template = (
                # NOTE: since mariadb 10.4.13 definer of view
                # mysql.user is not root but mariadb.sys user
                # it is safe not to remove it because the account by default
                # is locked and cannot login
                "DELETE FROM mysql.user WHERE user != 'mariadb.sys' ;\n"  # nosec
                "CREATE OR REPLACE USER '{0}'@'%' IDENTIFIED BY \'{1}\' ;\n"
                "GRANT ALL ON *.* TO '{0}'@'%' {4} WITH GRANT OPTION; \n"
                "DROP DATABASE IF EXISTS test ;\n"
                "CREATE OR REPLACE USER '{2}'@'127.0.0.1' IDENTIFIED BY '{3}';\n"
                "GRANT PROCESS, RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '{2}'@'127.0.0.1';\n"
                "FLUSH PRIVILEGES ;\n"
                "SHUTDOWN ;".format(mysql_dbadmin_username, mysql_dbadmin_password,
                                    mysql_dbsst_username, mysql_dbsst_password,
                                    mysql_x509))
        else:
            template = (
                "DELETE FROM mysql.user WHERE user != 'mariadb.sys' ;\n"  # nosec
                "CREATE OR REPLACE USER '{0}'@'%' IDENTIFIED BY \'{1}\' ;\n"
                "GRANT ALL ON *.* TO '{0}'@'%' {6} WITH GRANT OPTION;\n"
                "DROP DATABASE IF EXISTS test ;\n"
                "CREATE OR REPLACE USER '{2}'@'127.0.0.1' IDENTIFIED BY '{3}';\n"
                "GRANT PROCESS, RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '{2}'@'127.0.0.1' ;\n"
                "CREATE OR REPLACE USER '{4}'@'%' IDENTIFIED BY '{5}';\n"
                "GRANT SELECT ON *.* TO '{4}'@'%' {6};\n"
                "FLUSH PRIVILEGES ;\n"
                "SHUTDOWN ;".format(mysql_dbadmin_username, mysql_dbadmin_password,
                                    mysql_dbsst_username, mysql_dbsst_password,
                                    mysql_dbaudit_username, mysql_dbaudit_password,
                                    mysql_x509))
        bootstrap_sql_file = tempfile.NamedTemporaryFile(suffix='.sql').name
        with open(bootstrap_sql_file, 'w') as f:
            f.write(template)
            f.close()
        run_cmd_with_logging([
            'mysqld', '--user=mysql', '--bind-address=127.0.0.1',
            '--wsrep_cluster_address=gcomm://',
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
    # NOTE(portdirect): Explictly set the resource version we are patching to
    # ensure nothing else has modified the confimap since we read it.
    configmap_patch['metadata']['resourceVersion'] = configmap_dict[
        'metadata']['resource_version']

    # Retry up to 8 times in case of 409 only.  Each retry has a ~1 second
    # sleep in between so do not want to exceed the roughly 10 second
    # write interval per cm update.
    for i in range(8):
        try:
            api_response = k8s_api_instance.patch_namespaced_config_map(
                name=state_configmap_name,
                namespace=pod_namespace,
                body=configmap_patch)
            return True
        except kubernetes.client.rest.ApiException as error:
            if error.status == 409:
                # This status code indicates a collision trying to write to the
                # config map while another instance is also trying the same.
                logger.warning("Collision writing configmap: {0}".format(error))
                # This often happens when the replicas were started at the same
                # time, and tends to be persistent. Sleep with some random
                # jitter value briefly to break the synchronization.
                naptime = secretsGen.uniform(0.8,1.2)
                time.sleep(naptime)
            else:
                logger.error("Failed to set configmap: {0}".format(error))
                return error
        logger.info("Retry writing configmap attempt={0} sleep={1}".format(
            i+1, naptime))
    return True

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

def safe_update_service(service_dict, service_patch):
    """Update a service with locking.

    Keyword arguments:
    service_dict -- a dict representing the service to be patched
    service_patch -- a dict containign the patch
    """
    logger.debug("Safe Patching service")
    # NOTE(portdirect): Explictly set the resource version we are patching to
    # ensure nothing else has modified the service since we read it.
    service_patch['metadata']['resourceVersion'] = service_dict[
        'metadata']['resource_version']

    # Retry up to 8 times in case of 409 only.  Each retry has a ~1 second
    # sleep in between so do not want to exceed the roughly 10 second
    # write interval per cm update.
    for i in range(8):
        try:
            api_response = k8s_api_instance.patch_namespaced_service(
                name=primary_service_name,
                namespace=pod_namespace,
                body=service_patch)
            return True
        except kubernetes.client.rest.ApiException as error:
            if error.status == 409:
                # This status code indicates a collision trying to write to the
                # service while another instance is also trying the same.
                logger.warning("Collision writing service: {0}".format(error))
                # This often happens when the replicas were started at the same
                # time, and tends to be persistent. Sleep with some random
                # jitter value briefly to break the synchronization.
                naptime = secretsGen.uniform(0.8,1.2)
                time.sleep(naptime)
            else:
                logger.error("Failed to set service: {0}".format(error))
                return error
        logger.info("Retry writing service attempt={0} sleep={1}".format(
            i+1, naptime))
    return True

def set_primary_service_spec(key, value):
    """Update a service's endpoint via patching.

    Keyword arguments:
    key -- the key to be patched
    value -- the value to give the key
    """
    logger.debug("Setting service spec.selector key={0} to value={1}".format(key, value))
    service_dict = k8s_api_instance.read_namespaced_service(
        name=primary_service_name, namespace=pod_namespace).to_dict()
    service_patch = {'spec': {'selector': {}}, 'metadata': {}}
    service_patch['spec']['selector'][key] = value
    return safe_update_service(
        service_dict=service_dict, service_patch=service_patch)

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
                        leader_expiry,
                        "openstackhelm.openstack.org/reboot.node": ""
                    }
                },
                "data": {}
            }
            ensure_state_configmap(
                pod_namespace=pod_namespace,
                configmap_name=state_configmap_name,
                configmap_body=initial_configmap_body)


            initial_primary_service_body = {
                "apiVersion": "v1",
                "kind": "Service",
                "metadata": {
                    "name": primary_service_name,
                },
                "spec": {
                    "ports": [
                        {
                            "name": "mysql",
                            "port": mariadb_port
                        }
                    ],
                    "selector": {
                        "application": "mariadb",
                        "component": "server",
                        "statefulset.kubernetes.io/pod-name": leader
                    }
                }
            }
            if ensure_primary_service(
                    pod_namespace=pod_namespace,
                    service_name=primary_service_name,
                    service_body=initial_primary_service_body):
                logger.info("Service {0} already exists".format(primary_service_name))
            else:
                logger.info("Service {0} has been successfully created".format(primary_service_name))
    return state


def declare_myself_cluster_leader():
    """Declare the current pod as the cluster leader."""
    logger.info("Declaring myself current cluster leader")
    leader_expiry_raw = datetime.utcnow() + timedelta(
        seconds=cluster_leader_ttl)
    leader_expiry = "{0}Z".format(leader_expiry_raw.isoformat("T"))
    set_configmap_annotation(
        key='openstackhelm.openstack.org/leader.node', value=local_hostname)
    logger.info("Setting primary_service's spec.selector to {0}".format(local_hostname))
    try:
        set_primary_service_spec(
            key='statefulset.kubernetes.io/pod-name', value=local_hostname)
    except:
        initial_primary_service_body = {
            "apiVersion": "v1",
            "kind": "Service",
            "metadata": {
                "name": primary_service_name,
            },
            "spec": {
                "ports": [
                    {
                        "name": "mysql",
                        "port": mariadb_port
                    }
                ],
                "selector": {
                    "application": "mariadb",
                    "component": "server",
                    "statefulset.kubernetes.io/pod-name": local_hostname
                }
            }
        }
        if ensure_primary_service(
                pod_namespace=pod_namespace,
                service_name=primary_service_name,
                service_body=initial_primary_service_body):
            logger.info("Service {0} already exists".format(primary_service_name))
        else:
            logger.info("Service {0} has been successfully created".format(primary_service_name))
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
        declare_myself_cluster_leader()
    elif local_hostname == leader_node:
        logger.info("Renewing cluster leader lease")
        declare_myself_cluster_leader()


def get_grastate_val(key):
    """Extract data from grastate.dat.

    Keyword arguments:
    key -- the key to extract the value of
    """
    logger.debug("Reading grastate.dat key={0}".format(key))
    try:
        # This attempts to address a potential race condition with the initial
        # creation of the grastate.date file where the file would exist
        # however, it is not immediately populated. Testing indicated it could
        # take 15-20 seconds for the file to be populated. So loop and keep
        # checking up to 60 seconds. If it still isn't populated afterwards,
        # the IndexError will still occur as we are seeing now without the loop.
        time_end = time.time() + 60
        while time.time() < time_end:
            with open("/var/lib/mysql/grastate.dat", "r") as myfile:
                grastate_raw = [s.strip() for s in myfile.readlines()]
            if grastate_raw:
                break
            time.sleep(1)
        return [i for i in grastate_raw
                if i.startswith("{0}:".format(key))][0].split(':')[1].strip()
    except IndexError:
        logger.error(
            "IndexError: Unable to find %s with ':' in grastate.dat", key)
        raise


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
    for grastate_key, grastate_value in list(grastate.items()):
        configmap_key = "{0}.{1}".format(grastate_key, local_hostname)
        if get_configmap_value(type='data', key=configmap_key) != grastate_value:
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
                """Extract recovered wsrep position from uncleanly exited node."""
                wsrep_recover = subprocess.Popen(  # nosec
                    [
                        'mysqld', '--bind-address=127.0.0.1',
                        '--wsrep_cluster_address=gcomm://', '--wsrep-recover'
                    ],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    encoding="utf-8")
                out, err = wsrep_recover.communicate()
                wsrep_rec_pos = None
                # NOTE: communicate() returns a tuple (stdout_data, stderr_data).
                # The data will be strings if streams were opened in text mode;
                # otherwise, bytes. If it is bytes, we should decode and get a
                # str for the err.split() to not error below.
                if isinstance(err, bytes):
                    err = err.decode('utf-8')
                for item in err.split("\n"):
                    logger.info("Recovering wsrep position: {0}".format(item))
                    if "WSREP: Recovered position:" in item:
                        line = item.strip().split()
                        wsrep_rec_pos = line[-1].split(':')[-1]
                if wsrep_rec_pos is None:
                    logger.error("WSREP_REC_POS position could not be found.")
                    raise Exception("WSREP_REC_POS position could not be found.")
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
    for key, value in list(state_configmap_dict['data'].items()):
        keyitems = key.split('.')
        key = keyitems[0]
        node = keyitems[1]
        if key == 'sample_time':
            sample_times[node] = value
    sample_time_ok = True
    for key, value in list(sample_times.items()):
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


def get_nodes_with_highest_seqno():
    """Find out which node(s) has the highest sequence number and return
    them in an array."""
    logger.info("Getting the node(s) with highest seqno from configmap.")
    state_configmap = k8s_api_instance.read_namespaced_config_map(
        name=state_configmap_name, namespace=pod_namespace)
    state_configmap_dict = state_configmap.to_dict()
    seqnos = dict()
    for key, value in list(state_configmap_dict['data'].items()):
        keyitems = key.split('.')
        key = keyitems[0]
        node = keyitems[1]
        if key == 'seqno':
            #Explicit casting to integer to have resulting list of integers for correct comparison
            seqnos[node] = int(value)
    max_seqno = max(seqnos.values())
    max_seqno_nodes = sorted([k for k, v in list(seqnos.items()) if v == max_seqno])
    return max_seqno_nodes


def resolve_leader_node(nodename_array):
    """From the given nodename array, determine which node is the leader
    by choosing the node which has a hostname with the lowest number at
    the end of it. If by chance there are two nodes with the same number
    then the first one encountered will be chosen."""
    logger.info("Returning the node with the lowest hostname")
    lowest = sys.maxsize
    leader = nodename_array[0]
    for nodename in nodename_array:
        nodenum = int(nodename[nodename.rindex('-') + 1:])
        logger.info("Nodename %s has nodenum %d", nodename, nodenum)
        if nodenum < lowest:
            lowest = nodenum
            leader = nodename
    logger.info("Resolved leader is %s", leader)
    return leader


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
    max_seqno_nodes = get_nodes_with_highest_seqno()
    leader_node = resolve_leader_node(max_seqno_nodes)
    if (local_hostname == leader_node and not check_for_active_nodes()
            and get_cluster_state() == 'live'):
        logger.info("I lead the cluster. Setting cluster state to reboot.")
        set_configmap_annotation(
            key='openstackhelm.openstack.org/cluster.state', value='reboot')
        set_configmap_annotation(
            key='openstackhelm.openstack.org/reboot.node', value=local_hostname)
        return True
    elif local_hostname == leader_node:
        logger.info("The cluster is already rebooting")
        return False
    else:
        logger.info("{0} leads the cluster".format(leader_node))
        return False


def monitor_cluster():
    """Function to kick off grastate configmap updating thread"""
    while True:
        try:
            update_grastate_configmap()
        except Exception as error:
            logger.error("Error updating grastate configmap: {0}".format(error))
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
        try:
            deadmans_leader_election()
        except Exception as error:
            logger.error("Error electing leader: {0}".format(error))
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
    mysqld_cmd = ['mysqld', '--user=mysql']
    if cluster == 'new':
        mysqld_cmd.append('--wsrep-new-cluster')

    mysql_data_dir = '/var/lib/mysql'
    db_test_dir = "{0}/mysql".format(mysql_data_dir)
    if os.path.isdir(db_test_dir):
        logger.info("Setting the admin passwords to the current value")
        if not mysql_dbaudit_username:
            template = (
                "CREATE OR REPLACE USER '{0}'@'%' IDENTIFIED BY \'{1}\' ;\n"
                "GRANT ALL ON *.* TO '{0}'@'%' {4} WITH GRANT OPTION ;\n"
                "CREATE OR REPLACE USER '{2}'@'127.0.0.1' IDENTIFIED BY '{3}' ;\n"
                "GRANT PROCESS, RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '{2}'@'127.0.0.1' ;\n"
                "FLUSH PRIVILEGES ;\n"
                "SHUTDOWN ;".format(mysql_dbadmin_username, mysql_dbadmin_password,
                                    mysql_dbsst_username, mysql_dbsst_password,
                                    mysql_x509))
        else:
            template = (
                "CREATE OR REPLACE USER '{0}'@'%' IDENTIFIED BY \'{1}\' ;\n"
                "GRANT ALL ON *.* TO '{0}'@'%' {6} WITH GRANT OPTION ;\n"
                "CREATE OR REPLACE USER '{2}'@'127.0.0.1' IDENTIFIED BY '{3}' ;\n"
                "GRANT PROCESS, RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '{2}'@'127.0.0.1' ;\n"
                "CREATE OR REPLACE USER '{4}'@'%' IDENTIFIED BY '{5}' ;\n"
                "GRANT SELECT ON *.* TO '{4}'@'%' {6};\n"
                "FLUSH PRIVILEGES ;\n"
                "SHUTDOWN ;".format(mysql_dbadmin_username, mysql_dbadmin_password,
                                    mysql_dbsst_username, mysql_dbsst_password,
                                    mysql_dbaudit_username, mysql_dbaudit_password,
                                    mysql_x509))
        bootstrap_sql_file = tempfile.NamedTemporaryFile(suffix='.sql').name
        with open(bootstrap_sql_file, 'w') as f:
            f.write(template)
            f.close()
        run_cmd_with_logging([
            'mysqld', '--bind-address=127.0.0.1', '--wsrep-on=false',
            "--init-file={0}".format(bootstrap_sql_file)
        ], logger)
        os.remove(bootstrap_sql_file)
    else:
        logger.info(
            "This is a fresh node joining the cluster for the 1st time, not attempting to set admin passwords"
        )

    # Node ready to start MariaDB, update cluster state to live and remove
    # reboot node info, if set previously.
    if cluster == 'new':
        set_configmap_annotation(
            key='openstackhelm.openstack.org/cluster.state', value='live')
        set_configmap_annotation(
            key='openstackhelm.openstack.org/reboot.node', value='')

    logger.info("Launching MariaDB")
    run_cmd_with_logging(mysqld_cmd, logger)


def mysqld_reboot():
    """Reboot a mysqld cluster."""
    declare_myself_cluster_leader()
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
        declare_myself_cluster_leader()
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
    if not int(mariadb_replicas) > 1:
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
elif get_cluster_state() == 'reboot':
    reboot_node = get_configmap_value(
        type='annotation', key='openstackhelm.openstack.org/reboot.node')
    if reboot_node == local_hostname:
        logger.info(
        "Cluster reboot procedure wasn`t finished. Trying again.")
        update_grastate_on_restart()
        launch_leader_election()
        launch_cluster_monitor()
        mysqld_reboot()
    else:
        logger.info(
            "Waiting for the lead node to come online before joining "
            "it")
        update_grastate_on_restart()
        launch_leader_election()
        launch_cluster_monitor()
        while not check_for_active_nodes():
            time.sleep(default_sleep)
        set_configmap_annotation(
            key='openstackhelm.openstack.org/cluster.state', value='live')
        run_mysqld()
else:
    logger.critical("Dont understand cluster state, exiting with error status")
    sys.exit(1)
