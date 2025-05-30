====================
Own Service Accounts
====================

Problem Description
===================

Currently when an OpenStack-Helm chart deploys a OpenStack service,
it creates a service account that is used by other Openstack services
to interact with the service's API. For example, the Nova
chart creates a service account called `nova` and other charts
like Cinder and Neutron configure Cinder and Neutron services
to use the `nova` service account to interact with the Nova API.

However, there might be scenarios where multiple Nova accounts
are necessary. For instance, if Neutron requires more permissive
access to the Nova API than Cinder, it might be desirable to create
two separate accounts with tailored permissions.

Also the current approach assumes service accounts are owned by
the chart that creates them and it requires other charts to be
deployed with the credentials of the service account owner chart.
I.e. the service account credentials must be synced between charts.


Proposed Change
===============

The spec proposes to modify the `Keystone user manifest`_ so
it is able to create multiple Keystone users. The job will be deployed with
multiple containers, each container will create a separate Keystone user.

All other Openstack charts use the `Keystone user manifest`_ for
managing service accounts. So every Openstack chart will be able to create a bunch
of service accounts according to their needs.

E.g. the Neutron chart will create the following service accounts:

* neutron (used by Neutron to communicate with the Keystone API to check auth tokens
  and other services can use it to get access to the Neutron API)
* neutron_nova (used by Neutron to get access to the Nova API instead
  of using `nova` service account created by the Nova chart)
* neutron_placement (used by Neutron to get access to the Placement API
  instead of using `placement` service account managed by the Placement chart)

The proposed change is going to be backward compatible because the Neutron
chart will still be able to use the `neutron` and `placement` service accounts
managed by the Nova and Placement charts. Also the `neutron` service account
can still be used by other charts to communicate with the Neutron API.

Implementation
==============

Assignee(s)
-----------

Primary assignee:
  kozhukalov (Vladimir Kozhukalov <kozhukalov@gmail.com>)

Values
------

Service accounts credentials are defined in the `values.yaml` files
in the `.Values.endpoints.identity.auth` section. The section contains
a bunch of dicts defining credentials for every service account.

Currently those dicts which correspond to service accounts managed by other charts
must be aligned with those charts values. For example, the Neutron values must
define the `nova` service account the same way as the Nova chart does.

The following is the example of how the `.Values.endpoints.identity.auth`
section of a chart must be modified. The example is given for the Neutron chart:

.. code-block:: yaml

    endpoints:
      identity:
        auth:
          # This serivce account is managed by Keystone chart
          # and created during Keystone database sync.
          # We should not modify it.
          admin:
            region_name: RegionOne
            username: admin
            password: password
            project_name: admin
            user_domain_name: default
            project_domain_name: default
          # Service account with the following username/password
          # will be created by the Keystone user job
          # and will be used for Neutron configuration.
          # For backward compatibility this dict must not be modified
          # to stay aligned with other charts that use this service account
          # to get access to the Neutron API.
          neutron:
            role: admin,service
            region_name: RegionOne
            username: neutron
            password: password
            project_name: service
            user_domain_name: service
            project_domain_name: service
          # Service account with the following username/password
          # will be created by the Keystone user job
          # and will be used for Neutron configuration. Also the
          # `role` field must be added to assign necessary roles
          # to the service account.
          nova:
            role: admin,service
            region_name: RegionOne
            project_name: service
            username: neutron_nova
            password: neutron_nova_password
            user_domain_name: service
            project_domain_name: service
          # Service account with the following username/password
          # will be created by the Keystone user job
          # and will be used for Neutron configuration. Also the
          # `role` field must be added to assign necessary roles
          # to the service account.
          placement:
            role: admin,service
            region_name: RegionOne
            project_name: service
            username: neutron_placement
            password: neutron_placement_password
            user_domain_name: service
            project_domain_name: service

Secrets
-------

The service account credentials are stored in K8s secrets which are
used by the `Keystone user manifest`_ to create the service accounts.

So the the template that deploys those secrets must be updated to
create the secrets for all service accounts defined in the
`.Values.endpoints.identity.auth` section.

Also the `.Values.secrets.identity` section must be updated and
secret names must be added for all service accounts defined in the
`.Values.endpoints.identity.auth` section.

Keystone user manifest
----------------------

The Helm-toolkit chart defines the `Keystone user manifest`_
which is used by all Openstack charts to create service accounts.
The manifest must be updated to be able to accept `serviceUsers` parameter
which will be the list of service accounts to be created by the job.

For backward compatibility if the `serviceUsers` parameter is not given
then the manifest will use the `serviceUser` parameter or `serviceName` parameter
to define the `serviceUsers` as a list with a single element.

.. code-block::

    {{- $serviceName := index . "serviceName" -}}
    {{- $singleServiceUser := index . "serviceUser" | default $serviceName -}}
    {{- $serviceUsers := index . "serviceUsers" | default (tuple $singleServiceUser) -}}

Keystone user job
-----------------

All Openstack charts deploy the job to create service accounts which uses
the `Keystone user manifest`_. The modified manifest will be
able to create multiple Keystone users and the job template must also be updated
to pass the proper list of service accounts to the manifest.

For example, the Neutron chart will be modified to create the following
service accounts:

.. code-block::

    {{ dict "envAll" . "serviceName" "neutron" "serviceUsers" (tuple "neutron" "nova" "placement") | include "helm-toolkit.manifests.job_ks_user" }}

Work Items
----------

* Modify the `Keystone user manifest`_ to make it possible
  to create multiple Keystone users in a single job.
* Modify charts one by one as described above so they create their own
  service accounts to get access to the APIs of other OpenStack services.

Alternatives
------------

A K8s operator can be used to manage service accounts. In this case
charts will deploy the custom resources that will be handled by the operator.
The operator could also be useful for more complex scenarios when users
deploy Keystone federation and need more flexibility in managing
service accounts.

However, the proposed change is simpler to implement and it does not
require any additional components while the change is backward compatible
and does not break existing deployments.

Documentation Impact
====================
The documentation must be updated to reflect the change.

.. _Keystone user manifest: https://opendev.org/openstack/openstack-helm/src/branch/master/helm-toolkit/templates/manifests/_job-ks-user.yaml.tpl
