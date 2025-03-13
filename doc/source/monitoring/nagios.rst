Nagios
======

The Nagios chart in openstack-helm-infra can be used to provide an alarming
service that's tightly coupled to an OpenStack-Helm deployment.  The Nagios
chart uses a custom Nagios core image that includes plugins developed to query
Prometheus directly for scraped metrics and triggered alarms, query the Ceph
manager endpoints directly to determine the health of a Ceph cluster, and to
query Elasticsearch for logged events that meet certain criteria (experimental).

Authentication
--------------

The Nagios deployment includes a sidecar container that runs an Apache reverse
proxy to add authentication capabilities for Nagios.  The username and password
are configured under the nagios entry in the endpoints section of the chart's
values.yaml.

The configuration for Apache can be found under the conf.httpd key, and uses a
helm-toolkit function that allows for including gotpl entries in the template
directly.  This allows the use of other templates, like the endpoint lookup
function templates, directly in the configuration for Apache.

Image Plugins
-------------

The Nagios image used contains custom plugins that can be used for the defined
service check commands.  These plugins include:

- check_prometheus_metric.py: Query Prometheus for a specific metric and value
- check_exporter_health_metric.sh: Nagios plugin to query prometheus exporter
- check_rest_get_api.py: Check REST API status
- check_update_prometheus_hosts.py: Queries Prometheus, updates Nagios config
- query_prometheus_alerts.py: Nagios plugin to query prometheus ALERTS metric

More information about the Nagios image and plugins can be found here_.

.. _here: https://github.com/att-comdev/nagios


Nagios Service Configuration
----------------------------

The Nagios service is configured via the following section in the chart's
values file:

::

    conf:
      nagios:
        nagios:
          log_file: /opt/nagios/var/log/nagios.log
          cfg_file:
            - /opt/nagios/etc/nagios_objects.cfg
            - /opt/nagios/etc/objects/commands.cfg
            - /opt/nagios/etc/objects/contacts.cfg
            - /opt/nagios/etc/objects/timeperiods.cfg
            - /opt/nagios/etc/objects/templates.cfg
            - /opt/nagios/etc/objects/prometheus_discovery_objects.cfg
          object_cache_file: /opt/nagios/var/objects.cache
          precached_object_file: /opt/nagios/var/objects.precache
          resource_file: /opt/nagios/etc/resource.cfg
          status_file: /opt/nagios/var/status.dat
          status_update_interval: 10
          nagios_user: nagios
          nagios_group: nagios
          check_external_commands: 1
          command_file: /opt/nagios/var/rw/nagios.cmd
          lock_file: /var/run/nagios.lock
          temp_file: /opt/nagios/var/nagios.tmp
          temp_path: /tmp
          event_broker_options: -1
          log_rotation_method: d
          log_archive_path: /opt/nagios/var/log/archives
          use_syslog: 1
          log_service_retries: 1
          log_host_retries: 1
          log_event_handlers: 1
          log_initial_states: 0
          log_current_states: 1
          log_external_commands: 1
          log_passive_checks: 1
          service_inter_check_delay_method: s
          max_service_check_spread: 30
          service_interleave_factor: s
          host_inter_check_delay_method: s
          max_host_check_spread: 30
          max_concurrent_checks: 60
          check_result_reaper_frequency: 10
          max_check_result_reaper_time: 30
          check_result_path: /opt/nagios/var/spool/checkresults
          max_check_result_file_age: 3600
          cached_host_check_horizon: 15
          cached_service_check_horizon: 15
          enable_predictive_host_dependency_checks: 1
          enable_predictive_service_dependency_checks: 1
          soft_state_dependencies: 0
          auto_reschedule_checks: 0
          auto_rescheduling_interval: 30
          auto_rescheduling_window: 180
          service_check_timeout: 60
          host_check_timeout: 60
          event_handler_timeout: 60
          notification_timeout: 60
          ocsp_timeout: 5
          perfdata_timeout: 5
          retain_state_information: 1
          state_retention_file: /opt/nagios/var/retention.dat
          retention_update_interval: 60
          use_retained_program_state: 1
          use_retained_scheduling_info: 1
          retained_host_attribute_mask: 0
          retained_service_attribute_mask: 0
          retained_process_host_attribute_mask: 0
          retained_process_service_attribute_mask: 0
          retained_contact_host_attribute_mask: 0
          retained_contact_service_attribute_mask: 0
          interval_length: 1
          check_workers: 4
          check_for_updates: 1
          bare_update_check: 0
          use_aggressive_host_checking: 0
          execute_service_checks: 1
          accept_passive_service_checks: 1
          execute_host_checks: 1
          accept_passive_host_checks: 1
          enable_notifications: 1
          enable_event_handlers: 1
          process_performance_data: 0
          obsess_over_services: 0
          obsess_over_hosts: 0
          translate_passive_host_checks: 0
          passive_host_checks_are_soft: 0
          check_for_orphaned_services: 1
          check_for_orphaned_hosts: 1
          check_service_freshness: 1
          service_freshness_check_interval: 60
          check_host_freshness: 0
          host_freshness_check_interval: 60
          additional_freshness_latency: 15
          enable_flap_detection: 1
          low_service_flap_threshold: 5.0
          high_service_flap_threshold: 20.0
          low_host_flap_threshold: 5.0
          high_host_flap_threshold: 20.0
          date_format: us
          use_regexp_matching: 1
          use_true_regexp_matching: 0
          daemon_dumps_core: 0
          use_large_installation_tweaks: 0
          enable_environment_macros: 0
          debug_level: 0
          debug_verbosity: 1
          debug_file: /opt/nagios/var/nagios.debug
          max_debug_file_size: 1000000
          allow_empty_hostgroup_assignment: 1
          illegal_macro_output_chars: "`~$&|'<>\""

Nagios CGI Configuration
------------------------

The Nagios CGI configuration is defined via the following section in the chart's
values file:

::

    conf:
      nagios:
        cgi:
          main_config_file: /opt/nagios/etc/nagios.cfg
          physical_html_path: /opt/nagios/share
          url_html_path: /nagios
          show_context_help: 0
          use_pending_states: 1
          use_authentication: 0
          use_ssl_authentication: 0
          authorized_for_system_information: "*"
          authorized_for_configuration_information: "*"
          authorized_for_system_commands: nagiosadmin
          authorized_for_all_services: "*"
          authorized_for_all_hosts: "*"
          authorized_for_all_service_commands: "*"
          authorized_for_all_host_commands: "*"
          default_statuswrl_layout: 4
          ping_syntax: /bin/ping -n -U -c 5 $HOSTADDRESS$
          refresh_rate: 90
          result_limit: 100
          escape_html_tags: 1
          action_url_target: _blank
          notes_url_target: _blank
          lock_author_names: 1
          navbar_search_for_addresses: 1
          navbar_search_for_aliases: 1

Nagios Host Configuration
-------------------------

The Nagios chart includes a single host definition for the Prometheus instance
queried for metrics.  The host definition can be found under the following
values key:

::

    conf:
      nagios:
        hosts:
          - prometheus:
              use: linux-server
              host_name: prometheus
              alias: "Prometheus Monitoring"
              address: 127.0.0.1
              hostgroups: prometheus-hosts
              check_command: check-prometheus-host-alive

The address for the Prometheus host is defined by the PROMETHEUS_SERVICE
environment variable in the deployment template, which is determined by the
monitoring entry in the Nagios chart's endpoints section.  The endpoint is then
available as a macro for Nagios to use in all Prometheus based queries.  For
example:

::

    - check_prometheus_host_alive:
        command_name: check-prometheus-host-alive
        command_line: "$USER1$/check_rest_get_api.py --url $USER2$ --warning_response_seconds 5 --critical_response_seconds 10"

The $USER2$ macro above corresponds to the Prometheus endpoint defined in the
PROMETHEUS_SERVICE environment variable.  All checks that use the
prometheus-hosts hostgroup will map back to the Prometheus host defined by this
endpoint.

Nagios HostGroup Configuration
------------------------------

The Nagios chart includes configuration values for defined host groups under the
following values key:

::

    conf:
      nagios:
        host_groups:
          - prometheus-hosts:
              hostgroup_name: prometheus-hosts
              alias: "Prometheus Virtual Host"
          - base-os:
              hostgroup_name: base-os
              alias: "base-os"

These hostgroups are used to define which group of hosts should be targeted by
a particular nagios check.  An example of a check that targets Prometheus for a
specific metric query would be:

::

    - check_ceph_monitor_quorum:
        use: notifying_service
        hostgroup_name: prometheus-hosts
        service_description: "CEPH_quorum"
        check_command: check_prom_alert!ceph_monitor_quorum_low!CRITICAL- ceph monitor quorum does not exist!OK- ceph monitor quorum exists
        check_interval: 60

An example of a check that targets all hosts for a base-os type check (memory
usage, latency, etc) would be:

::

    - check_memory_usage:
        use: notifying_service
        service_description: Memory_usage
        check_command: check_memory_usage
        hostgroup_name: base-os

These two host groups allow for a wide range of targeted checks for determining
the status of all components of an OpenStack-Helm deployment.

Nagios Command Configuration
----------------------------

The Nagios chart includes configuration values for the command definitions Nagios
will use when executing service checks. These values are found under the
following key:

::

    conf:
      nagios:
        commands:
          - send_service_snmp_trap:
              command_name: send_service_snmp_trap
              command_line: "$USER1$/send_service_trap.sh '$USER8$' '$HOSTNAME$' '$SERVICEDESC$' $SERVICESTATEID$ '$SERVICEOUTPUT$' '$USER4$' '$USER5$'"
          - send_host_snmp_trap:
              command_name: send_host_snmp_trap
              command_line: "$USER1$/send_host_trap.sh '$USER8$' '$HOSTNAME$' $HOSTSTATEID$ '$HOSTOUTPUT$' '$USER4$' '$USER5$'"
          - send_service_http_post:
              command_name: send_service_http_post
              command_line: "$USER1$/send_http_post_event.py --type service --hostname '$HOSTNAME$' --servicedesc '$SERVICEDESC$' --state_id $SERVICESTATEID$ --output '$SERVICEOUTPUT$' --monitoring_hostname '$HOSTNAME$' --primary_url '$USER6$' --secondary_url '$USER7$'"
          - send_host_http_post:
              command_name: send_host_http_post
              command_line: "$USER1$/send_http_post_event.py --type host --hostname '$HOSTNAME$' --state_id $HOSTSTATEID$ --output '$HOSTOUTPUT$' --monitoring_hostname '$HOSTNAME$' --primary_url '$USER6$' --secondary_url '$USER7$'"
          - check_prometheus_host_alive:
              command_name: check-prometheus-host-alive
              command_line: "$USER1$/check_rest_get_api.py --url $USER2$ --warning_response_seconds 5 --critical_response_seconds 10"

The list of defined commands can be modified with configuration overrides, which
allows for the ability define commands specific to an infrastructure deployment.
These commands can include querying Prometheus for metrics on dependencies for a
service to determine whether an alert should be raised, executing checks on each
host to determine network latency or file system usage, or checking each node
for issues with ntp clock skew.

Note: Since the conf.nagios.commands key contains a list of the defined commands,
the entire contents of conf.nagios.commands will need to be overridden if
additional commands are desired (due to the immutable nature of lists).

Nagios Service Check Configuration
----------------------------------

The Nagios chart includes configuration values for the service checks Nagios
will execute.  These service check commands can be found under the following
key:

::
    conf:
      nagios:
        services:
          - notifying_service:
              name: notifying_service
              use: generic-service
              flap_detection_enabled: 0
              process_perf_data: 0
              contact_groups: snmp_and_http_notifying_contact_group
              check_interval: 60
              notification_interval: 120
              retry_interval: 30
              register: 0
          - check_ceph_health:
              use: notifying_service
              hostgroup_name: base-os
              service_description: "CEPH_health"
              check_command: check_ceph_health
              check_interval: 300
          - check_hosts_health:
              use: generic-service
              hostgroup_name: prometheus-hosts
              service_description: "Nodes_health"
              check_command: check_prom_alert!K8SNodesNotReady!CRITICAL- One or more nodes are not ready.
              check_interval: 60
          - check_prometheus_replicas:
              use: notifying_service
              hostgroup_name: prometheus-hosts
              service_description: "Prometheus_replica-count"
              check_command: check_prom_alert_with_labels!replicas_unavailable_statefulset!statefulset="prometheus"!statefulset {statefulset} has lesser than configured replicas
              check_interval: 60

The Nagios service configurations define the checks Nagios will perform.  These
checks contain keys for defining: the service type to use, the host group to
target, the description of the service check, the command the check should use,
and the interval at which to trigger the service check.  These services can also
be extended to provide additional insight into the overall status of a
particular service.  These services also allow the ability to define advanced
checks for determining the overall health and liveness of a service.  For
example, a service check could trigger an alarm for the OpenStack services when
Nagios detects that the relevant database and message queue has become
unresponsive.
