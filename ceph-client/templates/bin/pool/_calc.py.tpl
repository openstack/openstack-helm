#!/usr/bin/python
# -*- coding: utf-8 -*-

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

#NOTE(portdirect): this is a simple approximation of https://ceph.com/pgcalc/

import math
import sys

replication = int(sys.argv[1])
number_of_osds = int(sys.argv[2])
percentage_data = float(sys.argv[3])
target_pgs_per_osd = int(sys.argv[4])

raw_pg_num_opt = target_pgs_per_osd * number_of_osds \
    * (math.ceil(percentage_data) / 100.0) / replication

raw_pg_num_min = number_of_osds / replication

if raw_pg_num_min >= raw_pg_num_opt:
    raw_pg_num = raw_pg_num_min
else:
    raw_pg_num = raw_pg_num_opt

max_pg_num = int(math.pow(2, math.ceil(math.log(raw_pg_num, 2))))
min_pg_num = int(math.pow(2, math.floor(math.log(raw_pg_num, 2))))

if min_pg_num >= (raw_pg_num * 0.75):
    print(min_pg_num)
else:
    print(max_pg_num)
