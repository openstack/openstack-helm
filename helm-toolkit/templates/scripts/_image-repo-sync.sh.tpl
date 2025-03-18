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

{{- define "helm-toolkit.scripts.image_repo_sync" }}
#!/bin/sh
set -ex

IFS=','; for IMAGE in ${IMAGE_SYNC_LIST}; do
  docker pull ${IMAGE}
  docker tag ${IMAGE} ${LOCAL_REPO}/${IMAGE}
  docker push ${LOCAL_REPO}/${IMAGE}
done
{{- end }}
