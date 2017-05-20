#!/bin/bash
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
set -ex

folder='.'
if [[ $# -gt 0 ]] ; then
  folder="$1";
fi

res=$(find $folder \
      -not -path "*/\.*" \
      -not -path "*/doc/build/*" \
      -not -name "*.tgz" \
      -type f -exec egrep -l " +$" {} \;)

if [[ -z $res ]] ; then
  exit 0
else
  echo 'Trailing space(s) found.'
  exit 1
fi
