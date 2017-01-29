{{- define "dep_check_init_cont" -}}
{{- $envAll := index . 0 -}}
{{- $deps := index . 1 -}}
{
  "name": "init",
  "image": {{ $envAll.Values.images.dep_check | quote }},
  "imagePullPolicy": {{ $envAll.Values.images.pull_policy | quote }},
  "env": [
    {
      "name": "POD_NAME",
      "valueFrom": {
        "fieldRef": {
          "APIVersion": "v1",
          "fieldPath": "metadata.name"
        }
      }
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
      "value": "{{  include "joinListWithComma"  $deps.service }}"
    },
    {
      "name": "DEPENDENCY_JOBS",
      "value": "{{  include "joinListWithComma" $deps.jobs }}"
    },
    {
      "name": "DEPENDENCY_DAEMONSET",
      "value": "{{  include "joinListWithComma" $deps.daemonset }}"
    },
    {
      "name": "COMMAND",
      "value": "echo done"
    }
  ]
}
{{- end -}}
