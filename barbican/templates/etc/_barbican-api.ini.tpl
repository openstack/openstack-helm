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

{{ include "barbican.conf.barbican_values_skeleton" .Values.conf.barbican | trunc 0 }}
{{ include "barbican.conf.barbican" .Values.conf.barbican }}

[uwsgi]
socket = :{{ .Values.conf.barbican.barbican_api.barbican.config.bind_port }}
protocol = http
processes = 1
lazy = true
vacuum = true
no-default-app = true
memory-report = true
plugins = python
paste = config:/etc/barbican/barbican-api-paste.ini
add-header = Connection: close
