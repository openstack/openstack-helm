#!/bin/bash

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

{{/*
This test talks to the HTTP management API directly rather than through
rabbitmqadmin.

The RabbitMQ 4.x management image ships rabbitmqadmin v2, whose command grammar
differs from the python v1 tool, which dropped JSON output for arbitrary
commands, and which is absent altogether on architectures it has no binary for.
The image also carries no python interpreter. Every one of those broke the
previous version of this script. The management API is the interface all of
those tools are clients of, and it is stable across broker versions, so the test
uses it and needs nothing from the image beyond python3.
*/}}

set -e

python3 <<'PYTHON'
import base64
import json
import os
import ssl
import sys
import urllib.error
import urllib.parse
import urllib.request

CERT_DIR = "/etc/rabbitmq/certs"

connection = os.environ["RABBITMQ_ADMIN_CONNECTION"]
expected_nodes = int(os.environ["RABBIT_REPLICA_COUNT"])

parsed = urllib.parse.urlsplit(connection)
scheme = "https" if parsed.scheme in ("https", "rabbits") else "http"
base = f"{scheme}://{parsed.hostname}:{parsed.port}"
username = urllib.parse.unquote(parsed.username or "")
password = urllib.parse.unquote(parsed.password or "")

context = None
if scheme == "https":
    ca_file = os.path.join(CERT_DIR, "ca.crt")
    context = ssl.create_default_context(
        cafile=ca_file if os.path.exists(ca_file) else None
    )
    # The server certificate is issued for the service name rather than for
    # whatever host the endpoint lookup produced, which is why the previous
    # script passed --ssl-disable-hostname-verification. The chain is still
    # verified.
    context.check_hostname = False

header = base64.b64encode(f"{username}:{password}".encode()).decode("ascii")


def api(path):
    request = urllib.request.Request(base + path, method="GET")
    request.add_header("Authorization", "Basic " + header)
    request.add_header("Accept", "application/json")
    try:
        with urllib.request.urlopen(request, timeout=30, context=context) as response:
            return json.loads(response.read())
    except urllib.error.HTTPError as error:
        sys.exit(f"GET {path} failed: HTTP {error.code} {error.reason}")
    except urllib.error.URLError as error:
        sys.exit(f"GET {path} failed: {error.reason}")


failures = []

print(f"Querying the management API at {base}")
nodes = api("/api/nodes")
names = sorted(node["name"] for node in nodes)
print(f"Found {len(names)} nodes: {' '.join(names)}")

print("Checking node count")
if len(names) != expected_nodes:
    failures.append(
        f"number of nodes in cluster ({len(names)}) does not match the number "
        f"of desired pods ({expected_nodes})"
    )
else:
    print(f"Number of nodes in cluster ({len(names)}) matches the desired pods")

print("Checking cluster partitions")
for node in nodes:
    if "partitions" not in node:
        failures.append(f"partitions key not reported for node {node['name']}")
        continue
    if node["partitions"]:
        failures.append(
            f"cluster partition found on {node['name']}: {node['partitions']}"
        )
if not failures:
    print("No cluster partitions found")

# One read per node, matching what the previous script did. Note that the
# endpoint is the load balanced service, so this establishes that every read
# returns the same set rather than that a named node holds it.
print("Checking the user list is consistent across reads")
seen = set()
for name in names:
    users = sorted(user["name"] for user in api("/api/users"))
    print(f"  via {name}: {' '.join(users)}")
    seen.add(tuple(users))
if len(seen) > 1:
    failures.append(f"user lists differ between reads: {seen}")
else:
    print("User lists match")

if failures:
    for failure in failures:
        print(f"FAILED: {failure}")
    sys.exit(1)
print("RabbitMQ cluster checks passed")
PYTHON
