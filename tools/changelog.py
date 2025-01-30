import argparse
import os.path
from collections import defaultdict

from reno import config
from reno import loader


BEFORE_2024_2_0_NOTE = """Before 2024.2.0 all the OpenStack-Helm charts were versioned independently.
Here we provide all the release notes for the chart for all versions before 2024.2.0.
"""

def _indent_for_list(text, prefix='  '):
    lines = text.splitlines()
    return '\n'.join([lines[0]] + [
        prefix + l
        for l in lines[1:]
    ])


def chart_reports(loader, config, versions_to_include, title=None, charts=None):
    reports = defaultdict(list)

    file_contents = {}
    for version in versions_to_include:
        for filename, sha in loader[version]:
            body = loader.parse_note_file(filename, sha)
            file_contents[filename] = body

    for chart in charts:
        if title:
            reports[chart].append(f"# {title}")
            reports[chart].append('')

        for version in versions_to_include:
            if '-' in version:
                version_title = config.unreleased_version_title or version
            else:
                version_title = version

            reports[chart].append(f"## {version_title}")
            reports[chart].append('')

            if version == "2024.2.0":
                reports[chart].append(BEFORE_2024_2_0_NOTE)

            if config.add_release_date:
                reports[chart].append('Release Date: ' + loader.get_version_date(version))
                reports[chart].append('')

            notefiles = loader[version]

            # Prepare not named section
            # 1. Get all files named <chart>*.yaml
            #    and get <chart> section from all these files
            # 2. Get all files named common*.yaml and get <chart>
            #    section from all these files
            is_content = False
            for fn, sha in notefiles:
                if os.path.basename(fn).startswith(chart) or \
                        os.path.basename(fn).startswith("common"):
                    notes = file_contents[fn].get(chart, [])
                    for n in notes:
                        is_content = True
                        reports[chart].append(f"- {_indent_for_list(n)}")

            # Add new line after unnamed section if it is not empty
            if is_content:
                reports[chart].append("")

            # Prepare named sections
            # 1. Get all files named <chart>*.yaml
            #    and get all sections from all these files except <chart>
            # 2. Get all files named common*.yaml
            #    and get all sections from all these files except <chart>
            for section in config.sections:
                is_content = False

                # Skip chart specific sections
                if section.name not in ["features", "isseus", "upgrade", "api", "security", "fixes"]:
                    continue

                for fn, sha in notefiles:
                    if os.path.basename(fn).startswith(chart) or \
                            os.path.basename(fn).startswith("common"):

                        notes = file_contents[fn].get(section.name, [])

                        if notes and not is_content:
                            reports[chart].append(f"### {section.title}")
                            reports[chart].append("")

                        if notes:
                            is_content = True
                            for n in notes:
                                reports[chart].append(f"- {_indent_for_list(n)}")

                # Add new line after the section if it is not empty
                if is_content:
                    reports[chart].append("")

        report = reports[chart]
        reports[chart] = '\n'.join(report)

    return reports


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--charts", nargs="+", default=[], help="Charts to generate release notes for")
    args = parser.parse_args()

    conf = config.Config(".", "releasenotes")

    with loader.Loader(conf) as ldr:
        versions = ldr.versions
        reports = chart_reports(
            ldr,
            conf,
            versions,
            title="Release notes",
            charts=args.charts,
        )

    for chart in reports:
        with open(f"{chart}/CHANGELOG.md", "w") as f:
            f.write(reports[chart])
    return


if __name__ == "__main__":
    main()
