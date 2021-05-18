Upgrades and Reconfiguration
----------------------------

The OpenStack-Helm project assumes all upgrades will be done through
Helm. This includes handling several different resource types. First,
changes to the Helm chart templates themselves are handled. Second, all
of the resources layered on top of the container image, such as
``ConfigMaps`` which includes both scripts and configuration files, are
updated during an upgrade. Finally, any image references will result in
rolling updates of containers, replacing them with the updating image.

As Helm stands today, several issues exist when you update images within
charts that might have been used by jobs that already ran to completion
or are still in flight. An example of where this behavior would be
desirable is when an updated db\_sync image has updated to point from
one openstack release to another. In this case, the operator will likely
want a db\_sync job, which was already run and completed during site
installation, to run again with the updated image to bring the schema
inline with the Newton release.

The OpenStack-Helm project also implements annotations across all chart
configmaps so that changing resources inside containers, such as
configuration files, triggers a Kubernetes rolling update. This means
that those resources can be updated without deleting and redeploying the
service and can be treated like any other upgrade, such as a container
image change.

Note: Rolling update values can conflict with values defined in each
service's PodDisruptionBudget.  See
`here <https://docs.openstack.org/openstack-helm/latest/devref/pod-disruption-budgets.html>`_
for more information.

This is accomplished with the following annotation:

::

          ...
          annotations:
            configmap-bin-hash: {{ tuple "configmap-bin.yaml" . | include "helm-toolkit.utils.hash" }}
            configmap-etc-hash: {{ tuple "configmap-etc.yaml" . | include "helm-toolkit.utils.hash" }}

The ``hash`` function defined in the ``helm-toolkit`` chart ensures that
any change to any file referenced by configmap-bin.yaml or
configmap-etc.yaml results in a new hash, which will then trigger a
rolling update.

All ``Deployment`` chart components are outfitted by default
with rolling update strategies:

::

    # Source: keystone/templates/deployment-api.yaml
    spec:
      replicas: {{ .Values.pod.replicas.api }}
    {{ tuple $envAll | include "helm-toolkit.snippets.kubernetes_upgrades_deployment" | indent 2 }

In ``values.yaml`` in each chart, the same defaults are supplied in every
chart, which allows the operator to override at upgrade or deployment
time.

::

    pod:
      lifecycle:
        upgrades:
          deployments:
            revision_history: 3
            pod_replacement_strategy: RollingUpdate
            rolling_update:
              max_unavailable: 1
              max_surge: 3
