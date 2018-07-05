{{/*
Copyright 2017 The Openstack-Helm Authors.

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

{{- define "helm-toolkit.manifests.job_rabbit_init" -}}
{{- $envAll := index . "envAll" -}}
{{- $serviceName := index . "serviceName" -}}
{{- $nodeSelector := index . "nodeSelector" | default ( dict $envAll.Values.labels.job.node_selector_key $envAll.Values.labels.job.node_selector_value ) -}}
{{- $configMapBin := index . "configMapBin" | default (printf "%s-%s" $serviceName "bin" ) -}}
{{- $serviceUser := index . "serviceUser" | default $serviceName -}}
{{- $serviceUserPretty := $serviceUser | replace "_" "-" -}}

{{- $serviceAccountName := printf "%s-%s" $serviceUserPretty "rabbit-init" }}
{{ tuple $envAll "rabbit_init" $serviceAccountName | include "helm-toolkit.snippets.kubernetes_pod_rbac_serviceaccount" }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ printf "%s-%s" $serviceUserPretty "rabbit-init" | quote }}
spec:
  template:
    metadata:
      labels:
{{ tuple $envAll $serviceName "rabbit-init" | include "helm-toolkit.snippets.kubernetes_metadata_labels" | indent 8 }}
    spec:
      serviceAccountName: {{ $serviceAccountName | quote }}
      restartPolicy: OnFailure
      nodeSelector:
{{ toYaml $nodeSelector | indent 8 }}
      initContainers:
{{ tuple $envAll "rabbit_init" list | include "helm-toolkit.snippets.kubernetes_entrypoint_init_container" | indent 8 }}
      containers:
        - name: rabbit-init
          image: {{ $envAll.Values.images.tags.rabbit_init | quote }}
          imagePullPolicy: {{ $envAll.Values.images.pull_policy | quote }}
{{ tuple $envAll $envAll.Values.pod.resources.jobs.rabbit_init | include "helm-toolkit.snippets.kubernetes_resources" | indent 10 }}
          command:
            - /tmp/rabbit-init.sh
          volumeMounts:
            - name: rabbit-init-sh
              mountPath: /tmp/rabbit-init.sh
              subPath: rabbit-init.sh
              readOnly: true
          env:
          - name: RABBITMQ_ADMIN_CONNECTION
            valueFrom:
              secretKeyRef:
                name: {{ $envAll.Values.secrets.oslo_messaging.admin }}
                key: RABBITMQ_CONNECTION
          - name: RABBITMQ_USER_CONNECTION
            valueFrom:
              secretKeyRef:
                name: {{ index $envAll.Values.secrets.oslo_messaging $serviceName }}
                key: RABBITMQ_CONNECTION
{{- if $envAll.Values.conf.rabbitmq }}
          - name: RABBITMQ_AUXILIARY_CONFIGURATION
            value: {{ toJson $envAll.Values.conf.rabbitmq | quote }}
{{- end }}
      volumes:
        - name: rabbit-init-sh
          configMap:
            name: {{ $configMapBin | quote }}
            defaultMode: 0555

{{- end -}}
