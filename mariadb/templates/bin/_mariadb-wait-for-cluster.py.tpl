#!/usr/bin/env python3

import datetime
from enum import Enum
import logging
import os
import sys
import time

import pymysql
import pykube

MARIADB_HOST = os.getenv("MARIADB_HOST")
MARIADB_PASSWORD = os.getenv("MARIADB_PASSWORD")
MARIADB_REPLICAS = os.getenv("MARIADB_REPLICAS")

MARIADB_CLUSTER_STATE_LOG_LEVEL = os.getenv("MARIADB_CLUSTER_STATE_LOG_LEVEL", "INFO")

MARIADB_CLUSTER_STABILITY_COUNT = int(
    os.getenv("MARIADB_CLUSTER_STABILITY_COUNT", "30")
)
MARIADB_CLUSTER_STABILITY_WAIT = int(os.getenv("MARIADB_CLUSTER_STABILITY_WAIT", "4"))
MARIADB_CLUSTER_CHECK_WAIT = int(os.getenv("MARIADB_CLUSTER_CHECK_WAIT", "30"))

MARIADB_CLUSTER_STATE_CONFIGMAP = os.getenv("MARIADB_CLUSTER_STATE_CONFIGMAP")
MARIADB_CLUSTER_STATE_CONFIGMAP_NAMESPACE = os.getenv(
    "MARIADB_CLUSTER_STATE_CONFIGMAP_NAMESPACE", "openstack"
)
MARIADB_CLUSTER_STATE_PYKUBE_REQUEST_TIMEOUT = int(
    os.getenv("MARIADB_CLUSTER_STATE_PYKUBE_REQUEST_TIMEOUT", 60)
)

log_level = MARIADB_CLUSTER_STATE_LOG_LEVEL
logging.basicConfig(
    stream=sys.stdout,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
LOG = logging.getLogger("mariadb-cluster-wait")
LOG.setLevel(log_level)


def login():
    config = pykube.KubeConfig.from_env()
    client = pykube.HTTPClient(
        config=config, timeout=MARIADB_CLUSTER_STATE_PYKUBE_REQUEST_TIMEOUT
    )
    LOG.info(f"Created k8s api client from context {config.current_context}")
    return client


api = login()
cluster_state_map = (
    pykube.ConfigMap.objects(api)
    .filter(namespace=MARIADB_CLUSTER_STATE_CONFIGMAP_NAMESPACE)
    .get_by_name(MARIADB_CLUSTER_STATE_CONFIGMAP)
)


def get_current_state(cluster_state_map):
    cluster_state_map.get(
        MARIADB_CLUSTER_STATE_INITIAL_BOOTSTRAP_COMPLETED_KEY, "False"
    )


def retry(times, exceptions):
    def decorator(func):
        def newfn(*args, **kwargs):
            attempt = 0
            while attempt < times:
                try:
                    return func(*args, **kwargs)
                except exceptions:
                    attempt += 1
                    LOG.exception(
                        f"Exception thrown when attempting to run {func}, attempt {attempt} of {times}"
                    )
            return func(*args, **kwargs)
        return newfn
    return decorator


class initalClusterState:

    initial_state_key = "initial-bootstrap-completed.cluster"

    @retry(times=100, exceptions=(Exception))
    def __init__(self, api, namespace, name):
        self.namespace = namespace
        self.name = name
        self.cm = (
            pykube.ConfigMap.objects(api)
            .filter(namespace=self.namespace)
            .get_by_name(self.name)
        )

    def get_default(self):
        """We have deployments with completed job, but it is not reflected
        in the configmap state. Assume when configmap is created more than
        1h and we doing update/restart, and key not in map this is
        existed environment. So we assume the cluster was initialy bootstrapped.
        This is needed to avoid manual actions.
        """
        now = datetime.datetime.utcnow()
        created_at = datetime.datetime.strptime(
            self.cm.obj["metadata"]["creationTimestamp"], "%Y-%m-%dT%H:%M:%SZ"
        )
        delta = datetime.timedelta(seconds=3600)

        if now - created_at > delta:
            self.complete()
            return "COMPLETED"
        return "NOT_COMPLETED"

    @property
    @retry(times=10, exceptions=(Exception))
    def is_completed(self):

        self.cm.reload()
        if self.initial_state_key in self.cm.obj["data"]:
            return self.cm.obj["data"][self.initial_state_key]

        return self.get_default() == "COMPLETED"

    @retry(times=100, exceptions=(Exception))
    def complete(self):
        patch = {"data": {self.initial_state_key: "COMPLETED"}}
        self.cm.patch(patch)


ics = initalClusterState(
    api, MARIADB_CLUSTER_STATE_CONFIGMAP_NAMESPACE, MARIADB_CLUSTER_STATE_CONFIGMAP
)

if ics.is_completed:
    LOG.info("The initial bootstrap was completed, skipping wait...")
    sys.exit(0)

LOG.info("Checking for mariadb cluster state.")


def is_mariadb_stabe():
    try:
        wsrep_OK = {
            "wsrep_ready": "ON",
            "wsrep_connected": "ON",
            "wsrep_cluster_status": "Primary",
            "wsrep_local_state_comment": "Synced",
            "wsrep_cluster_size": str(MARIADB_REPLICAS),
        }
        wsrep_vars = ",".join(["'" + var + "'" for var in wsrep_OK.keys()])
        db_cursor = pymysql.connect(
            host=MARIADB_HOST, password=MARIADB_PASSWORD,
            read_default_file="/etc/mysql/admin_user.cnf"
        ).cursor()
        db_cursor.execute(f"SHOW GLOBAL STATUS WHERE Variable_name IN ({wsrep_vars})")
        wsrep_vars = db_cursor.fetchall()
        diff = set(wsrep_vars).difference(set(wsrep_OK.items()))
        if diff:
            LOG.error(f"The wsrep is not OK: {diff}")
        else:
            LOG.info("The wspep is ready")
            return True
    except Exception as e:
        LOG.exception(f"Got exception while checking state. {e}")
    return False


count = 0
ready = False
stable_for = 1

while True:
    if is_mariadb_stabe():
        stable_for += 1
        LOG.info(
            f"The cluster is stable for {stable_for} out of {MARIADB_CLUSTER_STABILITY_COUNT}"
        )
        if stable_for == MARIADB_CLUSTER_STABILITY_COUNT:
            ics.complete()
            sys.exit(0)
        else:
            LOG.info(f"Sleeping for {MARIADB_CLUSTER_STABILITY_WAIT}")
            time.sleep(MARIADB_CLUSTER_STABILITY_WAIT)
            continue
    else:
        LOG.info("Resetting stable_for count.")
        stable_for = 0
    LOG.info(f"Sleeping for {MARIADB_CLUSTER_CHECK_WAIT}")
    time.sleep(MARIADB_CLUSTER_CHECK_WAIT)
