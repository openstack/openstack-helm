# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

from pathlib import Path
import subprocess
from sphinx.application import Sphinx
from sphinx.util import logging
from sphinx.util.typing import ExtensionMetadata

PREFIX = "[helm_docs] "
VERSION = "0.1"

# the main template we use for all charts
HELMDOCSTMPL = "helm-docs.rst.gotmpl"
LOCALHELMDOCSTMPL = "README.rst.gotmpl"


logger = logging.getLogger(__name__)


def _run_helm_docs(
    helmdocsbin: Path,
    rootdir: Path,
    outfile: Path,
    chart: str,
    helmdocstmpl: Path,
    charttmpl: Path | None,
):
    tmpls = [str(p) for p in [helmdocstmpl, charttmpl] if p is not None]
    cmd = [
        str(helmdocsbin),
        "--output-file",
        str(outfile),
        "--template-files",
        ",".join(tmpls),
        "--chart-search-root",
        chart,
    ]
    subprocess.run(cmd, cwd=str(rootdir), check=True)


def setup(app: Sphinx) -> ExtensionMetadata:
    logger.info(PREFIX + "plugin %s", VERSION)

    # calculate our repo root level
    rootdir = (Path(app.srcdir) / ".." / "..").resolve()
    # our helm-docs binary
    helmdocsbin = rootdir / "tools" / "helm-docs"
    # this is where we will be writing our docs which
    # must be a relative path from a chart directory
    outdir = Path("..") / "doc" / "source" / "chart"
    # where our main helm template is which must be
    # relative to a chart directory
    helmdocstmpl = Path("..") / "doc" / HELMDOCSTMPL

    # find each chart
    for chartyaml in rootdir.rglob("Chart.yaml"):
        # the directory to the chart
        chartdir = chartyaml.parent
        # name of our chart
        chart = chartyaml.parent.name
        logger.info(PREFIX + "found %s", chart)
        # does the chart have a local template to include
        localtmpl = (
            LOCALHELMDOCSTMPL if (chartdir / "README.rst.gotmpl").exists() else None
        )
        outfile = outdir / f"{chart}.rst"
        _run_helm_docs(helmdocsbin, rootdir, outfile, chart, helmdocstmpl, localtmpl)

    return {
        "version": VERSION,
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
