Ensure chart-testing is installed

**Role Variables**

.. zuul:rolevar:: chart_testing_version

   Version of chart-testing to install.

.. zuul:rolevar:: ensure_chart_testing_repo_name_helm_chart
   :default: https://github.com/helm/chart-testing/releases/download

   The root location to get the chart testing helm chart.

.. zuul:rolevar:: ensure_chart_testing_repo_name_config
   :default: https://raw.githubusercontent.com/helm/chart-testing

   The root location to get the chart testing configuration files.
