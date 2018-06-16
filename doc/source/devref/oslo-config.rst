OSLO-Config Values
------------------

OpenStack-Helm generates oslo-config compatible formatted configuration files for
services dynamically from values specified in a yaml tree. This allows operators to
control any and all aspects of an OpenStack services configuration. An example
snippet for an imaginary Keystone configuration is described here:

::

    conf:
      keystone:
        DEFAULT: # Keys at this level are used for section headings
          max_token_size: 255
        token:
          provider: fernet
        fernet_tokens:
          key_repository: /etc/keystone/fernet-keys/
        credential:
          key_repository: /etc/keystone/credential-keys/
        database:
          max_retries: -1
        cache:
          enabled: true
          backend: dogpile.cache.memcached
        oslo_messaging_notifications:
          driver: # An example of a multistring option's syntax
            type: multistring
            values:
              - messagingv2
              - log
        security_compliance:
          password_expires_ignore_user_ids:
          # Values in a list will be converted to a comma separated key
            - "123"
            - "456"

This will be consumed by the templated ``configmap-etc.yaml`` manifest to
produce the following config file:

::

    ---
    # Source: keystone/templates/configmap-etc.yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: keystone-etc
    data:
      keystone.conf: |
        [DEFAULT]
        max_token_size = 255
        transport_url = rabbit://keystone:password@rabbitmq.default.svc.cluster.local:5672/openstack
        [cache]
        backend = dogpile.cache.memcached
        enabled = true
        memcache_servers = memcached.default.svc.cluster.local:11211
        [credential]
        key_repository = /etc/keystone/credential-keys/
        [database]
        connection = mysql+pymysql://keystone:password@mariadb.default.svc.cluster.local:3306/keystone
        max_retries = -1
        [fernet_tokens]
        key_repository = /etc/keystone/fernet-keys/
        [oslo_messaging_notifications]
        driver = messagingv2
        driver = log
        [security_compliance]
        password_expires_ignore_user_ids = 123,456
        [token]
        provider = fernet

Note that some additional values have been injected into the config file, this is
performed via statements in the configmap template, which also calls the
``helm-toolkit.utils.to_oslo_conf`` to convert the yaml to the required layout:

::

    {{- if empty .Values.conf.keystone.database.connection -}}
    {{- $_ := tuple "oslo_db" "internal" "user" "mysql" . | include "helm-toolkit.endpoints.authenticated_endpoint_uri_lookup"| set .Values.conf.keystone.database "connection" -}}
    {{- end -}}

    {{- if empty .Values.conf.keystone.DEFAULT.transport_url -}}
    {{- $_ := tuple "oslo_messaging" "internal" "user" "amqp" . | include "helm-toolkit.endpoints.authenticated_endpoint_uri_lookup" | set .Values.conf.keystone.DEFAULT "transport_url" -}}
    {{- end -}}

    {{- if empty .Values.conf.keystone.cache.memcache_servers -}}
    {{- $_ := tuple "oslo_cache" "internal" "memcache" . | include "helm-toolkit.endpoints.host_and_port_endpoint_uri_lookup" | set .Values.conf.keystone.cache "memcache_servers" -}}
    {{- end -}}

    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: keystone-etc
    data:
      keystone.conf: |
    {{ include "helm-toolkit.utils.to_oslo_conf" .Values.conf.keystone | indent 4 }}
    {{- end }}
