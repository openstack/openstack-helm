---
  CeilometerStats.create_meter_and_get_stats:
    -
      args:
        user_id: "user-id"
        resource_id: "resource-id"
        counter_volume: 1.0
        counter_unit: ""
        counter_type: "cumulative"
      runner:
        type: "constant"
        times: 1
        concurrency: 1
      context:
        users:
          tenants: 1
          users_per_tenant: 1
      sla:
        failure_rate:
          max: 0
  CeilometerMeters.list_meters:
    -
      runner:
        type: constant
        times: 1
        concurrency: 1
      sla:
        failure_rate:
          max: 0
      context:
        users:
          tenants: 1
          users_per_tenant: 1
        ceilometer:
          counter_name: "benchmark_meter"
          counter_type: "gauge"
          counter_unit: "%"
          counter_volume: 1
          resources_per_tenant: 1
          samples_per_resource: 1
          timestamp_interval: 10
          metadata_list:
            -
              status: "active"
              name: "rally benchmark on"
              deleted: "false"
            -
              status: "terminated"
              name: "rally benchmark off"
              deleted: "true"
      args:
        limit: 5
        metadata_query:
          status: "terminated"
  CeilometerQueries.create_and_query_samples:
    -
      args:
        filter: {"=": {"counter_unit": "instance"}}
        orderby: !!null
        limit: 10
        counter_name: "cpu_util"
        counter_type: "gauge"
        counter_unit: "instance"
        counter_volume: 1.0
        resource_id: "resource_id"
      runner:
        type: "constant"
        times: 1
        concurrency: 1
      context:
        users:
          tenants: 1
          users_per_tenant: 1
      sla:
        failure_rate:
          max: 0
