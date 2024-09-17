#!/usr/bin/env python3

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

See here for explanation:
http://lists.rabbitmq.com/pipermail/rabbitmq-discuss/2011-May/012765.html
*/}}

from __future__ import print_function
import base64
import json
import os
import hashlib
import re

user = os.environ['RABBITMQ_ADMIN_USERNAME']
password = os.environ['RABBITMQ_ADMIN_PASSWORD']
guest_password = os.environ['RABBITMQ_GUEST_PASSWORD']
output_file = os.environ['RABBITMQ_DEFINITION_FILE']

def hash_rabbit_password(password):
    salt = os.urandom(4)
    tmp0 = salt + password.encode('utf-8')
    tmp1 = hashlib.sha512(tmp0).digest()
    salted_hash = salt + tmp1
    pass_hash = base64.b64encode(salted_hash)
    return pass_hash.decode("utf-8")

output = {
    "users": [{
        "name": user,
        "password_hash": hash_rabbit_password(password),
        "hashing_algorithm": "rabbit_password_hashing_sha512",
        "tags": "administrator"
    },
    {
        "name": "guest",
        "password_hash": hash_rabbit_password(guest_password),
        "hashing_algorithm": "rabbit_password_hashing_sha512",
        "tags": "administrator"
    }
    ]
}

if 'RABBITMQ_USERS' in os.environ:
    output.update({'vhosts': []})
    output.update({'permissions': []})
    users_creds = json.loads(os.environ['RABBITMQ_USERS'])
    for user, creds in users_creds.items():
        if 'auth' in creds:
            for auth_key, auth_val in creds['auth'].items():
                username = auth_val['username']
                password = auth_val['password']
                user_struct = {
                    "name": username,
                    "password_hash": hash_rabbit_password(password),
                    "hashing_algorithm": "rabbit_password_hashing_sha512",
                    "tags": ""
                }
                output['users'].append(user_struct)
                if 'path' in creds:
                    for path in (
                        creds["path"]
                        if isinstance(creds["path"], list)
                        else [creds["path"]]
                    ):
                        vhost = re.sub("^/", "", path)
                        vhost_struct = {"name": vhost}

                        perm_struct = {
                            "user": username,
                            "vhost": vhost,
                            "configure": ".*",
                            "write": ".*",
                            "read": ".*"
                        }

                        output['vhosts'].append(vhost_struct)
                        output['permissions'].append(perm_struct)

if 'RABBITMQ_AUXILIARY_CONFIGURATION' in os.environ:
    aux_conf = json.loads(os.environ['RABBITMQ_AUXILIARY_CONFIGURATION'])
    if aux_conf.get('policies', []):
        output['policies'] = aux_conf['policies']
    if aux_conf.get('bindings', []):
        output['bindings'] = aux_conf['bindings']
    if aux_conf.get('queues', []):
        output['queues'] = aux_conf['queues']
    if aux_conf.get('exchanges', []):
        output['exchanges'] = aux_conf['exchanges']

with open(output_file, 'w') as f:
    f.write(json.dumps(output))
    f.close()
