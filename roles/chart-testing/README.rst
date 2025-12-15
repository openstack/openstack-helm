Run chart-testing (for helm charts)

**Role Variables**

.. zuul:rolevar:: zuul_work_dir
   :default: {{ zuul.project.src_dir }}

   The location of the main working directory of the job.

.. zuul:rolevar:: chart_testing_options
   :default: --validate-maintainers=false --check-version-increment=false

   Arguments passed to chart testing.

   The defaults are suitable for a Zuul environment because
   `validate-maintainers` requires a valid git remote (which is not
   present in Zuul) and `check-version-increment` requires each commit
   to have a new version; Zuul users are expected to set the version
   when tagging/publishing a release.
