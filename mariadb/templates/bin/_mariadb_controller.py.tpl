#!/usr/bin/env python3

"""
Mariadb controller

The script is responsible for set mariadb_role: primary to first
active pod in mariadb deployment.

Env variables:
MARIADB_CONTROLLER_DEBUG: Flag to enable debug when set to 1.
MARIADB_CONTROLLER_CHECK_PODS_DELAY: The delay between check pod attempts.
MARIADB_CONTROLLER_PYKUBE_REQUEST_TIMEOUT: The timeout for kubernetes http session
MARIADB_CONTROLLER_PODS_NAMESPACE: The namespace to look for mariadb pods.
MARIADB_MASTER_SERVICE_NAME: The name of master service for mariadb.
MARIADB_MASTER_SERVICE_SELECTOR: The labels of the mariadb server pods as a
    JSON object. The master service's selector is set to these plus the pod
    name of the elected primary.

Changelog:
0.1.0: Initial varsion
0.1.1: Own the whole selector of the master service
0.1.2: Keep the current primary while it is ready
0.1.3: Retry a failed check instead of exiting
"""


import json
import logging
import os
import sys
import time

import pykube

MARIADB_CONTROLLER_DEBUG = os.getenv("MARIADB_CONTROLLER_DEBUG")
MARIADB_CONTROLLER_CHECK_PODS_DELAY = int(
    os.getenv("MARIADB_CONTROLLER_CHECK_PODS_DELAY", 10)
)
MARIADB_CONTROLLER_PYKUBE_REQUEST_TIMEOUT = int(
    os.getenv("MARIADB_CONTROLLER_PYKUBE_REQUEST_TIMEOUT", 60)
)
MARIADB_CONTROLLER_PODS_NAMESPACE = os.getenv(
    "MARIADB_CONTROLLER_PODS_NAMESPACE", "openstack"
)
MARIADB_MASTER_SERVICE_NAME = os.getenv(
    "MARIADB_MASTER_SERVICE_NAME", "mariadb"
)
MARIADB_MASTER_SERVICE_SELECTOR = json.loads(
    os.getenv(
        "MARIADB_MASTER_SERVICE_SELECTOR",
        '{"application": "mariadb", "component": "server"}',
    )
)
POD_NAME_LABEL = "statefulset.kubernetes.io/pod-name"

log_level = "DEBUG" if MARIADB_CONTROLLER_DEBUG == "1" else "INFO"
logging.basicConfig(
    stream=sys.stdout,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
LOG = logging.getLogger("mariadb-controller")

LOG.setLevel(log_level)


def login():
    config = pykube.KubeConfig.from_env()
    client = pykube.HTTPClient(
        config=config, timeout=MARIADB_CONTROLLER_PYKUBE_REQUEST_TIMEOUT
    )
    LOG.info(f"Created k8s api client from context {config.current_context}")
    return client


api = login()


def resource_list(klass, selector, namespace=None):
    return klass.objects(api).filter(namespace=namespace, selector=selector)


def get_mariadb_pods():
    sorted_pods = sorted(
        resource_list(
            pykube.Pod,
            {"application": "mariadb", "component": "server"},
            MARIADB_CONTROLLER_PODS_NAMESPACE,
        ).iterator(),
        key=lambda i: i.name,
    )
    return sorted_pods


def get_mariadb_master_service(namespace):
    return pykube.Service.objects(api).filter(namespace=namespace).get(name=MARIADB_MASTER_SERVICE_NAME)


def link_master_service(pod):
    # The chart renders the service without a selector and leaves all of it
    # to this controller: a Service selector is an atomic map, so one key
    # added to a selector Helm applies server-side would conflict with every
    # upgrade. Until the first link the service has no endpoints.
    svc = get_mariadb_master_service(MARIADB_CONTROLLER_PODS_NAMESPACE)
    svc.reload()
    selector = dict(MARIADB_MASTER_SERVICE_SELECTOR)
    selector[POD_NAME_LABEL] = pod.name
    current = svc.obj["spec"].get("selector") or {}
    if current == selector:
        LOG.debug(f"Nothing to do, master service points to {pod.name}")
    else:
        # A merge patch keeps every key it does not mention, so a label
        # dropped from the chart has to be removed explicitly with null.
        removed = {key: None for key in current if key not in selector}
        svc.patch({"spec": {"selector": dict(removed, **selector)}})
        LOG.info(f"Link master service with {pod.name}")


def is_ready(pod):
    if pod.ready and "deletionTimestamp" not in pod.metadata:
        return True


def main():
    while True:
        # Retry on the next check rather than exit, so the controller is
        # back as soon as the API is, not after a CrashLoopBackOff delay.
        try:
            ready = [pod for pod in get_mariadb_pods() if is_ready(pod)]
            if ready:
                svc = get_mariadb_master_service(MARIADB_CONTROLLER_PODS_NAMESPACE)
                current = (svc.obj["spec"].get("selector") or {}).get(POD_NAME_LABEL)
                # Keep the current primary while it is ready, so a recovered pod
                # does not take the service back and drop connections twice.
                pod = next((p for p in ready if p.name == current), ready[0])
                link_master_service(pod)
        except Exception as error:
            LOG.exception(f"Check failed, retrying: {error}")
        LOG.debug(f"Sleeping for {MARIADB_CONTROLLER_CHECK_PODS_DELAY}")
        time.sleep(MARIADB_CONTROLLER_CHECK_PODS_DELAY)


main()
