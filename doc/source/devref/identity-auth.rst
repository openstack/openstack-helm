Identity Authentication
=======================

By default, helm-toolkit jobs (``ks-service``, ``ks-endpoints``, ``ks-user``,
``bootstrap``) authenticate to Keystone using username/password credentials
sourced from a Kubernetes secret via ``OS_*`` environment variables.

Alternative authentication plugins can be configured through the
``identity.openrc`` values section. This allows excluding default environment
variables and injecting additional ones required by a different keystoneauth
plugin.

See `keystoneauth plugin options
<https://docs.openstack.org/keystoneauth/2026.1/plugin-options.html>`_ for
available plugins and their required parameters.

Configuration
-------------

.. code-block:: yaml

   identity:
     openrc:
       exclude_vars: []
       extra_vars: []

``exclude_vars``
  A list of environment variable names to omit from the default set.
  Default variables: ``OS_IDENTITY_API_VERSION``, ``OS_AUTH_URL``,
  ``OS_REGION_NAME``, ``OS_INTERFACE``, ``OS_ENDPOINT_TYPE``,
  ``OS_PROJECT_DOMAIN_NAME``, ``OS_PROJECT_NAME``, ``OS_USER_DOMAIN_NAME``,
  ``OS_USERNAME``, ``OS_PASSWORD``, ``OS_DEFAULT_DOMAIN``.

``extra_vars``
  A list of additional environment variable entries to inject. Each entry
  supports static values, secret references, or configmap references.

Example: v3oidcaccesstoken
--------------------------

To use the ``v3oidcaccesstoken`` auth plugin:

.. code-block:: yaml

   identity:
     openrc:
       exclude_vars:
         - OS_USERNAME
         - OS_PASSWORD
         - OS_USER_DOMAIN_NAME
       extra_vars:
         - name: OS_AUTH_TYPE
           value: "v3oidcaccesstoken"
         - name: OS_ACCESS_TOKEN
           secretKeyRef:
             name: my-oidc-secret
             key: access-token
         - name: OS_IDENTITY_PROVIDER
           value: "myidp"
         - name: OS_PROTOCOL
           value: "mapped"

extra_vars entry formats
------------------------

Static value:

.. code-block:: yaml

   - name: OS_AUTH_TYPE
     value: "v3oidcaccesstoken"

From a Kubernetes Secret:

.. code-block:: yaml

   - name: OS_ACCESS_TOKEN
     secretKeyRef:
       name: my-oidc-secret
       key: access-token

From a ConfigMap:

.. code-block:: yaml

   - name: OS_CONFIG_VALUE
     configMapKeyRef:
       name: my-configmap
       key: some-key
