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
slow_query_log=off
slow_query_log_file=/var/log/mysql/mariadb-slow.log
log_warnings=2

# General logging has huge performance penalty therefore is disabled by default
general_log=off
general_log_file=/var/log/mysql/mariadb-error.log

long_query_time=3
log_queries_not_using_indexes=on
