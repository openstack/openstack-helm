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

set -ex

# FIXME: Add db sync executable endpoint to skyline-apiserver package and use it here
site_packages_dir=$(python -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')
alembic -c ${site_packages_dir}/skyline_apiserver/db/alembic/alembic.ini upgrade head
