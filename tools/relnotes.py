"""Shared helpers for turning git history into chart release notes.

Two producers feed the same consumer:

* ``Changelog:`` git trailers in commit messages, which is how new release
  notes are written.
* Legacy reno note files under ``releasenotes/notes/``, which are frozen but
  still have to appear in the charts they were written for.

This module deliberately depends on nothing outside the standard library so
that the commit message check can run on a bare node. Anything needing PyYAML
lives in ``chart_annotations.py``.
"""

import os
import re
import subprocess

# The change kinds Artifact Hub understands.
KINDS = ("added", "changed", "deprecated", "removed", "fixed", "security")

# Pseudo kind used to state that a commit deliberately has no release note.
SKIP = "skip"

# Legacy reno sections mapped onto the Artifact Hub kinds. Artifact Hub has no
# equivalent of "known issues" or "upgrade notes", so both land in "changed".
RENO_SECTION_KINDS = {
    "features": "added",
    "fixes": "fixed",
    "security": "security",
    "upgrade": "changed",
    "api": "changed",
    "issues": "changed",
}

NOTES_DIR = "releasenotes/notes"

GERRIT_QUERY_URL = "https://review.opendev.org/q/"

CHANGELOG_TRAILER = "changelog"
CHARTS_TRAILER = "charts"


class Entry(object):
    """A single release note destined for one chart."""

    def __init__(self, kind, description, links=None, source=None):
        self.kind = kind
        self.description = description
        self.links = links or []
        self.source = source

    def key(self):
        return (self.kind, self.description)

    def __repr__(self):
        return "Entry(%r, %r)" % (self.kind, self.description)


def git(*args, **kwargs):
    """Run a git command and return its stdout."""
    repo = kwargs.pop("repo", ".")
    return subprocess.run(
        ["git"] + list(args),
        cwd=repo,
        check=True,
        capture_output=True,
        text=True,
    ).stdout


def discover_charts(repo="."):
    """Every directory in the repo root that holds a Chart.yaml."""
    return sorted(
        name
        for name in os.listdir(repo)
        if os.path.isfile(os.path.join(repo, name, "Chart.yaml"))
    )


def tag_exists(tag, repo="."):
    return subprocess.run(
        ["git", "show-ref", "--tags", tag, "--quiet"],
        cwd=repo,
    ).returncode == 0


def commits_in_range(rev_range, repo="."):
    """Commits in ``rev_range``, newest first, merges excluded.

    Gerrit merges a change as a merge commit whose message is a copy of the
    change subject, so including them would duplicate every entry.
    """
    return git("log", "--no-merges", "--format=%H", rev_range, repo=repo).split()


# Record and field separators for the batched git log reads below. Both are
# ASCII control characters a commit message will not contain.
RS = "\x1e"
FS = "\x1f"


def messages_in_range(rev_range, repo="."):
    """``[(sha, message)]`` for the range, newest first, in one git call.

    Asking git for each message separately costs a process per commit, which
    over the whole history is minutes rather than seconds.
    """
    out = git(
        "log", "--no-merges", "--format=%x1e%H%x1f%B", rev_range, repo=repo
    )
    records = []
    for chunk in out.split(RS):
        if not chunk.strip():
            continue
        sha, _, message = chunk.partition(FS)
        records.append((sha.strip(), message))
    return records


def note_files_in_range(rev_range, repo="."):
    """``{sha: [note path]}`` for notes a commit added or changed, in one call."""
    out = git(
        "log", "--no-merges", "--diff-filter=AM", "--name-only",
        "--format=%x1e%H", rev_range, "--", NOTES_DIR, repo=repo
    )
    per_commit = {}
    for chunk in out.split(RS):
        lines = [line for line in chunk.splitlines() if line.strip()]
        if not lines:
            continue
        paths = [path for path in lines[1:] if is_note_path(path)]
        if paths:
            per_commit[lines[0].strip()] = paths
    return per_commit


def commit_message(sha, repo="."):
    return git("show", "-s", "--format=%B", sha, repo=repo)


def commit_files(sha, repo=".", diff_filter=None):
    """Paths touched by a single commit."""
    args = ["diff-tree", "--no-commit-id", "--name-only", "-r"]
    if diff_filter:
        args.append("--diff-filter=" + diff_filter)
    args.append(sha)
    return [line for line in git(*args, repo=repo).splitlines() if line]


def read_blobs(specs, repo="."):
    """Read many ``<rev>:<path>`` blobs in one ``git cat-file --batch`` call.

    A full render reads a few thousand note files. One ``git show`` each is
    most of the runtime; one batch is not measurable.
    """
    if not specs:
        return {}

    payload = "".join(spec + "\n" for spec in specs).encode()
    out = subprocess.run(
        ["git", "cat-file", "--batch"],
        cwd=repo,
        input=payload,
        stdout=subprocess.PIPE,
        check=True,
    ).stdout

    blobs = {}
    pos = 0
    for spec in specs:
        end = out.index(b"\n", pos)
        header = out[pos:end].decode().split()
        pos = end + 1
        # A deleted or unreachable path answers "<spec> missing".
        if len(header) < 3:
            blobs[spec] = ""
            continue
        size = int(header[2])
        blobs[spec] = out[pos:pos + size].decode("utf-8", "replace")
        pos += size + 1
    return blobs


def parse_trailers(message):
    """Return ``[(key, value)]`` for the trailers of a commit message.

    ``git interpret-trailers`` is authoritative here: it only recognises the
    final paragraph of the message, which is the same rule Gerrit applies to
    Change-Id. Using it means the check job validates exactly what the build
    later collects.
    """
    out = subprocess.run(
        ["git", "interpret-trailers", "--parse"],
        input=message,
        capture_output=True,
        text=True,
        check=True,
    ).stdout
    trailers = []
    for line in out.splitlines():
        key, sep, value = line.partition(":")
        if sep:
            trailers.append((key.strip(), value.strip()))
    return trailers


def subject_of(message):
    lines = [line for line in message.strip().splitlines()]
    return lines[0].strip() if lines else ""


CHANGE_ID_RE = re.compile(r"^Change-Id:[ \t]*(I[0-9a-f]+)[ \t]*$", re.M)

# A message that never writes the word cannot carry the trailer, whatever git
# would make of its last paragraph. Checking that first keeps the build from
# spawning git interpret-trailers once per commit, which is the difference
# between seconds and minutes over the whole history.
MENTIONS_RE = re.compile(
    r"^[ \t]*(%s|%s)[ \t]*:" % (CHANGELOG_TRAILER, CHARTS_TRAILER), re.I | re.M
)


# A Conventional Commits subject already says what kind of change it is, so a
# commit written that way needs no Changelog: trailer to repeat it.
CONVENTIONAL_KINDS = {
    "feat": "added",
    "fix": "fixed",
    "refactor": "changed",
    "perf": "changed",
    "revert": "changed",
}

# Types that describe work with nothing to tell a deployer. Recognised so that
# such a commit passes the check without a trailer, but producing no note.
CONVENTIONAL_SILENT = frozenset(
    ["build", "chore", "ci", "docs", "style", "test", "tests"]
)

CONVENTIONAL_RE = re.compile(
    r"^(?P<type>[a-z]+)"
    r"(?:\((?P<scope>[^)]*)\))?"
    r"(?P<breaking>!)?"
    r":[ \t]+(?P<description>.+)$"
)


def _conventional(subject):
    """Parse a Conventional Commits subject, or None if it is not one.

    Only the types above are recognised. That matters because this repository
    also writes "neutron: fix the probe", which has the same shape, and a
    chart name is not a change kind.
    """
    match = CONVENTIONAL_RE.match(subject.strip())
    if not match:
        return None

    kind = match.group("type").lower()
    if kind not in CONVENTIONAL_KINDS and kind not in CONVENTIONAL_SILENT:
        return None

    description = match.group("description").strip()
    if not description:
        return None
    if match.group("breaking"):
        # Artifact Hub has no breaking kind, and a breaking change is a
        # change whatever the type says.
        return "changed", description
    if kind in CONVENTIONAL_SILENT:
        return SKIP, description
    return CONVENTIONAL_KINDS[kind], description


def note_subject(message):
    """The commit subject as a release note should read it.

    A Conventional Commits prefix names the kind, which the annotation
    already carries in its own field, so "fix(nova): sized the job" is a note
    that reads "sized the job".
    """
    subject = subject_of(message)
    conventional = _conventional(subject)
    return conventional[1] if conventional else subject


def parse_changelog_trailers(message):
    """Pull the release note trailers out of a commit message.

    Returns ``(entries, charts_spec, change_id)`` where entries is a list of
    ``(kind, description)`` pairs. A ``Changelog:`` trailer carrying only a
    kind takes the commit subject as its description.
    """
    match = CHANGE_ID_RE.search(message)
    change_id = match.group(1) if match else None

    if not MENTIONS_RE.search(message):
        return [], None, change_id

    subject = note_subject(message)
    entries = []
    charts_spec = None

    for key, value in parse_trailers(message):
        lowered = key.lower()
        if lowered == CHANGELOG_TRAILER:
            kind, _, description = value.partition(":")
            entries.append((kind.strip().lower(), description.strip() or subject))
        elif lowered == CHARTS_TRAILER:
            charts_spec = value if charts_spec is None else charts_spec + "," + value

    return entries, charts_spec, change_id


def release_notes_of(message):
    """Every release note a commit message declares.

    Returns ``(entries, charts_spec, change_id, inferred)``. ``inferred`` says
    the entries came from the subject rather than from a trailer, which the
    check treats more leniently: an author who wrote a trailer meant it to
    reach a chart, while a conventional subject is just how they write
    subjects.

    Both the build and the check go through here, so what the check validates
    is what the build later collects.
    """
    entries, charts_spec, change_id = parse_changelog_trailers(message)
    if entries:
        return entries, charts_spec, change_id, False

    guess = _conventional(subject_of(message))
    if guess:
        return [guess], charts_spec, change_id, True

    return [], charts_spec, change_id, False


def split_charts_spec(spec):
    """Split a ``Charts:`` trailer value into names."""
    return [name for name in re.split(r"[,\s]+", spec.strip()) if name]


def charts_from_files(files, all_charts):
    """Charts whose directory a commit touched."""
    charts = set()
    for path in files:
        top = path.split("/", 1)[0]
        if top in all_charts:
            charts.add(top)
    return charts


def target_charts(sha, charts_spec, all_charts, repo="."):
    """Charts a commit's release note belongs to.

    Without a ``Charts:`` trailer the charts are inferred from the diff, so a
    commit touching only roles, playbooks or tools reaches no chart at all.
    """
    if charts_spec is None:
        return charts_from_files(commit_files(sha, repo=repo), all_charts)

    names = split_charts_spec(charts_spec)
    lowered = {name.lower() for name in names}
    if "all" in lowered:
        return set(all_charts)
    if "none" in lowered:
        return set()
    return set(names)


def note_owner(basename, all_charts):
    """The chart a legacy reno note file belongs to.

    Returns ``"common"`` for notes that apply to every chart, a chart name, or
    None when the file name matches nothing. The longest matching chart name
    wins so that ``mariadb-backup-<hash>.yaml`` belongs to mariadb-backup
    rather than to mariadb.
    """
    stem = basename.rsplit(".", 1)[0]
    if stem == "common" or stem.startswith("common-"):
        return "common"

    best = None
    for chart in all_charts:
        if stem == chart or stem.startswith(chart + "-"):
            if best is None or len(chart) > len(best):
                best = chart
    return best


def is_note_path(path):
    return path.startswith(NOTES_DIR + "/") and path.endswith((".yaml", ".yml"))


def is_aggregate_note(basename, all_charts):
    """True for a pre-2024.2.0 per-chart running changelog.

    Before notes were written one file per change, each chart had a single
    file named after it holding every version it had ever had, oldest first::

        neutron:
          - 0.1.0 Initial Chart
          - 0.1.1 Change helm-toolkit dependency version to ">= 0.1.0"

    A reno note describes one change and its items have no chronology, but
    these are a changelog in their own right and run the opposite way round
    to the annotation, so their order has to be flipped.
    """
    return basename.rsplit(".", 1)[0] in all_charts


def gerrit_links(change_id):
    if not change_id:
        return []
    return [("Gerrit change", GERRIT_QUERY_URL + change_id)]
