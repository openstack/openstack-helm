=================
Charts versioning
=================

Problem Description
===================

There are issues:

* All Openstack-Helm charts depend on the helm-toolkit subchart, but
  the helm-toolkit version is not pinned. When helm-toolkit is updated,
  we don't bump the version of the charts that depend on it and re-publish
  them. This can change the behavior of the charts while the version of the
  chart tarball remains unchanged.
* We use `chart-testing`_ to lint the charts. The chart-testing tool
  requires that the chart version is bumped every time any file in the
  chart directory is changed. In every chart, we have a ``values_overrides``
  directory where we store the version-specific overrides as well as
  example overrides for some specific configurations. These overrides are
  not part of the chart tarball, but when they are changed, we bump the
  chart version.
* We use ``apiVersion: v1`` in ``Chart.yaml``, and dependencies are stored in a
  separate ``requirements.yaml`` file. However, ``apiVersion: v2`` allows defining
  dependencies directly in the ``Chart.yaml`` file.
* We track the release notes in a separate directory and we don't have a
  CHANGELOG.md file in chart tarballs.
* Chart maintainers are assumed to update the same release notes file
  when they change the same chart in two separate commits. This leads to
  merge conflicts that are now resolved manually which is inconvenient.
  This is because we are misusing the Reno tool which is designed to
  avoid merge conflicts in the release notes.
* All the chart versions are independent of each other and do not follow the
  Openstack release versioning which makes it difficult for users to understand
  which version of the chart corresponds to which Openstack release.

Proposed Change
===============

We propose to do the following:

* Move values overrides to a separate directory.
* Use ``apiVersion: v2`` in ``Chart.yaml``.
* Move release notes to the CHANGELOG.md files.
* Once the Openstack is released we will bump the version of all charts to
  this new release, for example ``2025.1.0``.
  Semver assumes the following:

    * MAJOR version when you make incompatible API changes
    * MINOR version when you add functionality in a backward compatible manner
    * PATCH version when you make backward compatible bug fixes

  However, we will not strictly follow these assumptions. We will still
  follow the policy that the last version of any chart must
  be compatible with all currently maintained versions of Openstack
  (usually 3 most recent versions). All the changes between Openstack
  releases will be backward compatible.

  We will not bump the chart version in the git repo when we update chart.
  Instead, we will increment the PATCH automatically when building the tarball.
  The PATCH will be calculated as the number of commits related to a given
  chart after the latest git tag.
  So for example if the latest tag is ``2024.2.0`` and we have 3 commits
  in the nova chart after this tag, the version of the nova tarball will be
  ``2024.2.3``.

  All the tarballs will be published with the build metadata showing
  the commit SHA sum with which the tarball is built. The tarball
  version will look like ``2025.1.X+<osh_commit_sha>_<osh_infra_commit_sha>``.

Implementation
==============

Assignee(s)
-----------

Primary assignees:
  kozhukalov (Vladimir Kozhukalov <kozhukalov@gmail.com>)

Work Items
----------

The following work items need to be completed for this specification to be
implemented.

Values overrides
~~~~~~~~~~~~~~~~
Move values_overrides from all charts to a separate directory ``values``
with the hierarchy ``values_overrides/<chart-name>/<feature1>_<feature2>.yaml``.
The Openstack-Helm plugin is able to lookup the overrides in an arbitrary directory,
but the directory structure must be as described above.

Update the version of all charts to ``2024.2.0``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
All the charts must be updated to the version ``2024.2.0`` in a single commit.
While developing the charts we will not change the version of the charts in
their Chart.yaml files in the git repo. So, in the git repos the versions
of all charts will be the same, e.g. ``2024.2.0``. It will be changed
twice a year when the Openstack is released and the version update
commit will be tagged appropriately.

However when we build a chart the tarball version will be updated every time.
The tarball version will be calculated automatically
``2024.2.X+<osh_commit_sha>_<osh_infra_commit_sha>`` where ``X`` is the number
of commits related to the chart after the latest tag.

.. code-block:: bash

    $ PATCH=$(git log --oneline <tag>.. <chart_directory> | wc -l)
    $ OSH_COMMIT_SHA=$(cd ${SRC}/openstack-helm; git rev-parse --short HEAD)
    $ OSH_INFRA_COMMIT_SHA=$(cd ${SRC}/openstack-helm-infra; git rev-parse --short HEAD)
    $ helm package <chart> --version 2024.2.${PATCH}+${OSH_COMMIT_SHA}_${OSH_INFRA_COMMIT_SHA}

.. note::
    When the chart itself is not changed but is re-built with the new version
    of the helm-toolkit, the PATCH will not be changed and the tarball will
    be published with the same version but with the new build metadata (``${OSH_INFRA_COMMIT_SHA}``).

Set git tag for the Openstack-Helm repositories
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
We will set the git tag ``2024.2.0`` for all the Openstack-Helm repositories.
These tags are set by means of submitting a patch to the openstack/releases
repository. Since that we will set such tag twice a year when the Openstack
is released.

Update ``apiVersion`` in ``Chart.yaml``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Update ``apiVersion`` to ``v2`` in all ``Chart.yaml`` files and
migrate the dependecies (helm-toolkit) from ``requirements.yaml``
to ``Chart.yaml``.

Reorganize the process of managing release notes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The Reno tool (a Python package used for managing release notes) can be used
in a way that allows to avoid merge conflicts for PRs that update the same chart.
It generates the release notes report using the git history.

We suggest the following workflow:

* When a chart is updated, the maintainer runs the ``reno new <chart>`` command to create
  a new release note file ``releasenotes/notes/<chart>-<hash>.yaml``.
* The maintainer fills in the new release note file with the necessary information.
* The maintainer commits the release note file.
* While building the tarball we will use ``reno report`` command with a custom script
  to generate the release notes report and automatically prepare
  the ``<chart>/CHANGELOG.md`` file.

Since we are not going to bump the chart version when we update it, all the
release notes will be bound to some git commits and we be put under the headers
that correspond to git tags.

The format of the ``CHANGELOG.md`` file:

.. code-block:: markdown

    ## X.Y.Z-<num_commits_after_X.Y.Z>

    - Some new update

    ## X.Y.Z

    - Some update
    - Previous update

Where ``X.Y.Z`` is the tag in the git repository and the ``X.Y.Z`` section contains
all the release notes made before the tag was set. The ``X.Y.Z-<num_commits_after_X.Y.Z>``
section contains all the release notes made after the tag was set.

At this point we have the only tag ``0.1.0``. So, when we set the ``2024.2.0`` tag almost all
the release notes will go to this tag and the ``CHANGELOG.md`` file. So it will look like:

.. code-block:: markdown

    ## 2024.2.0-<num_commits_after_2024.2.0>

    - Some new update

    ## 2024.2.0

    - Some update
    - Previous update

Update the versioning policy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* When the helm-toolkit chart is updated and tested with all other charts,
  we will re-build it and publish with the new version according to how it is
  described above.
  All other charts also will be re-built with this new version of
  helm-toolkit (inside) and published with the new build metadata (new ``$OSH_INFRA_COMMIT_SHA``).
  Helm-toolkit version will not be pinned in the charts.
* When a particular chart is changed, we will re-build and publish only this chart.
  So all charts will be built and published independently of each other.
  All the test jobs must be able to use updated chart from the PR with other
  charts taken from the public helm repository (tarballs).

Alternatively, we could pin the helm-toolkit version in the charts, but this would
make the maintenance of the charts more complicated.

Documentation Impact
====================

The user documentation must be updated and it must be emphasized that the chart version
is not equal to the Openstack release version and that the Openstack version is defined
by the images used with the charts. Also it must be explained that a particular version
like ``2024.2.X`` is compatible with those Openstack releases that were maintained at the time
``2024.2.X`` was built and published (i.e ``2023.1``, ``2023.2``, ``2024.1``, ``2024.2``).

.. _chart-testing: https://github.com/helm/chart-testing.git
