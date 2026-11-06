# Instructions for AI coding agents

This file is for AI coding agents and for the people who run them. Read all of
it before you prepare a change for this repository. In this file "you" is the
agent, and "the person" is the human who runs the agent and submits the
change.

OpenStack-Helm is a set of Helm charts maintained by a small group of
reviewers. Review time and CI capacity are the scarce resources here, not code.

## Repository map

- `<chart>/`: one directory per chart, with `Chart.yaml`, `values.yaml` and
  `templates/`. `make charts` lists the charts.
- `helm-toolkit/`: the library chart with the shared templates. Almost every
  chart depends on it as `file://../helm-toolkit` and ships a copy of it, so
  a change in `helm-toolkit` is a change in all of them.
- `values_overrides/<chart>/<name>.yaml`: values files that are put on top of
  the chart defaults. Some turn on an optional feature (`tls.yaml`,
  `netpol.yaml`), the others select an OpenStack release and a base image
  (`2026.1-ubuntu_noble.yaml`). The CI jobs deploy the charts with them.
- `zuul.d/`: the CI jobs. `playbooks/` and `roles/` hold the Ansible code
  that the jobs run: `roles/deploy-env` builds the test Kubernetes cluster
  and `roles/deploy-charts` installs the charts.
- `tools/`: the scripts that compute chart versions and collect and check
  release notes.
- `doc/source/`: the documentation. The specs are in
  `doc/source/specs/<series>/` and the developer reference is in
  `doc/source/devref/`.
- `releasenotes/notes/`: the old release notes, which are frozen.

The current release series is the `BASE_VERSION` in the `Makefile`. The
container images are not built here: see
[openstack-helm-images](https://opendev.org/openstack/openstack-helm-images)
and [loci](https://opendev.org/openstack/loci).

## 1. The human behind the agent is responsible

The person who submits the change is its author, not you. A purely autonomous
submission with no identifiable accountable human is not acceptable. The
person must:

- Understand every line of the change and be able to explain why it is
  needed.
- Answer review comments personally and in a reasonable time, and not paste
  them into an agent and push its output without reading it.

You cannot carry this responsibility for the person, but you can make it
possible for them to carry it:

- Do not send a change for review (`git review`), post a comment or a vote in
  Gerrit, or `recheck` a change unless the person asks you for that action.
  A request to write a change is not a request to push it.
- Before you hand a change over, explain it to the person: what it changes,
  why each part is needed, what you tested, what you did not test, and what
  you are not sure about. They need this to answer for the change in review.
- Report only what you did. Do not write in the commit message or tell the
  person that a chart was rendered, linted or deployed when it was not.
- When the person gives you a review comment, explain to them what the
  reviewer asks for and what you changed in response, before the new patch
  set is pushed. If you think the reviewer is wrong, tell the person; do not
  change the code without saying so, and do not argue with the reviewer in
  the person's name.

## 2. Follow the OpenInfra AI policy

Like every OpenInfra Foundation project, OpenStack-Helm follows the
foundation's
[Policy for AI Generated Content](https://openinfra.org/legal/ai-policy).
Read the policy itself. It rests on five principles:

> 1. **AI use is welcomed.** Contributors are free to use the AI tools that
>    work best for them. We neither mandate particular tools nor discourage
>    their use.
> 2. **Humans remain accountable.** Every contribution must have an
>    accountable human author who signs off under the Developer Certificate
>    of Origin (DCO), fully understands, and stands behind the work,
>    regardless of how it was produced.
> 3. **Material AI use is disclosed.** When AI tools materially shape a
>    contribution, that fact is recorded in the commit metadata using a
>    machine-readable label, so the origin of the work can be understood
>    later if questions arise.
> 4. **Results are human-consumable.** Contributions must be understood by
>    the humans who propose, review, and maintain them. The point of
>    engagement is the human community, not the tooling.
> 5. **The same standard applies.** Don't trust AI output implicitly. AI
>    assisted contributions are held to the same quality, correctness,
>    security, and licensing standards as any other contribution. Reviewers
>    may reject low-quality work, but neither a higher nor a lower bar
>    applies because a tool was involved.

The contributor checklist of the policy asks for the following:

- Add an `Assisted-By:` label to the commit message. The policy recommends
  `Assisted-By`; `Generated-By` is still approved. The policy does not say
  what the label contains. In this repository it names the tool and the
  model, for example `Assisted-By: Claude Opus 5.5`. Add it yourself.
- Explain in comments or the commit message any prompts or background context
  the reviewers might need to fully understand the change and how much of the
  change came from the tool.
- These labels are in addition to `Signed-off-by:`, which identifies the
  contributor who submits the change. A `Signed-off-by:` or `Co-Authored-By:`
  label is a statement that a human contributor takes responsibility for the
  entire contents of the commit, including any parts that were generated or
  assisted by AI tools. These two labels therefore name people, not tools:
  an agent that adds `Co-Authored-By:` for itself by default must use
  `Assisted-By:` instead.
- The person carefully reviews any suggested or generated code or comments to
  ensure nothing is harmful, malicious or incorrect.
- Check that the output of the tool is compatible with the license of this
  project, Apache-2.0. Material authored or owned by third parties must be
  licensed as open source or be in the public domain, or the copyright holder
  must give permission to release it as open source. Make sure the AI tool
  does not claim proprietary rights to the code or content it generates.
- When the tool has them, enable the features that flag or block output that
  matches publicly available code, and operate the tool in a mode that
  respects open source licensing.

For reviewers, the disclosure label is not grounds for rejection; it is
context. If a change is substantially re-worked by a human during the review,
consider whether to remove the label.

To sign off, commit with `git commit -s` under the person's own git identity
and do not change `user.name` or `user.email`. Gerrit rejects a commit
without a `Signed-off-by:` line.

## 3. Take part in the community

Changes from people the reviewers know are reviewed faster. Changes from
unknown accounts that send many patches and never talk to anyone are reviewed
last, if at all.

You cannot take part in the community for the person. Do not post to the
chat, the mailing list or Gerrit in their name unless they ask you to. The
rules below are for the person, and each one says what your part is.

- The person joins the chat, `#openstack-helm` on the
  [Kubernetes Slack](https://kubernetes.slack.com/messages/C3WERB7DE/),
  introduces themselves and says what they work on and why.
- A large or tree-wide change is agreed before it is written. The person
  describes the plan in the chat or on the
  [openstack-discuss](https://lists.openstack.org/cgi-bin/mailman/listinfo/openstack-discuss)
  mailing list (subject prefix `[openstack-helm]`). Before you write such a
  change, stop and ask the person whether the approach was agreed. If it was
  not, offer to draft the proposal or the spec for the person to send, and do
  not write the code yet.
- A change that updates the design or changes the user experience may need a
  spec. A spec is not mandatory; the person asks in the chat whether the
  change needs one. A spec gives reviewers more context and makes it easier
  for them to trust the change. To write one, copy
  [doc/source/specs/COPYME](doc/source/specs/COPYME) to
  `doc/source/specs/<series>/` and send it as a separate change.
- A change must not contradict the merged specs. Before you implement a
  change, read all the merged specs in `doc/source/specs/` that cover the
  same area, from every release series, and implement the change as they
  describe. A newer spec takes precedence: if two specs contradict each
  other, follow the newer one. The specs in a later series directory are
  newer, and the specs that are not in a series directory are the oldest. If
  the request contradicts a merged spec, tell the person and do not implement
  it. When the community decides on a design that contradicts a merged spec,
  a new spec must be written, reviewed and merged first.
- The person reviews other people's changes: review is how this project
  scales, and whoever sends changes reviews other changes too. A useful
  review tests the change or points to a concrete problem; a bare `+1` is not
  a review. When the person asks you to review a change, render or deploy it
  and report the concrete problems you found, with the evidence, not general
  praise or a long list of style remarks. The person reads your findings and
  posts the review.

## 4. Change mechanics

- The project uses Gerrit on <https://review.opendev.org>, not GitHub pull
  requests. Changes are pushed with `git review`, and you push only when the
  person asks you to (see section 1).
- In Gerrit one commit is one change, and the `Change-Id:` trailer says which
  change a commit belongs to. To update a change, for example after a review
  comment, amend its commit with `git commit --amend` and keep the
  `Change-Id:` line as it is; the next push adds a new patch set to the same
  change. Do not add a second commit with the fix: Gerrit makes a separate
  change out of it. Do not write or edit the `Change-Id:` line yourself; the
  commit hook that `git review` installs adds it to a new commit.
- Keep each change small enough for one reviewer to check: one logical change
  per commit, no unrelated clean-up, and no series of the same patch for many
  charts unless that was agreed.
- Do not bump `version` in `Chart.yaml`. Chart versions are computed at build
  time and bumped by the core team once per release series.
- Write the release note in the commit message. The
  `openstack-helm-release-notes` job checks the message of every change and
  fails when one of these rules is broken (see
  [doc/source/devref/release-notes.rst](doc/source/devref/release-notes.rst)):

  - A commit that changes a chart directory must have a `Changelog:` trailer
    or a Conventional Commits subject.
  - The trailer is `Changelog: <kind>` or `Changelog: <kind>: <description>`.
    The kind is `added`, `changed`, `deprecated`, `removed`, `fixed` or
    `security`. Without a description the commit subject becomes the note.
    Repeat the trailer to write several notes.
  - `Changelog: skip` says that the change has nothing to tell a deployer. It
    cannot be combined with other `Changelog:` trailers.
  - A Conventional Commits subject such as `fix(nova): ...` needs no trailer.
    `feat` gives an `added` note, `fix` gives `fixed`, and `refactor`, `perf`,
    `revert` and any type with `!` give `changed`. `build`, `chore`, `ci`,
    `docs`, `style` and `test` give no note. A subject such as
    `neutron: fix the probe` is not one of these and needs a trailer.
  - The note goes to the charts whose directories the commit changes. To
    send it to other charts, add `Charts: <chart>, <chart>`, `Charts: all` or
    `Charts: none`. A `Charts:` trailer needs a note to send: it cannot go
    with `Changelog: skip` or with a subject type that gives no note.
  - A commit that changes no chart directory must not have a `Changelog:`
    trailer with a kind, unless it names the charts with `Charts:`.
  - `Changelog:` and `Charts:` must be in the last paragraph of the message.

  A change in `helm-toolkit` sends its note to `helm-toolkit` alone. When the
  change is visible in the charts that use it, add `Charts: all`. Do not add
  new files under `releasenotes/notes/`. Check the commit before it is
  pushed with `python3 tools/check_commit_message.py`.
- Write the commit message for a human reader: the subject says what changes,
  the body says why. Do not paste a list of every file you changed. Put all
  the trailers (`Changelog:`, `Charts:`, `Assisted-By:`, `Signed-off-by:`,
  `Change-Id:`) together in the last paragraph of the message; git does not
  read them anywhere else.
- Render every chart you changed before and after the change and compare the
  results. Do it with the default values and with each file in
  `values_overrides/<chart>/` that touches the values or templates you
  changed:

      helm dependency update <chart>
      helm template <chart> ./<chart> > default.yaml
      helm template <chart> ./<chart> \
          -f values_overrides/<chart>/<name>.yaml > <name>.yaml

  Run the same commands on the parent commit, for example in a
  `git worktree`, and `diff -u` the two sets of files. For a change in
  `helm-toolkit`, do this for several charts that use the changed template.
  Explain every difference in the commit message. If there is none, say so:
  "With the default values the chart renders as before."

  Two things make the comparison harder. Most OpenStack service charts
  generate a random `memcache_secret_key` on every render, which also changes
  the `secret-etc-hash` annotations; add
  `--set endpoints.oslo_cache.auth.memcache_secret_key=fixed` to both renders
  to remove this noise. The service configuration is rendered into a Secret
  in base64, so a change in it shows as one changed line; decode both values
  to see what changed.
- If a Zuul job fails, read the logs of the failed job before anything else;
  the person can ask you to do this. Check whether the same job fails on
  other open changes before you assume your change broke it. If the failure
  is not related to the change and comes from a temporary problem, such as a
  network error or a node that failed, say so to the person with the evidence
  from the logs: the buildset can then be rechecked. In any other case, fix
  the cause. Never `recheck` without looking at the logs.
- Do not weaken the CI to make a change pass. Find the cause of the failure
  and fix it. Do not remove a job or make it non-voting, skip or delete a
  test, loosen a check in a test or in the linter configuration, raise a
  timeout, add a retry, or widen `irrelevant-files`. If the test itself is
  wrong, fix it in a separate change and explain in its commit message why
  it was wrong.

## 5. Code conventions

- Use the snippets that already exist in `helm-toolkit`. Before you write a
  template, check whether `helm-toolkit` already has a snippet for the same
  job, and call it instead of writing your own.
- Wherever possible, use the existing code patterns instead of introducing
  new ones.
- Match the style of the code around your change: naming, indentation and
  comment density.
- Implement optional features with the existing extension points:
  `extraObjects`, `extraContainers`, `extraVolumes` and `pod.etcSources`.
  Not every chart has all of them: `extraObjects` is in almost every chart,
  the other three are in a minority. If the chart you work on lacks the one
  you need, add it the same way as a chart that already has it, for example
  `keystone`, with a default that renders nothing.
- All changes must be backward compatible. An existing deployment must
  upgrade to the new chart with the same values and keep working. Do not
  remove or rename values, change their meaning, or change defaults in a way
  that changes the result. A new value must have a default that keeps the
  current behaviour. If a value must go away, deprecate it first and keep it
  working for at least one release series.
- Keep chart defaults working for the deployments in `zuul.d` and
  `values_overrides/`.
