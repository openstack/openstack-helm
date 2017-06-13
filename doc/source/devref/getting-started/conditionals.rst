Common Conditionals
-------------------

The OpenStack-Helm charts make the following conditions available across
all charts, which can be set at install or upgrade time with Helm below.

Developer Mode
~~~~~~~~~~~~~~

::

    helm install local/chart --set development.enabled=true

The development mode flag should be used by any charts that should
behave differently on a developer's laptop than in a production-like deployment,
or have resources that would be difficult to spin up in a small environment.

A chart could for instance define the following ``development:``
override to set ``foo`` to ``bar`` in a dev environment, which
would be triggered by setting the ``enabled`` flag to ``true``.

::

    development:
      enabled: false
      foo: bar


Resources
~~~~~~~~~

::

    helm install local/chart --set resources.enabled=true

Resource limits/requirements can be turned on and off. By default, they
are off. Setting this enabled to ``true`` will deploy Kubernetes
resources with resource requirements and limits.
