"""Validate the release note trailers of a commit message.

Release notes for charts are written as git trailers and collected at build
time by tools/chart_annotations.py. This check runs in the gate so that a
malformed or missing trailer is caught while it can still be fixed, rather
than silently producing an empty changelog months later.

Run it locally against the commit you are about to push:

    python3 tools/check_commit_message.py
"""

import argparse
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import relnotes  # noqa: E402

HELP = """
Release notes are written as git trailers in the last paragraph of the commit
message, next to Change-Id:

    neutron: fix the health probe for the OVN agent

    <body>

    Changelog: fixed
    Change-Id: I7d940919531125e2806b18fcb6cfe245d6b31450

    Changelog: <kind>[: <description>]
        <kind> is one of {kinds},
        or "skip" to declare that the commit needs no release note. Without a
        description the commit subject is used. Repeat the trailer to attach
        several notes to one commit.

    Charts: <name>[, <name>...] | all | none
        Overrides the charts the note is attached to. Omitted, the charts are
        taken from the directories the commit touches, so a commit that only
        changes roles, playbooks, tools or docs produces no note at all.
""".format(kinds=", ".join(relnotes.KINDS))


def resolve_commit(message, commit, branch, repo="."):
    """Find the commit the message belongs to.

    In the gate the message comes from Zuul while the checkout may carry a
    speculative merge on top, so the commit is located by its Change-Id rather
    than assumed to be HEAD.
    """
    match = re.search(r"^Change-Id:\s*(I[0-9a-f]+)\s*$", message, re.M)
    if match:
        found = relnotes.git(
            "log",
            "--no-merges",
            "--format=%H",
            "--grep=^Change-Id: %s$" % match.group(1),
            "%s..HEAD" % branch,
            repo=repo,
        ).split()
        if found:
            return found[0]
    return commit


def unparsed_trailers(message, trailers):
    """Trailer keys written in the message but outside the trailer block.

    git only recognises trailers in the final paragraph. A Changelog line in
    the middle of the body parses as prose and would be dropped without a
    word, so treat it as an error.

    The match is anchored at column zero on purpose. An indented line belongs
    to the trailer above it, so a wrapped note whose text happens to begin
    "Charts:" is folded into that note rather than lost, and a line that
    really is outside the block is unindented by definition.
    """
    parsed = {}
    for key, _ in trailers:
        parsed[key.lower()] = parsed.get(key.lower(), 0) + 1

    problems = []
    for key in (relnotes.CHANGELOG_TRAILER, relnotes.CHARTS_TRAILER):
        written = len(
            re.findall(r"^%s[ \t]*:" % key, message, re.M | re.I)
        )
        if written > parsed.get(key, 0):
            problems.append(key)
    return problems


def check(message, sha, all_charts, repo="."):
    """Return a list of error strings, empty when the message is valid."""
    errors = []

    trailers = relnotes.parse_trailers(message)
    for key in unparsed_trailers(message, trailers):
        errors.append(
            "a %s: line is not in the trailer block and would be ignored; "
            "move it to the last paragraph, next to Change-Id"
            % key.capitalize()
        )

    entries, charts_spec, _ = relnotes.parse_changelog_trailers(message)
    kinds = [kind for kind, _ in entries]

    for kind, description in entries:
        if kind not in relnotes.KINDS and kind != relnotes.SKIP:
            errors.append(
                "unknown Changelog kind %r; use one of: %s, skip"
                % (kind, ", ".join(relnotes.KINDS))
            )
        if not description:
            errors.append(
                "Changelog: %s has no description and the commit subject is "
                "empty" % kind
            )

    if relnotes.SKIP in kinds and len(entries) > 1:
        errors.append(
            "Changelog: skip cannot be combined with other Changelog trailers"
        )

    if charts_spec is not None:
        names = relnotes.split_charts_spec(charts_spec)
        lowered = [name.lower() for name in names]
        if ("all" in lowered or "none" in lowered) and len(names) > 1:
            errors.append(
                "Charts: all and Charts: none cannot be combined with chart names"
            )
        else:
            unknown = [
                name
                for name in names
                if name.lower() not in ("all", "none") and name not in all_charts
            ]
            for name in unknown:
                errors.append("Charts: names an unknown chart %r" % name)

        if not entries:
            errors.append(
                "Charts: has no effect without a Changelog: trailer"
            )
        elif kinds == [relnotes.SKIP]:
            errors.append("Charts: has no effect alongside Changelog: skip")

    touched = relnotes.charts_from_files(
        relnotes.commit_files(sha, repo=repo), all_charts
    )

    if not entries and touched:
        errors.append(
            "this commit changes %s but carries no Changelog: trailer; add one, "
            "or Changelog: skip if the change needs no release note"
            % ", ".join(sorted(touched))
        )

    if entries and kinds != [relnotes.SKIP] and not errors:
        targets = relnotes.target_charts(sha, charts_spec, all_charts, repo=repo)
        if not targets:
            errors.append(
                "the Changelog: trailer would not reach any chart because the "
                "commit touches no chart directory; name the charts with a "
                "Charts: trailer or drop the Changelog: trailer"
            )

    return errors


def describe(message, sha, all_charts, repo="."):
    entries, charts_spec, _ = relnotes.parse_changelog_trailers(message)
    if not entries:
        return "no release note"
    if [kind for kind, _ in entries] == [relnotes.SKIP]:
        return "release note explicitly skipped"

    targets = relnotes.target_charts(sha, charts_spec, all_charts, repo=repo)
    if not targets:
        listed = "no chart"
    elif targets == set(all_charts):
        listed = "all %d charts" % len(all_charts)
    else:
        listed = ", ".join(sorted(targets))
    return "%d release note(s) for %s" % (len(entries), listed)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--commit", default="HEAD", help="Commit to check (default: HEAD)"
    )
    parser.add_argument(
        "--message-file",
        help="Read the message from this file instead of from the commit",
    )
    parser.add_argument(
        "--branch",
        default="master",
        help="Target branch, used to locate the commit under review",
    )
    parser.add_argument("--repo", default=".", help="Repository root")
    args = parser.parse_args()

    if args.message_file:
        with open(args.message_file) as handle:
            message = handle.read()
        sha = resolve_commit(message, args.commit, args.branch, repo=args.repo)
    else:
        sha = args.commit
        message = relnotes.commit_message(sha, repo=args.repo)

    all_charts = relnotes.discover_charts(args.repo)
    errors = check(message, sha, all_charts, repo=args.repo)

    print("Checking %s" % relnotes.git("rev-parse", "--short", sha, repo=args.repo).strip())
    print("Subject: %s" % relnotes.subject_of(message))

    if errors:
        print("")
        for error in errors:
            print("ERROR: %s" % error)
        print(HELP)
        return 1

    print("OK: %s" % describe(message, sha, all_charts, repo=args.repo))
    return 0


if __name__ == "__main__":
    sys.exit(main())
