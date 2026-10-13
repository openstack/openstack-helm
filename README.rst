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
   * - 2025.2 (Flamingo)
     - Ubuntu Noble
     - Ubuntu Noble
     - >=1.33,<=1.35
   * - 2026.1 (Gazpacho)
     - Ubuntu Noble
     - Ubuntu Noble
     - >=1.33,<=1.35
   * - 2026.2 (Hibiscus)
     - Ubuntu Resolute
     - Ubuntu Resolute
     - >=1.33,<=1.35

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

Release notes are written as git trailers in the commit that makes the change. If you update a
chart, add a ``Changelog:`` trailer to the last paragraph of the commit message, next to
``Change-Id``:

.. code-block:: text

    neutron: fix the health probe for the OVN agent

    <body>

    Changelog: fixed
    Change-Id: I7d940919531125e2806b18fcb6cfe245d6b31450

The kind is one of ``added``, ``changed``, ``deprecated``, ``removed``, ``fixed`` and ``security``,
or ``skip`` when the change needs no release note. Without a description the commit subject is used.

By default the note goes to the charts whose directories the commit touches. Use a ``Charts:``
trailer to override that, for example ``Charts: barbican, keystone`` or ``Charts: all`` when a
change affects every chart.

When building tarballs we collect the release notes belonging to the version being built and write
them into the ``artifacthub.io/changes`` annotation of ``<chart_name>/Chart.yaml``, which
`Artifact Hub <https://artifacthub.io/docs/topics/annotations/helm/>`_ renders as the chart's
changelog. Run ``python3 tools/check_commit_message.py`` to validate your commit before pushing.

The full description lives in ``doc/source/devref/release-notes.rst``, including how the legacy
``releasenotes/notes`` files are still picked up.
