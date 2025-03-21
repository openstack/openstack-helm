==============
OpenStack-Helm
==============

Mission
-------

The goal of OpenStack-Helm is to provide a collection of Helm charts that
simply, resiliently, and flexibly deploy OpenStack and related services
on Kubernetes.

Versions supported
------------------

The table below shows the combinations of the Openstack/Platform/Kubernetes versions
that are tested and proved to work.

.. list-table::
   :widths: 30 30 30 30
   :header-rows: 1

   * - Openstack version
     - Host OS
     - Image OS
     - Kubernetes version
   * - 2023.2 (Bobcat)
     - Ubuntu Jammy
     - Ubuntu Jammy
     - >=1.29,<=1.31
   * - 2024.1 (Caracal)
     - Ubuntu Jammy
     - Ubuntu Jammy
     - >=1.29,<=1.31
   * - 2024.2 (Dalmatian)
     - Ubuntu Jammy
     - Ubuntu Jammy
     - >=1.29,<=1.31

Communication
-------------

* Join us on `IRC <irc://chat.oftc.net/openstack-helm>`_:
  ``#openstack-helm`` on oftc
* Join us on `Slack <https://kubernetes.slack.com/messages/C3WERB7DE/>`_
  (this is preferable way of communication): ``#openstack-helm``
* Join us on `Openstack-discuss <https://lists.openstack.org/cgi-bin/mailman/listinfo/openstack-discuss>`_
  mailing list (use subject prefix ``[openstack-helm]``)

The list of Openstack-Helm core team members is available here
`openstack-helm-core <https://review.opendev.org/#/admin/groups/1749,members>`_.

Storyboard
----------

You found an issue and want to make sure we are aware of it? You can do so on our
`Storyboard <https://storyboard.openstack.org/#!/project_group/64>`_.

Bugs should be filed as stories in Storyboard, not GitHub.

Please be as much specific as possible while describing an issue. Usually having
more context in the bug description means less efforts for a developer to
reproduce the bug and understand how to fix it.

Also before filing a bug to the Openstack-Helm `Storyboard <https://storyboard.openstack.org/#!/project_group/64>`_
please try to identify if the issue is indeed related to the deployment
process and not to the deployable software.

Other links
-----------

Our documentation is available `here <https://docs.openstack.org/openstack-helm/latest/>`_.

This project is under active development. We encourage anyone interested in
OpenStack-Helm to review the `code changes <https://review.opendev.org/q/(project:openstack/openstack-helm+OR+project:openstack/openstack-helm-images+OR+project:openstack/loci)+AND+-is:abandoned>`_

Our repositories:

* OpenStack charts `openstack-helm <https://opendev.org/openstack/openstack-helm.git>`_
* OpenStack-Helm plugin `openstack-helm-plugin <https://opendev.org/openstack/openstack-helm-plugin.git>`_
* Build non-OpenStack images `openstack-helm-images <https://opendev.org/openstack/openstack-helm-images.git>`_
* Build Openstack images `loci <https://opendev.org/openstack/loci.git>`_

We welcome contributions in any form: code review, code changes, usage feedback, updating documentation.

Release notes
-------------

We use `reno <https://opendev.org/openstack/reno.git>`_ for managing release notes. If you update
a chart, please add a release note using the following command:

.. code-block:: bash

    reno new <chart_name>

This will create a new release note file ``releasenotes/notes/<chart_name>-<sha>.yaml``. Fill in the
necessary information and commit the release note file.

If you update multiple charts in a single commit use the following command:

.. code-block:: bash

    reno new common

This will create a new release note file ``releasenotes/notes/common-<sha>.yaml``. In this case you
can add multiple chart specific sections in this release note file.

When building tarballы, we will use the ``reno`` features to combine release notes from all files and
generate  ``<chart_name>/CHANGELOG.md`` files.
