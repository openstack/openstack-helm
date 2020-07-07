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
import struct

user = os.environ['RABBITMQ_ADMIN_USERNAME']
password = os.environ['RABBITMQ_ADMIN_PASSWORD']
output_file = os.environ['RABBITMQ_DEFINITION_FILE']

salt = os.urandom(4)

tmp0 = salt + password.encode('utf-8')

tmp1 = hashlib.sha512(tmp0).digest()

salted_hash = salt + tmp1

pass_hash = base64.b64encode(salted_hash)

output = {
    "users": [{
        "name": user,
        "password_hash": pass_hash.decode("utf-8"),
        "hashing_algorithm": "rabbit_password_hashing_sha512",
        "tags": "administrator"
    }]
}
with open(output_file, 'w') as f:
    f.write(json.dumps(output))
    f.close()
