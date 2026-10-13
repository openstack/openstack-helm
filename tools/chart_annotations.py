"""Write the ``artifacthub.io/changes`` annotation into a chart's Chart.yaml.

Run during the chart build, after linting and before ``helm package``, so the
annotation ships in the tarball without ever being committed to git. Artifact
Hub stitches the annotations of every published version together into one
changelog, so each build only carries the notes belonging to the version being
built: everything since the previous commit that touched the chart.

Notes come from two places, both keyed by the commit that introduced them:

* ``Changelog:`` trailers in commit messages, routed to charts by the
  ``Charts:`` trailer or, failing that, by the directories the commit touched.
* Legacy reno note files under releasenotes/notes, routed to charts by file
  name and by the sections the note body carries.
"""

import argparse
import os
import re
import sys

import yaml

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import relnotes  # noqa: E402

ANNOTATION_KEY = "artifacthub.io/changes"

# Indent of the keys inside the top-level annotations mapping.
ANNOTATION_INDENT = 2


class _Dumper(yaml.SafeDumper):
    """Emit multi-line descriptions as literal blocks rather than as one
    double-quoted line full of \\n escapes, and indent nested sequences."""

    def increase_indent(self, flow=False, indentless=False):
        return super(_Dumper, self).increase_indent(flow, False)


def _represent_str(dumper, data):
    if "\n" in data:
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


_Dumper.add_representer(str, _represent_str)


def version_paths(chart, repo="."):
    """The paths a chart's version is a function of.

    Mirrors tools/chart_version.sh: helm-toolkit is vendored into every chart
    that depends on it, so those charts get a new version when helm-toolkit
    moves, and their notes have to be bounded by the same commits.
    """
    paths = [chart]
    if chart != "helm-toolkit":
        with open(os.path.join(repo, chart, "Chart.yaml")) as handle:
            if re.search(r"name:[ \t]*helm-toolkit", handle.read()):
                paths.append("helm-toolkit")
    return paths


def build_range(chart, base_version, repo=".", since=None, full=False):
    """The commit range covered by the version currently being built.

    A version is bounded by the commits that produce it, the same ones
    tools/chart_version.sh counts: the newest is this version's commit and the
    one before it published the previous version. Consecutive versions
    therefore partition the history and every note is published exactly once.

    Returns None when the chart has not moved since the base tag, and so has
    nothing new to say. A commit routed to this chart without touching it -- a
    ``Charts: all`` change, say -- does not bump the version and is carried by
    the next version of the chart, the first one that can hold it.

    ``full`` drops the lower bound so that the version carries every release
    note the chart has ever had, and ``since`` replaces it with an explicit
    revision. Both are for the series bump, where the versions that would
    otherwise hold the accumulated history were published without annotations.
    """
    paths = version_paths(chart, repo=repo)

    if full or since:
        # The upper bound is the whole history's newest commit touching the
        # chart, which is the sha tools/chart_version.sh puts in the version.
        newest = relnotes.git(
            "log", "-1", "--format=%H", "HEAD", "--", *paths, repo=repo
        ).strip()
        if not newest:
            return None
        return "%s..%s" % (since, newest) if since else newest

    if relnotes.tag_exists(base_version, repo=repo):
        spec = "%s..HEAD" % base_version
        floor = base_version
    else:
        spec = "HEAD"
        floor = None

    shas = relnotes.git(
        "log", "--format=%H", spec, "--", *paths, repo=repo
    ).split()
    if not shas:
        return None

    lower = shas[1] if len(shas) > 1 else floor
    return "%s..%s" % (lower, shas[0]) if lower else shas[0]


def note_entries(content, owner, chart, all_charts, aggregate=False):
    """Release notes a single legacy reno note file contributes to a chart.

    A note reaches a chart either because the file belongs to it (or to
    ``common``), or because the note body names the chart as a section. The
    second rule keeps notes such as a ``mariadb:`` section inside
    ``mariadb-backup-<hash>.yaml`` reaching mariadb.
    """
    data = yaml.safe_load(content) or {}
    if not isinstance(data, dict):
        return []

    owned = owner in (chart, "common")
    entries = []
    for key, value in data.items():
        if key == chart:
            kind = "changed"
        elif owned and key in relnotes.RENO_SECTION_KINDS:
            kind = relnotes.RENO_SECTION_KINDS[key]
        else:
            continue

        items = list(value or [])
        if aggregate:
            # A running changelog reads oldest first; the annotation reads
            # newest first.
            items.reverse()

        for item in items:
            description = str(item).strip()
            if description:
                entries.append(relnotes.Entry(kind, description, source="reno"))

    return entries


def collect(chart, all_charts, rev_range, repo=".", note_cache=None):
    """Every release note belonging to a chart within a commit range.

    The two reads over the range are batched into one git call each, because
    a full render walks the whole history and a process per commit there costs
    minutes. What remains per commit is done only for the few commits that
    need it: a commit with no release note trailer never runs
    ``git interpret-trailers``, and a note file is read once however many
    charts it reaches.
    """
    entries = []
    note_paths = relnotes.note_files_in_range(rev_range, repo=repo)
    note_cache = {} if note_cache is None else note_cache

    wanted = [
        "%s:%s" % (sha, path)
        for sha, paths in note_paths.items()
        for path in paths
        if "%s:%s" % (sha, path) not in note_cache
    ]
    note_cache.update(relnotes.read_blobs(wanted, repo=repo))

    for sha, message in relnotes.messages_in_range(rev_range, repo=repo):
        trailers, charts_spec, change_id = relnotes.parse_changelog_trailers(message)
        links = relnotes.gerrit_links(change_id)

        targets = None
        for kind, description in trailers:
            if kind not in relnotes.KINDS or not description:
                # Rejected by the commit message check; ignored here so that a
                # single malformed commit cannot break every later build.
                continue
            if targets is None:
                targets = relnotes.target_charts(
                    sha, charts_spec, all_charts, repo=repo
                )
            if chart in targets:
                entries.append(
                    relnotes.Entry(kind, description, links, source="trailer")
                )

        for path in note_paths.get(sha, ()):
            content = note_cache.get("%s:%s" % (sha, path), "")
            basename = os.path.basename(path)
            owner = relnotes.note_owner(basename, all_charts)
            for entry in note_entries(
                content, owner, chart, all_charts,
                aggregate=relnotes.is_aggregate_note(basename, all_charts),
            ):
                entry.links = links
                entries.append(entry)

    seen = set()
    unique = []
    for entry in entries:
        if entry.key() not in seen:
            seen.add(entry.key())
            unique.append(entry)

    return unique


def render(entries):
    """Render entries as the YAML document the annotation carries."""
    payload = []
    for entry in entries:
        item = {"kind": entry.kind, "description": _clean(entry.description)}
        if entry.links:
            item["links"] = [{"name": name, "url": url} for name, url in entry.links]
        payload.append(item)

    return yaml.dump(
        payload,
        Dumper=_Dumper,
        default_flow_style=False,
        sort_keys=False,
        width=1000000,
        allow_unicode=True,
    )


def _clean(text):
    """Strip trailing whitespace so literal blocks stay representable."""
    return "\n".join(line.rstrip() for line in text.strip().splitlines())


def _annotation_block(key, value):
    lines = ["%s%s: |" % (" " * ANNOTATION_INDENT, key)]
    for line in value.rstrip("\n").splitlines():
        lines.append(" " * (ANNOTATION_INDENT + 2) + line if line.strip() else "")
    return lines


def _drop_key(body, key):
    """Remove ``key`` and its nested lines from an annotations block body."""
    base = None
    for line in body:
        if line.strip():
            base = len(line) - len(line.lstrip())
            break
    if base is None:
        return body

    kept = []
    skipping = False
    for line in body:
        stripped = line.strip()
        indent = len(line) - len(line.lstrip())
        if skipping:
            if not stripped or indent > base:
                continue
            skipping = False
        if indent == base and stripped.split(":", 1)[0].strip("\"'") == key:
            skipping = True
            continue
        kept.append(line)
    return kept


def upsert_annotation(text, key, value):
    """Insert or replace ``key`` in the top-level ``annotations`` mapping.

    Edits the file as text rather than round-tripping it through a YAML
    parser, so the licence header, comments and layout of Chart.yaml survive
    untouched.
    """
    lines = text.splitlines()
    block = _annotation_block(key, value)

    start = next(
        (i for i, line in enumerate(lines) if line.startswith("annotations:")), None
    )

    if start is not None:
        end = start + 1
        while end < len(lines) and (
            not lines[end].strip() or lines[end][:1] in (" ", "\t")
        ):
            end += 1
        body = lines[start + 1:end]
        while body and not body[-1].strip():
            body.pop()
        body = _drop_key(body, key)
        merged = [lines[start]] + body + block
        return "\n".join(lines[:start] + merged + lines[end:]) + "\n"

    # No annotations mapping yet: add one before the document end marker.
    insert_at = len(lines)
    for i in range(len(lines) - 1, -1, -1):
        if lines[i].strip() == "...":
            insert_at = i
            break
        if lines[i].strip():
            break

    addition = [""] + ["annotations:"] + block
    return "\n".join(lines[:insert_at] + addition + lines[insert_at:]) + "\n"


def verify(text, key, value, path):
    """Fail loudly rather than package a chart with a mangled Chart.yaml."""
    try:
        data = yaml.safe_load(text)
    except yaml.YAMLError as err:
        raise SystemExit("%s: annotation left the file unparsable: %s" % (path, err))

    if not isinstance(data, dict):
        raise SystemExit("%s: is not a YAML mapping after annotating" % path)

    written = (data.get("annotations") or {}).get(key)
    if written is None:
        raise SystemExit("%s: annotation %s was not written" % (path, key))

    if yaml.safe_load(written) != yaml.safe_load(value):
        raise SystemExit("%s: annotation %s did not round-trip" % (path, key))


def annotate(chart, base_version, repo=".", dry_run=False, all_charts=None,
             since=None, full=False, note_cache=None):
    all_charts = all_charts or relnotes.discover_charts(repo)
    rev_range = build_range(
        chart, base_version, repo=repo, since=since, full=full
    )

    if rev_range is None:
        print("%s: unchanged since %s, no release notes" % (chart, base_version))
        return 0

    entries = collect(
        chart, all_charts, rev_range, repo=repo, note_cache=note_cache
    )

    if not entries:
        print("%s: no release notes in %s" % (chart, rev_range))
        return 0

    value = render(entries)
    if dry_run:
        print("%s: %d release note(s) in %s" % (chart, len(entries), rev_range))
        print(value)
        return len(entries)

    path = os.path.join(repo, chart, "Chart.yaml")
    with open(path) as handle:
        original = handle.read()

    updated = upsert_annotation(original, ANNOTATION_KEY, value)
    verify(updated, ANNOTATION_KEY, value, path)

    with open(path, "w") as handle:
        handle.write(updated)

    print("%s: wrote %d release note(s) from %s" % (chart, len(entries), rev_range))
    return len(entries)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--charts", nargs="+", required=True, help="Charts to annotate"
    )
    parser.add_argument(
        "--base-version",
        required=True,
        help="Tag the current series started from, for example 2026.1.0",
    )
    parser.add_argument("--repo", default=".", help="Repository root")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the annotation instead of writing Chart.yaml",
    )
    bound = parser.add_mutually_exclusive_group()
    bound.add_argument(
        "--full",
        action="store_true",
        help="Render every release note the chart has ever had, rather than "
        "only those of the version being built. For the series bump, where "
        "the earlier versions were published without annotations.",
    )
    bound.add_argument(
        "--since",
        metavar="REV",
        help="Open the range at REV instead of at the previous version",
    )
    args = parser.parse_args()

    all_charts = relnotes.discover_charts(args.repo)
    # Shared across charts: a common note is read once, not once per chart.
    note_cache = {}
    for chart in args.charts:
        if chart not in all_charts:
            raise SystemExit("unknown chart: %s" % chart)
        annotate(
            chart,
            args.base_version,
            repo=args.repo,
            dry_run=args.dry_run,
            all_charts=all_charts,
            since=args.since,
            full=args.full,
            note_cache=note_cache,
        )


if __name__ == "__main__":
    main()
