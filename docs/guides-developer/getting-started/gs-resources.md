## Resource Limits

Resource limits should be defined for all charts within OpenStack-Helm.

The convention is to leverage a `resources:` section within values.yaml by using an `enabled` setting that defaults to `false` but can be turned on by the operator at install or upgrade time.

The resources specify the requests (memory and cpu) and limits (memory and cpu) for each deployed resource.  For example, from the Nova chart `values.yaml`:

```
resources:
  enabled: false
  nova_compute:
    requests:
      memory: "124Mi"
      cpu: "100m"
    limits:
      memory: "1024Mi"
      cpu: "2000m"
  nova_libvirt:
    requests:
      memory: "124Mi"
      cpu: "100m"
    limits:
      memory: "1024Mi"
      cpu: "2000m"
  nova_api_metadata:
    requests:
      memory: "124Mi"
      cpu: "100m"
    limits:
      memory: "1024Mi"
      cpu: "2000m"
...
```

These resources definitions are then applied to the appropriate component when the `enabled` flag is set.  For instance, the following nova_compute daemonset has the requests and limits values applied from `.Values.resources.nova_compute`:

```
          {{- if .Values.resources.enabled }}
          resources:
            requests:
              memory: {{ .Values.resources.nova_compute.requests.memory | quote }}
              cpu: {{ .Values.resources.nova_compute.requests.cpu | quote }}
            limits:
              memory: {{ .Values.resources.nova_compute.limits.memory | quote }}
              cpu: {{ .Values.resources.nova_compute.limits.cpu | quote }}
          {{- end }}
```

When a chart developer doesn't know what resource limits or requests to apply to a new component, they can deploy the component locally and examine resource utilization using tools like WeaveScope.  The resource limits may not be perfect on initial submission, but over time and with community contributions, they can be refined to reflect reality.
