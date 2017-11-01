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

{{- define "helm-toolkit.snippets.kubernetes_entrypoint_rbac" -}}
{{- $envAll := index . 0 -}}
{{- $component := $envAll.Release.Name -}}
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: cluster-role-binding-entrypoint-{{ $component }}
  annotations:
    # Tiller sorts the execution of resources in the following order:
    # Secret, ServiceAccount, Role, RoleBinding. The problem is that
    # this Secret will not be created if ServiceAccount doesn't exist.
    # The solution is to add pre-install hook so that these are created first.
    helm.sh/hook: pre-install
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-role-entrypoint-{{ $component }}
subjects:
  - kind: ServiceAccount
    name: service-account-entrypoint-{{ $component }}
    namespace:  {{ $envAll.Release.Namespace }}
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: cluster-role-entrypoint-{{ $component }}
  annotations:
    # Tiller sorts the execution of resources in the following order:
    # Secret, ServiceAccount, Role, RoleBinding. The problem is that
    # this Secret will not be created if ServiceAccount doesn't exist.
    # The solution is to add pre-install hook so that these are created first.
    helm.sh/hook: pre-install
rules:
  - apiGroups:
    - ""
    - extensions
    - batch
    - apps
    resources:
    - pods
    - services
    - jobs
    - endpoints
    - daemonsets
    verbs:
    - get
    - list
---
apiVersion: v1
kind: Secret
metadata:
  name: secret-entrypoint-{{ $component }}
  namespace:  {{ $envAll.Release.Namespace }}
  annotations:
    kubernetes.io/service-account.name: service-account-entrypoint-{{ $component }}
type: kubernetes.io/service-account-token
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: service-account-entrypoint-{{ $component }}
  namespace:  {{ $envAll.Release.Namespace }}
  annotations:
    # Tiller sorts the execution of resources in the following order:
    # Secret, ServiceAccount, Role, RoleBinding. The problem is that
    # this Secret will not be created if ServiceAccount doesn't exist.
    # The solution is to add pre-install hook so that these are created first.
    helm.sh/hook: pre-install
{{- end -}}
