Release Notes
=============

Release notes for charts are written as git trailers in the commit that makes
the change. At build time they are collected into the
``artifacthub.io/changes`` annotation of the chart's ``Chart.yaml``, which
`Artifact Hub <https://artifacthub.io/docs/topics/annotations/helm/>`_ turns
into a changelog spanning every published version of the chart.

Nothing is generated into the git tree: the annotation is written into
``Chart.yaml`` only for as long as it takes ``helm package`` to run, and the
file is restored afterwards.

Writing a release note
----------------------

Add a ``Changelog:`` trailer to the last paragraph of the commit message, next
to ``Change-Id``::

    neutron: fix the health probe for the OVN agent

    health-probe.py picks its check from the configuration file name it is
    given, and the ovn-agent daemonset passes ovn_agent.ini, which matched
    neither sriov_agent.ini nor metadata_agent.ini.

    Changelog: fixed
    Change-Id: I7d940919531125e2806b18fcb6cfe245d6b31450

The trailer takes one of the change kinds Artifact Hub understands:

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
     - Not a kind: states that the commit deliberately needs no release note.

Without a description the commit subject becomes the release note. Give a
description when the subject is not what a deployer needs to read::

    Changelog: fixed: Restart the DHCP agent cleanly when its configuration changes

Repeat the trailer to attach several notes to one commit::

    Changelog: added: The probes can now be tuned under pod.probes
    Changelog: fixed: The OVN agent is probed through its metadata socket

Which charts a note reaches
---------------------------

By default a note goes to the charts whose directories the commit touches. A
commit that only changes ``roles``, ``playbooks``, ``tools``, ``zuul.d`` or
``doc`` touches no chart and therefore produces no release note at all, which
is why such a commit needs no ``Changelog:`` trailer.

Use a ``Charts:`` trailer when the default is wrong::

    Charts: barbican, keystone
    Charts: all
    Charts: none

``all`` fans the note out to every chart, which is what a change affecting all
of them should use. ``none`` suppresses routing entirely. Note that changing
``helm-toolkit`` infers ``helm-toolkit`` alone: if the change is visible to the
charts that depend on it, say so with ``Charts: all``.

A commit that changes a chart must either carry a ``Changelog:`` trailer or opt
out explicitly::

    Changelog: skip

Use ``skip`` for changes with nothing to tell a deployer: whitespace, comments,
test-only changes, or a fix to an unreleased change earlier in the same series.

Checking before you push
------------------------

The ``openstack-helm-release-notes`` job validates the trailers of every
change. Run the same check locally against the commit you are about to push::

    python3 tools/check_commit_message.py

To see the annotation a chart would ship::

    python3 tools/chart_annotations.py --charts neutron \
        --base-version 2026.1.0 --dry-run

Common failures are a ``Changelog:`` line written in the middle of the message
rather than in the trailer block, where git does not recognise it, and a
``Changelog:`` trailer on a commit that touches no chart directory and names
none with ``Charts:``, where the note would reach nothing.

Which notes end up in which version
-----------------------------------

A chart's version counts the commits that touched it, and the commits that
touched ``helm-toolkit`` when it depends on it, since helm-toolkit is vendored
into the tarball. A version is bounded by two of those commits: the newest is
the version's own, and the one before it produced the previous version.
Consecutive versions therefore partition the history, and since Artifact Hub
concatenates the annotations of every published version, each note appears
exactly once. ``tools/chart_version.sh`` and ``tools/chart_annotations.py``
have to agree on those boundaries, so they derive them the same way.

A note routed to a chart the commit did not touch, through ``Charts: all`` for
instance, does not bump that chart's version. It is carried by the next
version of the chart, the first one that can hold it.

At the series bump
------------------

Chart versions are raised once per OpenStack release, for every chart at
once, by a single commit that sets ``version:`` in all of the ``Chart.yaml``
files and ``BASE_VERSION`` in the ``Makefile``. That commit is then tagged
with the new version, as ``2026.1.0`` tags the commit that introduced it.

Because every chart's version changes in that one commit, every chart is
republished from it, and that is the only moment at which the whole history
can be attached to a version. The same commit therefore also sets::

    chart_full_annotations: 1

in the ``vars`` of ``zuul.d/project.yaml``. The publish job passes it through
to ``make`` as ``FULL_ANNOTATIONS``, and each chart's first version in the new
series carries every release note it has ever had, the frozen reno notes
included, rather than only the notes of that version. A follow-up commit sets
it back to ``0`` so that later versions carry only their own notes again.

The full render does not depend on the tag, so it is correct on the publish
run that follows the bump commit even though the tag can only be pushed once
that commit has merged. The tag matters from the next commit onward, when it
starts the patch count for the series.

To see what a chart would ship before committing to any of this::

    python3 tools/chart_annotations.py --charts neutron \
        --base-version 2026.2.0 --full --dry-run

Legacy reno notes
-----------------

Release notes used to be written as reno note files under
``releasenotes/notes``. Those files are frozen but still read: a note is
attributed to the commit that added it and routed to charts by its file name,
so it appears in the same version it always would have. Their sections map
onto the Artifact Hub kinds as follows.

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

A note file belongs to the chart whose name is the longest chart name its file
name starts with, so ``mariadb-backup-<hash>.yaml`` belongs to mariadb-backup
rather than to mariadb. A ``common-<hash>.yaml`` note reaches every chart, and
a section named after a chart reaches that chart whatever the file is called.

Notes were not always written one file per change. Before 2024.2.0 each chart
had a single file named after it, ``releasenotes/notes/<chart>.yaml``, holding
every version that chart had ever had, oldest first::

    neutron:
      - 0.1.0 Initial Chart
      - 0.1.1 Change helm-toolkit dependency version to ">= 0.1.0"

Seventy-five of those remain. They are a changelog in their own right and run
the opposite way round to the annotation, which is newest first, so their
entries are reversed when they are rendered: ``0.3.50`` appears above
``0.1.0``. A note file with a hash in its name describes one change and its
items have no chronology, so those keep the order they were written in.

There is no way to write a new reno note, because reno is gone. The
``releasenotes`` tox environment, the release notes site it built from
``releasenotes/source``, ``releasenotes/config.yaml`` and the reno requirement
were all removed along with ``tools/changelog.py``; ``releasenotes/notes`` is
all that is left under that directory, and the chart build is the only thing
that reads it. Charts no longer carry a ``CHANGELOG.md`` either: the
annotation is the only release note metadata a chart ships.
