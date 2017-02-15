#! /usr/bin/env python
# vim: tabstop=4 shiftwidth=4 softtabstop=4

# All Rights Reserved.
#
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

"""
Usage

$ cat /tmp/globals.yaml
global:
  neener: teener

ceph:
  foo: bar
  coo: zoo
  foo:
    hoo: woo

keystone:
  goo: baz

---

$ ./values.py -y /tmp/globals.yaml
2016-12-14 13:02:31,950 values       INFO     Processing YAML file /tmp/globals.yaml
2016-12-14 13:02:31,951 values       INFO     Writing out /tmp/helmVccaOA/ceph.yaml
2016-12-14 13:02:31,952 values       INFO     Writing out /tmp/helmVccaOA/keystone.yaml

$ cat /tmp/helmVccaOA/ceph.yaml
global:
  neener: teener
coo: zoo
foo:
  hoo: woo

$ cat /tmp/helmVccaOA/keystone.yaml
global:
  neener: teener
goo: baz

---

$ helm install --values=/tmp/helmVccaOA/ceph.yaml ./ceph-0.1.0.tgz --namespace=ceph

"""

import yaml
import tempfile
import sys
import os
import logging
import argparse
from logging.handlers import SysLogHandler

LOG = logging.getLogger('values')
LOG_FORMAT='%(asctime)s %(name)-12s %(levelname)-8s %(message)s'
LOG_DATE = '%m-%d %H:%M'
DESCRIPTION = "Values Generator"

# special top level parameters
# we will copy to all configs
COPY_LIST=['global']

def parse_args():

    ap = argparse.ArgumentParser(description=DESCRIPTION)
    ap.add_argument('-d', '--debug', action='store_true',
                    default=False, help='Enable debugging')
    ap.add_argument('-y', '--yaml', action='store',
                    required=True, help='Path to Master YAML File')
    return ap.parse_args()


def setup_logging(args):
    level = logging.DEBUG if args.debug else logging.INFO
    logging.basicConfig(level=level, format=LOG_FORMAT, date_fmt=LOG_DATE)
    handler = SysLogHandler(address='/dev/log')
    syslog_formatter = logging.Formatter('%(name)s: %(levelname)s %(message)s')
    handler.setFormatter(syslog_formatter)
    LOG.addHandler(handler)


def is_path_creatable(pathname):
    '''
    `True` if the current user has sufficient permissions to create the passed
    pathname; `False` otherwise.
    '''
    # Parent directory of the passed path. If empty, we substitute the current
    # working directory (CWD) instead.
    dirname = os.path.dirname(pathname) or os.getcwd()
    return os.access(dirname, os.W_OK)


def process_yaml(yaml_path):
    '''
    Processes YAML file and generates breakdown of top level
    keys
    '''

    # perform some basic validation
    if not os.path.isfile(yaml_path):
        LOG.exception("The path %s does not point to a valid file", yaml_path)
        sys.exit(1)

    tmp_dir = tempfile.mkdtemp(prefix='helm', dir='/tmp')

    yamldata = yaml.load(open(yaml_path).read())
    for top_level in yamldata.keys():
        if top_level in COPY_LIST:
            continue
        top_level_path = os.path.join(tmp_dir, top_level + '.yaml')
        if is_path_creatable(top_level_path):

            with open(top_level_path, 'w') as f:
                LOG.info("Writing out %s", top_level_path)
                for item in COPY_LIST:
                    if item in yamldata.keys():
                        f.write(yaml.dump({item: yamldata[item]}, default_flow_style=False))
                f.write(yaml.dump(yamldata[top_level], default_flow_style=False))

        else:
            LOG.exception("Unable to create path %s based on top level key in %s" % (top_level_path, yaml_path))


def run(args):

    LOG.info("Processing YAML file %s", args.yaml)
    process_yaml(args.yaml)


if __name__ == '__main__':

    args = parse_args()
    setup_logging(args)

    try:
        run(args)
        sys.exit(0)
    except Exception as err:
        LOG.exception(err)
        sys.exit(1)

