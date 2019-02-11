..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode

..

========================================================
Support OCI image registry with authentication turned on
========================================================

Blueprint:
support-oci-image-registry-with-authentication-turned-on_

.. _support-oci-image-registry-with-authentication-turned-on: https://blueprints.launchpad.net/openstack-helm/+spec/support-oci-image-registry-with-authentication-turned-on

Problem Description
===================
In the current openstack-helm, all charts provide an ``images:`` section in
their ``values.yaml`` that have the container images references. By default,
the container images are all downloaded from a registry hosted by Docker or Quay.
However, the image references can be overridden by operators to download images
from any OCI image registry. In the case that the OCI image registry has
authentication turned on, kubelet would fail to download the images because the
current Openstack-Helm does not provide a way to pass the OCI image registry
credentials to kubernetes when pulling images.


Use case
========
Operators should be able to use Openstack-Helm to deploy containerized openstack
services with a docker registry has authentication turned on.


Proposed Change
===============
To be able to pull images from an OCI image registry which has the authentication
turned on, kubernetes needs credentials. For each chart, a new ``endpoints:``
entry could be added in ``values.yaml`` to provide image credentials, a secret
needs to be generated to hold the credentials and the ``imagePullSecrets:`` field
should be added in each service account to specify which secret should be used
to get the credentials from when pulling images by kubelet.

The detailed proposes change are described as following:

1. For each chart, add a new entry ``oci_image_registry:`` under ``endpoints:`` in
``values.yaml``. The entry ``oci_image_registry:`` has the ``auth:`` section which
provides the credentials for accessing registry images and an option ``enabled:``
to determine whether images authentication is required or not. The registry basic
information would also be included for generating the registry URL by the endpoint
lookup functions. Also add a new entry ``oci_image_registry:`` under ``secrets:``
to indicate the secret name. In order to create the secret that holds the provided
credentials, add a new component ``secret_registry`` in ``manifests:`` section.
For example:

.. code-block:: yaml

   secrets:
     oci_image_registry:
       nova: nova-oci-image-registry-key

   endpoints:
     ...
     oci_image_registry:
       name: oci-image-registry
       namespace: oci-image-registry
       auth:
         enabled: false
         nova:
           username: nova
           password: password
       hosts:
         default: localhost
       host_fqdn_override:
         default: null
       port:
         registry:
           default: 5000

   manifests:
     secret_registry: true

The option ``enabled:`` under ``auth:`` and the manifest ``secret_registry:``
provide the ability for operator to determine whether they would like to have
secrets generated and passed to kubernetes for pulling images.

The secret would not be created with the default option ``enabled: false`` and
``secret_registry: true``. To enable secret creation, operator should override
``enabled:`` to true. The above example shows the default credentials, operator
should override the ``username:`` and ``password:`` under ``auth:`` section to
provide their own credentials.

Then, add manifest ``secret-registry.yaml`` in ``templates/`` to leverage
the function that will be added in helm-toolkit to create the secret. For example:

.. code-block:: yaml

   {{- if and .Values.manifests.secret_registry .Values.endpoints.oci_image_registry.auth.enabled }}
   {{ include "helm-toolkit.manifests.secret_registry" ( dict "envAll" . "registryUser" .Chart.Name ) }}
   {{- end }}

2. Add a helm-toolkit function ``helm-toolkit.manifests.secret_registry`` to create a
   manifest for secret generation. For example:

.. code-block:: rst

   {{- define "helm-toolkit.manifests.secret_registry" -}}
   {{- $envAll := index . "envAll" }}
   {{- $registryUser := index . "registryUser" }}
   {{- $secretName := index $envAll.Values.secrets.oci_image_registry $registryUser }}
   {{- $registryHost := tuple "oci_image_registry" "internal" $envAll | include "helm-toolkit.endpoints.endpoint_host_lookup" }}
   {{- $registryPort := tuple "oci_image_registry" "internal" "registry" $envAll | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
   {{- $imageCredentials := index $envAll.Values.endpoints.oci_image_registry.auth $registryUser }}
   {{- $dockerAuthToken := printf "%s:%s" $imageCredentials.username $imageCredentials.password | b64enc }}
   {{- $dockerAuth := printf "{\"auths\": {\"%s:%s\": {\"auth\": \"%s\"}}}" $registryHost $registryPort $dockerAuthToken | b64enc }}
   ---
   apiVersion: v1
   kind: Secret
   metadata:
     name: {{ $secretName }}
   type: kubernetes.io/dockerconfigjson
   data:
     .dockerconfigjson: {{ $dockerAuth }}
   {{- end }}

3. Reference the created secret by adding the ``imagePullSecrets:`` field to ServiceAccount
   resource template [2]_ in ``helm-toolkit/snippets/_kubernetes_pod_rbac_serviceaccount.tpl``.
   To handle it as optional, the field is wrapped in a conditional. For example,

.. code-block:: yaml

   ---
   apiVersion: v1
   kind: ServiceAccount
   ...
   {{- if $envAll.Values.endpoints.oci_image_registry.auth.enabled }}
   imagePullSecrets:
     - name: {{ index $envAll.Values.secrets.oci_image_registry $envAll.Chart.Name }}
   {{- end }}

If .Values.endpoints.oci_image_registry.auth.enabled will be set to true, then any
containers created with the current service account will have the ``imagePullSecrets``
automatically added to their spec and the secret will be passed to kubelet to be
used for pulling images.


Security Impact
---------------
The credentials for the registry could be exposed by running the kubectl command:
kubectl get secret <secret-name> --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode

Authentication should be enabled for normal users to access Kube API server via
either kubectl command or kube REST API call.


Performance Impact
------------------
No performance impact


Alternatives
------------
Before using Openstack-Helm to deploy openstack services,

1. Put .docker/config.json in docker/kubelet root directory on all nodes
2. Pre-pulling images on all nodes

But above alternatives have limitations and security impact. i.e...require root access
to configure on all nodes, all pods can read any configured private registries, all pods
can use any images cached on a node [1]_


Implementation
==============

Assignee(s)
-----------

Primary assignees:

* Angie Wang (angiewang)


Work Items
----------
#. Provide the credentials and add the manifest across all charts in OSH and OSH-infra
#. Update helm-toolkit to provide manifest to create secret for registry authentication
#. Update helm-toolkit serviceaccount template to pass the secret in a conditional


Testing
=======
None

Documentation Impact
====================
Documentation of how to enable the registry secret generation


References
==========
.. [1] https://kubernetes.io/docs/concepts/containers/images
.. [2] https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#add-imagepullsecrets-to-a-service-account
