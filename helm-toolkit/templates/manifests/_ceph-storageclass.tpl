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

{{/*
abstract: |
  Creates a manifest for kubernete ceph storageclass
examples:
  - values: |
      manifests:
        storageclass: true
      storageclass:
        rbd:
          provision_storage_class: true
          provisioner: "ceph.com/rbd"
          metadata:
            default_storage_class: true
            name: general
          parameters:
            #We will grab the monitors value based on helm-toolkit.endpoints.host_and_port_endpoint_uri_lookup
            pool: rbd
            admin_id: admin
            ceph_configmap_name: "ceph-etc"
            admin_secret_name: "pvc-ceph-conf-combined-storageclass"
            admin_secret_namespace: ceph
            user_id: admin
            user_secret_name: "pvc-ceph-client-key"
            image_format: "2"
            image_features: layering
        cephfs:
          provision_storage_class: true
          provisioner: "ceph.com/cephfs"
          metadata:
            name: cephfs
          parameters:
            admin_id: admin
            admin_secret_name: "pvc-ceph-cephfs-client-key"
            admin_secret_namespace: ceph
    usage: |
      {{- range $storageclass, $val := .Values.storageclass }}
      {{ dict "storageclass_data" $val "envAll" $ | include "helm-toolkit.manifests.ceph-storageclass" }}
      {{- end }}
    return: |
      ---
      apiVersion: storage.k8s.io/v1
      kind: StorageClass
      metadata:
        annotations:
          storageclass.kubernetes.io/is-default-class: "true"
        name: general
      provisioner: ceph.com/rbd
      parameters:
        monitors: ceph-mon.<ceph-namespace>.svc.<k8s-domain-name>:6789
        adminId: admin
        adminSecretName: pvc-ceph-conf-combined-storageclass
        adminSecretNamespace: ceph
        pool: rbd
        userId: admin
        userSecretName: pvc-ceph-client-key
        image_format: "2"
        image_features: layering
      ---
      apiVersion: storage.k8s.io/v1
      kind: StorageClass
      metadata:
        name: cephfs
      provisioner: ceph.com/cephfs
      parameters:
        monitors: ceph-mon.<ceph-namespace>.svc.<k8s-domain-name>:6789
        adminId: admin
        adminSecretName: pvc-ceph-cephfs-client-key
        adminSecretNamespace: ceph
*/}}

{{- define "helm-toolkit.manifests.ceph-storageclass" -}}
{{- $envAll := index . "envAll" -}}
{{- $monHost := $envAll.Values.conf.ceph.global.mon_host -}}
{{- if empty $monHost -}}
{{- $monHost = tuple "ceph_mon" "internal" "mon" $envAll | include "helm-toolkit.endpoints.host_and_port_endpoint_uri_lookup" -}}
{{- end -}}
{{- $storageclassData := index . "storageclass_data" -}}
---
{{- if $storageclassData.provision_storage_class }}
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
{{- if $storageclassData.metadata.default_storage_class }}
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
{{- end }}
  name: {{ $storageclassData.metadata.name }}
provisioner: {{ $storageclassData.provisioner }}
parameters:
  monitors: {{ $monHost }}
{{- range $attr, $value := $storageclassData.parameters }}
  {{ $attr }}: {{ $value | quote }}
{{- end }}
allowVolumeExpansion: true

{{- end }}
{{- end }}
