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
ACTION="${@:-api}"

case "$ACTION" in
  api)
    alembic --config=/etc/workloadmgr/alembic.ini upgrade head
    ;;&
  api|workloads)
    sed -i "s/'service', 'tvault-object-store', 'status'/'echo', 'running'/" /usr/lib/python3/dist-packages/workloadmgr/vault/vault.py
    /usr/bin/s3vaultfuse.py --config-file=/etc/tvault-object-store.conf &
    ;;
  cron)
    sed -i "s/shutil.which('systemctl'), 'status', 'wlm-cron'/'true'/" /usr/lib/python3/dist-packages/workloadmgr/service.py
    ;;
esac

exec /usr/bin/workloadmgr-${ACTION} --config-file=/etc/workloadmgr/workloadmgr.conf
