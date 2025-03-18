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

# NOTE(sw5822): Redirect no-op operator output to Nagios log file to clean out
# Nagios's log file, since Nagios doesn't support logging to /dev/null
: > /opt/nagios/var/log/nagios.log

# Check whether Nagios endpoint is reachable
reply=$(curl -s -o /dev/null -w %{http_code} http://127.0.0.1:8000/nagios)
if [ \"$reply\" -lt 200 -o \"$reply\" -ge 400 ]; then
  exit 1
fi
