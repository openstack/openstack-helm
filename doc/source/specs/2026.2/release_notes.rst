===================================
Release Notes in the Chart Metadata
===================================

Problem Description
===================

Contributors record notes as `reno`_ files under ``releasenotes/notes``, one
YAML file per change, named ``<chart>-<hash>.yaml`` for a note about a single
chart or ``common-<hash>.yaml`` for a note about several. There are 545 such
files. At build time ``tools/changelog.py`` combines them into a
``<chart>/CHANGELOG.md`` that ships inside the chart tarball, as the
`chart versioning spec`_ for 2025.1 proposed.

Nothing consumes that file. Helm does not read it. The charts are published as
a Helm repository at ``https://tarballs.opendev.org/openstack/openstack-helm``,
and ``helm repo index`` builds its ``index.yaml`` from chart metadata, not from
the files inside a tarball, so a note never reaches a deployer who adds the
repository. The one place a release note could be read from is the only place
it is not written to.

Chart metadata does have an established place for this. The Helm ecosystem
carries per-version release notes in the ``artifacthub.io/changes`` annotation
of ``Chart.yaml``, a convention `defined by Artifact Hub`_ and used by the
Bitnami, argo-helm and prometheus-community charts. Its shape is sensible
independently of who consumes it: each chart version carries the changes that
version introduced, and a reader assembles a chart's changelog from the
versions it has. It is also plain chart metadata, which means
``helm repo index`` copies it into the published index alongside every version
it already lists, and ``helm show chart`` prints it from a tarball.

The source is awkward as well.

* A note lives in a file separate from the change that motivated it. The
  contributor has to remember to create it, choose a name for it and keep its
  contents in step with the commit it describes. Reno was adopted because a
  per-change file avoids the merge conflicts a single shared changelog would
  cause, which it does, but the cost is a second artifact per change.

* Which charts a note reaches is encoded in the file name, and the match is a
  prefix. A note named ``mariadb-backup-<hash>.yaml`` starts with ``mariadb``,
  so its contents appear under the mariadb chart as well as under
  mariadb-backup. The same happens for every chart whose name is a prefix of
  another, prometheus and the seven ``prometheus-*`` charts among them.

* A note whose name matches neither an existing chart nor ``common`` is
  dropped from every ``CHANGELOG.md`` without a word. The file still renders
  on the reno release notes site, so the mistake is invisible until someone
  compares the two.

Proposed Change
===============

Starting with the 2026.2 series, release notes are written as git trailers in
the commit that makes the change, and the build renders them into the
``artifacthub.io/changes`` annotation of ``Chart.yaml``. ``CHANGELOG.md`` and
``tools/changelog.py`` are removed.

The goal is to make the charts compatible with that annotation, not to publish
them anywhere new. Where the charts are published does not change, and whether
they are ever listed on Artifact Hub is a separate question. Adopting the
convention means the notes are carried in a form the ecosystem's tools already
understand, starting with the repository index the publishing job already
generates.

Release notes are written as commit message trailers
----------------------------------------------------

The commit message is the one place that already travels with the change,
survives a rebase, is reviewed alongside the diff and cannot conflict with
another contributor's commit message. Gerrit already relies on trailers for
``Change-Id``, and this repository's commits already carry ``Signed-off-by``,
``Task`` and ``Story``, so the mechanism needs no new tooling from a
contributor's point of view.

The Changelog trailer
~~~~~~~~~~~~~~~~~~~~~

A note is a ``Changelog:`` trailer in the last paragraph of the commit
message, where git recognises trailers::

    neutron: fix the health probe for the OVN agent

    health-probe.py picks its check from the configuration file name it is
    given, and the ovn-agent daemonset passes ovn_agent.ini, which matched
    neither sriov_agent.ini nor metadata_agent.ini.

    Changelog: fixed
    Change-Id: I7d940919531125e2806b18fcb6cfe245d6b31450

The value is one of the change kinds the annotation defines, or ``skip``:

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Kind
     - Use for
   * - ``added``
     - New functionality, new values, new templates.
   * - ``changed``
     - Behaviour changes, upgrade notes, changes to the values schema.
   * - ``deprecated``
     - Functionality still present but on its way out.
   * - ``removed``
     - Functionality that is gone.
   * - ``fixed``
     - Bug fixes.
   * - ``security``
     - Fixes for security issues.
   * - ``skip``
     - Not a kind. States that the change deliberately needs no release note.

Without a description the commit subject becomes the note. A description is
given after a second colon when the subject is not what a deployer needs to
read, and the trailer repeats when one commit does several things::

    Changelog: added: The probes can now be tuned under pod.probes
    Changelog: fixed: The OVN agent is probed through its metadata socket

The ``Change-Id`` of the commit becomes a link on every note it produces, so
each entry points back at the review that introduced it.

Notes longer than a line
~~~~~~~~~~~~~~~~~~~~~~~~

A trailer is one logical line, but it does not have to be written as one.
Continuation lines indented by at least one space or a tab belong to the
trailer above them, so a long note is wrapped the way the rest of the commit
message is::

    Changelog: fixed: The OVN agent is probed through its metadata socket
      rather than through the RPC queue, which it never had. Deployments
      running the agent with other extensions should disable the probe.
    Change-Id: I7d940919531125e2806b18fcb6cfe245d6b31450

Git folds those lines back together before anything reads them, joining them
with a single space, so the note above is one paragraph::

    The OVN agent is probed through its metadata socket rather than through
    the RPC queue, which it never had. Deployments running the agent with
    other extensions should disable the probe.

The length is unlimited, but the line breaks are not preserved: a note is a
paragraph of prose, and a blank line, a bullet list or a block of YAML written
inside a trailer does not survive. A note that genuinely has parts is written
as several trailers instead, which reads better anyway because each part
carries its own kind::

    Changelog: changed: Ingress objects are replaced by Gateway API resources
    Changelog: removed: The manifests.ingress and endpoints.ingress values

**The indentation is what makes a continuation a continuation.** Git
recognises trailers only in the last paragraph of the message, so a
continuation line that starts at column zero, or a blank line in the middle of
the block, ends the block: every trailer after that point is lost, and the
note disappears without a word. The check job described below tests for this
and rejects the commit, and the reno notes that carry a multi-paragraph
description are rendered as YAML literal blocks, so the annotation format
itself places no limit here. The limit is git's.

Which charts a note reaches
~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default a note reaches the charts whose directories the commit touches. A
commit that only changes ``roles``, ``playbooks``, ``tools``, ``zuul.d`` or
``doc`` touches no chart, produces no note and therefore needs no trailer at
all. This is the common case and it needs no thought from the contributor.

A ``Charts:`` trailer overrides the default::

    Charts: barbican, keystone
    Charts: all
    Charts: none

``all`` fans the note out to every chart, which is what a change affecting all
of them uses. ``none`` suppresses routing. Note that a change to
``helm-toolkit`` infers ``helm-toolkit`` alone; a change visible to the charts
that vendor it says so with ``Charts: all``.

Unlike the file name rule it replaces, this is an explicit list rather than a
prefix match, so mariadb-backup and mariadb are distinct and a typo is an
error rather than a silently misrouted note.

Validating the trailers
~~~~~~~~~~~~~~~~~~~~~~~

A check pipeline job validates the trailers of the change under review and
fails when:

* a commit changes a chart directory but carries no ``Changelog:`` trailer,
  and has not opted out with ``Changelog: skip``;
* a trailer names a kind that is not in the table above;
* a ``Charts:`` trailer names a chart that does not exist, or mixes ``all`` or
  ``none`` with chart names;
* a ``Changelog:`` line appears outside the trailer block, where git does not
  recognise it and the note would be silently lost;
* a ``Changelog:`` trailer would reach no chart at all, because the commit
  touches no chart directory and names none.

The job runs the same parser the build runs, so what it validates is exactly
what the build later collects. It has no ``irrelevant-files``: a change that
touches no chart still has to be free of stray trailers.

Chart versions are bumped twice a year
--------------------------------------

In the git repository every ``Chart.yaml`` carries the version of the series,
``2026.2.0`` from this series onward, and it is never bumped by an individual
change. The version is raised once per OpenStack release, for every chart at
once, and tracks the OpenStack version, so 2027.1 charts carry ``2027.1.0``.
A contributor changing a chart does not touch its ``version`` field, which is
what keeps concurrent changes from conflicting over it.

The published version is computed at build time and is unchanged from what
``tools/chart_version.sh`` computes today::

    2026.2.<X>+<sha>

``<X>`` is the number of commits since the ``2026.2.0`` tag that touched the
chart, and ``<sha>`` is the most recent of those commits, abbreviated to nine
characters. A chart that vendors ``helm-toolkit`` counts commits touching
``helm-toolkit`` as well, because helm-toolkit is packaged into the tarball
and a chart whose contents changed has to get a new version. The version is a
function of the chart's own history and of nothing else, so it does not depend
on which commit the publishing job happens to run at.

The build renders the notes into Chart.yaml
-------------------------------------------

Before ``helm package`` runs, the build writes the notes belonging to the
version being built into ``Chart.yaml``:

.. code-block:: yaml

    annotations:
      artifacthub.io/changes: |
        - kind: fixed
          description: 'neutron: fix the health probe for the OVN agent'
          links:
            - name: Gerrit change
              url: https://review.opendev.org/q/I7d940919531125e2806b18fcb6cfe245d6b31450

The ``links`` list is the per-change one the annotation defines, not the
chart-level ``artifacthub.io/links`` annotation, which is a different key with
a different purpose and is not used here. Descriptions are emitted by a YAML
writer rather than by string formatting, which is what quotes a subject such
as ``neutron: fix ...`` that would otherwise not be a valid plain scalar.

The annotation is build output, not source. It is written into the working
copy only for as long as it takes to package the chart and the file is
restored afterwards, so a build leaves no modification behind. Nothing about
release notes is ever committed to ``Chart.yaml``.

Because it is chart metadata rather than a packaged file, the publishing job
carries it further without any change: ``helm repo index`` copies annotations
into the ``index.yaml`` entry it writes for the version, and that index is
merged into the published one. The repository at
``https://tarballs.opendev.org/openstack/openstack-helm`` therefore accumulates
one set of release notes per chart version, which is what any consumer of the
convention reads.

The 2026.2.0 rebuild renders the whole history
----------------------------------------------

Every version already in the published index carries no annotation, so the
notes that belong to those versions have no version left to ride on.
Publishing only new notes from now on would leave the accumulated history
unreachable.

The bump to ``2026.2.0`` is therefore also a migration. When all 80 charts are
bumped to ``2026.2.0`` and re-published, each chart is built with the full
range rather than an incremental one, and its annotation carries **every**
release note that has ever applied to it: the trailers of the 2026.2 series
and the legacy reno notes that precede them. Version ``2026.2.0`` of each
chart is the version that carries the complete changelog.

This is a one-off, driven by an explicit range passed to the build tool as
part of the release procedure rather than by a rule the tool infers. It
happens once, at this series boundary, because this is the boundary at which
annotations begin. Later series bumps are ordinary: ``2027.1.0`` continues
from the last version published in 2026.2 and does not repeat its history.

Later builds render only what the version adds
----------------------------------------------

After ``2026.2.0``, a build renders only the notes belonging to the version
being built: the commits between the previous version of the chart and this
one. In the normal case that is exactly the one commit that triggered the
build, so the annotation holds the one or two entries that commit declared.

Stating the boundaries the same way the version does is what makes this
correct. A version is bounded by two of the commits ``tools/chart_version.sh``
counts: the newest is this version's commit, and the one before it produced
the previous version. Consecutive versions therefore partition the history and
every commit falls inside exactly one version, so a reader assembling a
chart's changelog from the versions in the index sees every note exactly once.
The two tools have to agree on those boundaries, so they derive them the same
way, including the helm-toolkit paths.

A note routed to a chart the commit did not touch, through ``Charts: all`` for
instance, does not bump that chart's version and does not by itself cause the
chart to be rebuilt. It is carried by the next version of that chart, which is
the first version that can hold it.

The legacy reno notes
---------------------

The files under ``releasenotes/notes`` are frozen. No new ones are written,
and removing reno removes ``reno new`` along with it, so there is no longer a
way to add one by accident.

They are still read, so nothing already written is lost. A note is attributed
to the commit that added it, which is what places it in the right version, and
it is routed to charts by its file name with the prefix bug fixed: a file
belongs to the chart whose name is the longest chart name the file name starts
with, so ``mariadb-backup-<hash>.yaml`` belongs to mariadb-backup rather than
to mariadb. A ``common-<hash>.yaml`` note reaches every chart, and a section
named after a chart reaches that chart whatever the file is called, so notes
that were routed by their contents rather than their name keep working.

Their sections map onto the Artifact Hub kinds:

.. list-table::
   :header-rows: 1
   :widths: 30 30 40

   * - reno section
     - Artifact Hub kind
     - Notes
   * - ``features``
     - ``added``
     -
   * - ``fixes``
     - ``fixed``
     -
   * - ``security``
     - ``security``
     -
   * - ``upgrade``
     - ``changed``
     - Artifact Hub has no upgrade kind.
   * - ``api``
     - ``changed``
     -
   * - ``issues``
     - ``changed``
     - Artifact Hub has no known-issues kind.
   * - ``<chart>``
     - ``changed``
     - A section named after a chart.

The 545 note files are kept exactly as they are. Nothing is rewritten, renamed
or migrated into trailers, and no note is deleted: the build reads them where
they sit, so a note written years ago still reaches the chart it was written
for.

Reno itself goes. The release notes site that ``tox -e releasenotes`` builds
from ``releasenotes/source`` and publishes to docs.openstack.org would freeze
at the last reno note, and it duplicates what a chart's own metadata now
carries. The ``releasenotes`` tox environment, the
``release-notes-jobs-python3`` job template, ``releasenotes/source``,
``releasenotes/config.yaml``, ``releasenotes/requirements.txt`` and the reno
requirement in ``doc/requirements.txt`` are removed. What remains under
``releasenotes`` is ``notes`` and nothing else, read by the chart build alone.

Implementation
==============

Assignee(s)
-----------

Primary assignee:
  kozhukalov

Work Items
----------

#. Add the trailer parser, the chart routing and the legacy reno note reader
   as a module shared by the build tool and the check job.
#. Add the tool that renders the ``artifacthub.io/changes`` annotation into
   ``Chart.yaml``, deriving the version boundaries the same way
   ``tools/chart_version.sh`` derives the version, and restoring the file
   after packaging.
#. Add the commit message check job to the check and gate pipelines.
#. Remove ``tools/changelog.py``, the ``CHANGELOG.md`` make target and the
   ``SKIP_CHANGELOG`` switch, and drop reno from the chart build.
#. Remove reno from the repository: the ``releasenotes`` tox environment, the
   ``release-notes-jobs-python3`` template, ``releasenotes/source``,
   ``releasenotes/config.yaml``, ``releasenotes/requirements.txt`` and the
   reno requirement in ``doc/requirements.txt``. Leave ``releasenotes/notes``
   untouched.
#. Rewrite the release notes section of ``README.rst`` around the trailer
   format and add a contributor document describing it.
#. At the 2026.2.0 bump, set every ``Chart.yaml`` to ``2026.2.0``, tag the
   repository and re-publish all 80 charts with the full range so that each
   carries its complete history.

Alternatives
------------

**Keep reno and write the annotation from the note files.** This fixes the
destination but not the source: a contributor still writes a second file per
change and still routes it by naming it correctly. It also keeps a section
vocabulary that has to be translated into Artifact Hub's.

**Write the annotation into Chart.yaml by hand**, as the Bitnami and
argo-helm charts do. This is the ecosystem's common practice and needs no
tooling at all, but ``Chart.yaml`` is a single file per chart, so two
concurrent changes to the same chart conflict over it. Avoiding exactly that
is why this repository moved to reno in the first place. It works for Bitnami
because a bot writes the annotation rather than a person.

**Derive the notes from the commit subject alone**, with no trailer. This
removes the contributor's work entirely but also removes their judgement: every
commit would produce an entry, including whitespace and test-only changes, and
nothing would distinguish a fix from a removal.

**Conventional Commits**, encoding the kind and the chart in the subject as
``fix(neutron): ...``. Compact and widely understood, but it rewrites the
subject line convention of the whole project, carries one entry per commit,
and expresses a multi-chart change awkwardly.

**Publish a full changelog with every version** rather than partitioning the
history. A reader assembling the changelog across versions would see every
entry repeated once per version, and the index would grow with the square of
the number of releases.

Documentation Impact
====================

The release notes section of ``README.rst`` is rewritten around the trailer
format. A contributor document under ``doc/source/devref`` describes the
trailers, the routing rules, how to validate a commit before pushing and how
the legacy reno notes are still read. The 2025.1 `chart versioning spec`_
keeps its versioning decisions; its release notes section, which proposed
``CHANGELOG.md``, is superseded by this one.

References
==========

* `Artifact Hub annotations in Helm Chart.yaml
  <https://artifacthub.io/docs/topics/annotations/helm/>`_, which defines the
  ``artifacthub.io/changes`` format and its change kinds
* `The OpenStack-Helm chart repository
  <https://tarballs.opendev.org/openstack/openstack-helm>`_
* `reno, the OpenStack release notes manager
  <https://docs.openstack.org/reno/latest/>`_
* `Chart versioning spec, 2025.1
  <https://docs.openstack.org/openstack-helm/latest/specs/2025.1/chart_versioning.html>`_

.. _reno: https://docs.openstack.org/reno/latest/
.. _defined by Artifact Hub: https://artifacthub.io/docs/topics/annotations/helm/
.. _chart versioning spec: https://docs.openstack.org/openstack-helm/latest/specs/2025.1/chart_versioning.html
