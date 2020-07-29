#!/usr/bin/python
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

import json
import os
import requests
import sys

def main(args):
    base_url, token, domainId, domainName, filename = args[1], args[2], args[3], args[4], args[5]
    url = "%s/domains/%s/config" % (base_url, domainId)
    print("Connecting to url: %r" % url)

    headers = {
        'Content-Type': "application/json",
        'X-Auth-Token': token,
        'Cache-Control': "no-cache"
    }

    verify = os.getenv('OS_CACERT', True)

    response = requests.request("GET", url, headers=headers, verify=verify)

    if response.status_code == 404:
        print("domain config not found - put")
        action = "PUT"
    else:
        print("domain config found - patch")
        action = "PATCH"

    with open(filename, "rb") as f:
        data = {"config": json.load(f)}

    response = requests.request(action, url,
                                data=json.dumps(data),
                                headers=headers, verify=verify)


    print("Response code on action [%s]: %s" % (action, response.status_code))
    # Put and Patch can return 200 or 201. If it is not a 2XX code, error out.
    if (response.status_code // 100) != 2:
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 6:
        sys.exit(1)
    main(sys.argv)
