# Copyright 2017 The Openstack-Helm Authors.
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

[mysqld]
bind_address=0.0.0.0
port={{ .Values.network.port.mariadb }}

# When a client connects, the server will perform hostname resolution,
# and when DNS is slow, establishing the connection will become slow as well.
# It is therefore recommended to start the server with skip-name-resolve to
# disable all DNS lookups. The only limitation is that the GRANT statements
# must then use IP addresses only.
skip_name_resolve

[client]
protocol=tcp
port={{ .Values.network.port.mariadb }}
