[SERVICE]
    Flush          1
    Daemon         Off
    Log_Level      {{ .Values.conf.fluentbit.service.log_level }}
    Parsers_File   parsers.conf

[INPUT]
    Name           tail
    Tag            kube.*
    Path           /var/log/containers/*.log
    Parser         docker
    DB             /var/log/flb_kube.db
    Mem_Buf_Limit  {{ .Values.conf.fluentbit.input.mem_buf_limit }}

[OUTPUT]
    Name          forward
    Match         *
    Host          {{ tuple "aggregator" "internal" . | include "helm-toolkit.endpoints.hostname_short_endpoint_lookup" }}
    Port          {{ tuple "aggregator" "internal" "service" . | include "helm-toolkit.endpoints.endpoint_port_lookup" }}
