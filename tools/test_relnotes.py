"""Unit tests for the release note tooling.

    python3 -m unittest discover -s tools -p 'test_*.py'
"""

import os
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import chart_annotations  # noqa: E402
import check_commit_message  # noqa: E402
import relnotes  # noqa: E402

CHARTS = [
    "barbican",
    "ceph-mon",
    "helm-toolkit",
    "mariadb",
    "mariadb-backup",
    "mariadb-cluster",
    "neutron",
    "nova",
    "prometheus",
    "prometheus-kube-state-metrics",
]


class NoteOwnerTest(unittest.TestCase):
    def owner(self, name):
        return relnotes.note_owner(name, CHARTS)

    def test_bare_chart_name(self):
        self.assertEqual(self.owner("neutron.yaml"), "neutron")

    def test_reno_hash_suffix(self):
        self.assertEqual(self.owner("neutron-00a56405067b123d.yaml"), "neutron")

    def test_descriptive_suffix(self):
        self.assertEqual(
            self.owner("barbican-drop-endpoint-tls-95b9ce8b3616d0df.yaml"),
            "barbican",
        )

    def test_longest_chart_name_wins(self):
        # The prefix match that made mariadb swallow mariadb-backup's notes.
        self.assertEqual(
            self.owner("mariadb-backup-58c8a77f9c03bae8.yaml"), "mariadb-backup"
        )
        self.assertEqual(
            self.owner("prometheus-kube-state-metrics-bf96b36233c397a4.yaml"),
            "prometheus-kube-state-metrics",
        )

    def test_unknown_suffix_falls_back_to_the_chart(self):
        self.assertEqual(self.owner("mariadb-crd-9f2b7c48ad51e630.yaml"), "mariadb")

    def test_common(self):
        self.assertEqual(self.owner("common-8730c7058550f934.yaml"), "common")
        self.assertEqual(self.owner("common.yaml"), "common")

    def test_unrelated(self):
        self.assertIsNone(self.owner("something-else.yaml"))


class NoteEntriesTest(unittest.TestCase):
    def entries(self, content, owner, chart, aggregate=False):
        return [
            (entry.kind, entry.description)
            for entry in chart_annotations.note_entries(
                content, owner, chart, CHARTS, aggregate=aggregate
            )
        ]

    def test_aggregate_note_is_reversed(self):
        # The pre-2024.2.0 per-chart changelogs run oldest first, the
        # annotation newest first.
        content = (
            "neutron:\n"
            "  - 0.1.0 Initial Chart\n"
            "  - 0.1.1 Second thing\n"
            "  - 0.1.2 Third thing\n"
        )
        self.assertEqual(
            [description for _, description in
             self.entries(content, "neutron", "neutron", aggregate=True)],
            ["0.1.2 Third thing", "0.1.1 Second thing", "0.1.0 Initial Chart"],
        )

    def test_a_reno_note_keeps_the_order_it_was_written_in(self):
        content = "fixes:\n  - First point\n  - Second point\n"
        self.assertEqual(
            [description for _, description in
             self.entries(content, "neutron", "neutron")],
            ["First point", "Second point"],
        )

    def test_aggregates_are_recognised_by_name(self):
        self.assertTrue(relnotes.is_aggregate_note("neutron.yaml", CHARTS))
        self.assertTrue(relnotes.is_aggregate_note("mariadb-backup.yaml", CHARTS))
        self.assertFalse(
            relnotes.is_aggregate_note("neutron-00a56405067b123d.yaml", CHARTS)
        )
        self.assertFalse(relnotes.is_aggregate_note("common-abc.yaml", CHARTS))

    def test_sections_map_onto_artifacthub_kinds(self):
        content = "features:\n  - New thing\nfixes:\n  - Fixed thing\n"
        self.assertEqual(
            self.entries(content, "neutron", "neutron"),
            [("added", "New thing"), ("fixed", "Fixed thing")],
        )

    def test_upgrade_and_api_become_changed(self):
        content = "upgrade:\n  - Upgrade note\napi:\n  - Values moved\n"
        self.assertEqual(
            self.entries(content, "neutron", "neutron"),
            [("changed", "Upgrade note"), ("changed", "Values moved")],
        )

    def test_generic_sections_stay_with_the_owning_chart(self):
        content = "fixes:\n  - Backup fix\n"
        self.assertEqual(self.entries(content, "mariadb-backup", "mariadb"), [])
        self.assertEqual(
            self.entries(content, "mariadb-backup", "mariadb-backup"),
            [("fixed", "Backup fix")],
        )

    def test_common_note_reaches_every_chart(self):
        content = "fixes:\n  - Shared fix\n"
        self.assertEqual(
            self.entries(content, "common", "nova"), [("fixed", "Shared fix")]
        )

    def test_chart_section_reaches_that_chart_from_any_file(self):
        # A mariadb: section inside a mariadb-backup note still reaches mariadb.
        content = "mariadb:\n  - Cross referenced\n"
        self.assertEqual(
            self.entries(content, "mariadb-backup", "mariadb"),
            [("changed", "Cross referenced")],
        )
        self.assertEqual(self.entries(content, "mariadb-backup", "nova"), [])

    def test_empty_note(self):
        self.assertEqual(self.entries("", "neutron", "neutron"), [])


class TrailerTest(unittest.TestCase):
    def test_kind_only_takes_the_subject(self):
        message = "neutron: fix the probe\n\nBody.\n\nChangelog: fixed\n"
        entries, charts, change_id = relnotes.parse_changelog_trailers(message)
        self.assertEqual(entries, [("fixed", "neutron: fix the probe")])
        self.assertIsNone(charts)
        self.assertIsNone(change_id)

    def test_explicit_description(self):
        message = "subject\n\nChangelog: added: A brand new knob\n"
        entries, _, _ = relnotes.parse_changelog_trailers(message)
        self.assertEqual(entries, [("added", "A brand new knob")])

    def test_several_entries_and_metadata(self):
        message = (
            "subject\n"
            "\n"
            "Body.\n"
            "\n"
            "Changelog: added: One\n"
            "Changelog: fixed: Two\n"
            "Charts: neutron, nova\n"
            "Change-Id: I0123456789abcdef\n"
        )
        entries, charts, change_id = relnotes.parse_changelog_trailers(message)
        self.assertEqual(entries, [("added", "One"), ("fixed", "Two")])
        self.assertEqual(charts, "neutron, nova")
        self.assertEqual(change_id, "I0123456789abcdef")

    def test_trailer_outside_the_block_is_not_parsed(self):
        message = "subject\n\nChangelog: fixed\nProse follows the trailer.\n"
        entries, _, _ = relnotes.parse_changelog_trailers(message)
        self.assertEqual(entries, [])


class UnparsedTrailersTest(unittest.TestCase):
    """A trailer git cannot see is an error; a wrapped note is not."""

    def problems(self, message):
        return check_commit_message.unparsed_trailers(
            message, relnotes.parse_trailers(message)
        )

    def test_wrapped_note_beginning_with_a_trailer_name_is_fine(self):
        message = (
            "neutron: fix the probe\n"
            "\n"
            "Body.\n"
            "\n"
            "Changelog: fixed: see below\n"
            "  Charts: ovn and friends are affected\n"
            "Change-Id: I0123456789abcdef\n"
        )
        self.assertEqual(self.problems(message), [])

    def test_trailer_at_column_zero_outside_the_block_is_reported(self):
        message = (
            "neutron: fix the probe\n"
            "\n"
            "Changelog: fixed\n"
            "prose at column zero ends the trailer block\n"
        )
        self.assertEqual(self.problems(message), [relnotes.CHANGELOG_TRAILER])


class NotePrecedenceTest(unittest.TestCase):
    """A reno note wins over whatever the commit message says.

    A change carrying both would otherwise be announced twice, once in the
    note's words and once in the subject's. The note is the one written for a
    deployer to read.
    """

    NOTE = "magnum:\n  - |\n    The domain ks-user job now requests CPU and memory.\n"

    def collect(self, message, note=None):
        """What collect() would keep for magnum from one commit."""
        entries, _, _, _ = relnotes.release_notes_of(message)
        from_note = (
            chart_annotations.note_entries(note, "magnum", "magnum", CHARTS)
            if note else []
        )
        if from_note:
            return [(e.kind, e.description) for e in from_note]
        return [(k, d) for k, d in entries if k in relnotes.KINDS]

    def test_note_wins_over_an_inferred_subject(self):
        self.assertEqual(
            self.collect("fix(magnum): size the domain ks-user job\n", self.NOTE),
            [("changed", "The domain ks-user job now requests CPU and memory.")],
        )

    def test_note_wins_over_an_explicit_trailer(self):
        message = "magnum: size the job\n\nBody.\n\nChangelog: fixed: Sized the job\n"
        self.assertEqual(
            self.collect(message, self.NOTE),
            [("changed", "The domain ks-user job now requests CPU and memory.")],
        )

    def test_without_a_note_the_message_is_used(self):
        self.assertEqual(
            self.collect("fix(magnum): size the domain ks-user job\n"),
            [("fixed", "size the domain ks-user job")],
        )


class ConventionalSubjectTest(unittest.TestCase):
    """A Conventional Commits subject already names the kind, so a commit
    written that way needs no Changelog: trailer to repeat it."""

    def notes(self, subject, body=""):
        message = subject + "\n\nSome body.\n" + body
        entries, _, _, inferred = relnotes.release_notes_of(message)
        return entries, inferred

    def test_kind_is_taken_from_the_type(self):
        self.assertEqual(
            self.notes("fix(nova): Bla-bla-bla"),
            ([("fixed", "Bla-bla-bla")], True),
        )
        self.assertEqual(
            self.notes("feat(neutron): add a knob")[0], [("added", "add a knob")]
        )
        for subject, kind in (
            ("refactor(cinder): tidy up", "changed"),
            ("perf(glance): fewer calls", "changed"),
            ("revert(ovn): back it out", "changed"),
        ):
            self.assertEqual(self.notes(subject)[0][0][0], kind)

    def test_the_type_prefix_is_not_part_of_the_note(self):
        (_, description), = self.notes("fix(nova): Bla-bla-bla")[0]
        self.assertEqual(description, "Bla-bla-bla")

    def test_a_scope_is_not_required(self):
        self.assertEqual(self.notes("fix: a thing")[0], [("fixed", "a thing")])

    def test_breaking_marker_is_a_change(self):
        self.assertEqual(
            self.notes("feat(nova)!: drop a value")[0], [("changed", "drop a value")]
        )

    def test_types_with_nothing_to_tell_a_deployer_are_silent(self):
        for subject in ("ci(zuul): bump the nodeset", "docs: fix a typo",
                        "chore: tidy", "test(nova): add a case"):
            entries, _ = self.notes(subject)
            self.assertEqual([kind for kind, _ in entries], [relnotes.SKIP], subject)

    def test_the_repos_other_subject_style_is_not_conventional(self):
        # "neutron: ..." has the same shape but a chart name is not a kind.
        for subject in ("neutron: fix the health probe",
                        "[ceph] Update image references",
                        "Bump all charts to 2026.2.0"):
            self.assertEqual(self.notes(subject), ([], False), subject)

    def test_an_explicit_trailer_wins(self):
        entries, inferred = self.notes(
            "fix(nova): Bla-bla-bla", "\nChangelog: security: Base image bumped\n"
        )
        self.assertEqual(entries, [("security", "Base image bumped")])
        self.assertFalse(inferred)

    def test_skip_suppresses_the_inferred_note(self):
        entries, _ = self.notes("fix(nova): Bla-bla-bla", "\nChangelog: skip\n")
        self.assertEqual([kind for kind, _ in entries], [relnotes.SKIP])

    def test_a_bare_trailer_also_drops_the_prefix(self):
        entries, _ = self.notes("fix(nova): Bla-bla-bla", "\nChangelog: fixed\n")
        self.assertEqual(entries, [("fixed", "Bla-bla-bla")])


class RoutingTest(unittest.TestCase):
    def test_charts_from_files(self):
        files = [
            "neutron/values.yaml",
            "roles/deploy-env/tasks/main.yaml",
            "tools/chart_annotations.py",
            "nova/templates/deployment.yaml",
        ]
        self.assertEqual(
            relnotes.charts_from_files(files, CHARTS), {"neutron", "nova"}
        )

    def test_non_chart_files_route_nowhere(self):
        files = ["doc/source/index.rst", "zuul.d/base.yaml"]
        self.assertEqual(relnotes.charts_from_files(files, CHARTS), set())

    def test_explicit_spec(self):
        self.assertEqual(
            relnotes.target_charts(None, "neutron, nova", CHARTS), {"neutron", "nova"}
        )
        self.assertEqual(relnotes.target_charts(None, "all", CHARTS), set(CHARTS))
        self.assertEqual(relnotes.target_charts(None, "none", CHARTS), set())


class VersionPathsTest(unittest.TestCase):
    """A chart's notes are bounded by the same paths its version counts,
    so a helm-toolkit bump does not republish notes already published."""

    def setUp(self):
        self.repo = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, self.repo)
        for name, deps in (
            ("dependent", "dependencies:\n  - name: helm-toolkit\n"),
            ("standalone", ""),
            ("helm-toolkit", ""),
        ):
            os.mkdir(os.path.join(self.repo, name))
            with open(os.path.join(self.repo, name, "Chart.yaml"), "w") as handle:
                handle.write("name: %s\n%s" % (name, deps))

    def paths(self, chart):
        return chart_annotations.version_paths(chart, repo=self.repo)

    def test_dependent_chart_is_bounded_by_helm_toolkit_too(self):
        self.assertEqual(self.paths("dependent"), ["dependent", "helm-toolkit"])

    def test_standalone_chart_is_bounded_by_itself(self):
        self.assertEqual(self.paths("standalone"), ["standalone"])

    def test_helm_toolkit_does_not_list_itself_twice(self):
        self.assertEqual(self.paths("helm-toolkit"), ["helm-toolkit"])


FIXTURE = """\
# Licensed under the Apache License, Version 2.0

---
apiVersion: v2
name: neutron
version: 2026.1.0
dependencies:
  - name: helm-toolkit
    repository: file://../helm-toolkit
...
"""


class UpsertTest(unittest.TestCase):
    KEY = chart_annotations.ANNOTATION_KEY

    def upsert(self, text, value):
        out = chart_annotations.upsert_annotation(text, self.KEY, value)
        chart_annotations.verify(out, self.KEY, value, "<test>")
        return out

    def test_inserts_before_the_document_end_marker(self):
        out = self.upsert(FIXTURE, "- kind: fixed\n  description: Thing\n")
        self.assertIn("annotations:", out)
        self.assertTrue(out.rstrip().endswith("..."))
        self.assertIn("# Licensed under the Apache License", out)

    def test_is_idempotent(self):
        value = "- kind: fixed\n  description: Thing\n"
        once = self.upsert(FIXTURE, value)
        twice = self.upsert(once, value)
        self.assertEqual(once, twice)

    def test_replaces_a_stale_value(self):
        first = self.upsert(FIXTURE, "- kind: fixed\n  description: Old\n")
        second = self.upsert(first, "- kind: added\n  description: New\n")
        self.assertIn("New", second)
        self.assertNotIn("Old", second)

    def test_keeps_other_annotations(self):
        text = FIXTURE.replace(
            "...\n",
            "annotations:\n"
            "  artifacthub.io/signKey: |\n"
            "    fingerprint: DEADBEEF\n"
            "...\n",
        )
        out = self.upsert(text, "- kind: fixed\n  description: Thing\n")
        self.assertIn("artifacthub.io/signKey", out)
        self.assertIn("fingerprint: DEADBEEF", out)

    def test_without_a_document_end_marker(self):
        out = self.upsert(
            FIXTURE.replace("...\n", ""), "- kind: fixed\n  description: Thing\n"
        )
        self.assertIn("annotations:", out)


class RenderTest(unittest.TestCase):
    def test_multi_line_description_uses_a_literal_block(self):
        entry = relnotes.Entry("fixed", "First line.\nSecond line.")
        rendered = chart_annotations.render([entry])
        self.assertIn("description: |-", rendered)

    def test_links(self):
        entry = relnotes.Entry(
            "fixed", "Thing", relnotes.gerrit_links("I0123456789abcdef")
        )
        rendered = chart_annotations.render([entry])
        self.assertIn("https://review.opendev.org/q/I0123456789abcdef", rendered)

    def test_trailing_whitespace_is_stripped(self):
        entry = relnotes.Entry("fixed", "Line one.   \nLine two.\n")
        rendered = chart_annotations.render([entry])
        self.assertNotIn("   \n", rendered)


if __name__ == "__main__":
    unittest.main()
