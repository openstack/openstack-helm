{{- define "helm-toolkit.kubernetes_entrypoint_init_container" -}}
{{- $envAll := index . 0 -}}
{{- $deps := index . 1 -}}
{
  "name": "init",
  "image": {{ $envAll.Values.images.dep_check | quote }},
  "imagePullPolicy": {{ $envAll.Values.images.pull_policy | quote }},
  "env": [
    {
      "name": "POD_NAME",
      {{- if $deps.pod -}}
      "value": "{{ index $deps.pod 0 }}"
      {{- else -}}
      "valueFrom": {
        "fieldRef": {
          "APIVersion": "v1",
          "fieldPath": "metadata.name"
        }
      }
      {{- end -}}
    },
    {
      "name": "NAMESPACE",
      "valueFrom": {
        "fieldRef": {
          "APIVersion": "v1",
          "fieldPath": "metadata.namespace"
        }
      }
    },
    {
      "name": "INTERFACE_NAME",
      "value": "eth0"
    },
    {
      "name": "DEPENDENCY_SERVICE",
      "value": "{{  include "helm-toolkit.joinListWithComma"  $deps.service }}"
    },
    {
      "name": "DEPENDENCY_JOBS",
      "value": "{{  include "helm-toolkit.joinListWithComma" $deps.jobs }}"
    },
    {
      "name": "DEPENDENCY_DAEMONSET",
      "value": "{{  include "helm-toolkit.joinListWithComma" $deps.daemonset }}"
    },
    {
      "name": "DEPENDENCY_CONTAINER",
      "value": "{{  include "helm-toolkit.joinListWithComma" $deps.container }}"
    },
    {
      "name": "COMMAND",
      "value": "echo done"
    }
  ]
}
{{- end -}}
