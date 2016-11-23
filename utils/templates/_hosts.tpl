{{define "rabbitmq_host"}}rabbitmq.{{.Release.Namespace}}.svc.{{.Values.global.region}}.{{.Values.global.tld}}{{end}}
{{define "memcached_host"}}memcached.{{.Release.Namespace}}.svc.{{.Values.global.region}}.{{.Values.global.tld}}{{end}}
{{define "infra-db"}}infra-db.{{.Release.Namespace}}.svc.kubernetes.{{.Values.global.region}}.{{.Values.global.tld}}{{end}}

{{define "keystone_db_host"}}infra-db.{{.Release.Namespace}}.svc.{{.Values.global.region}}.{{.Values.global.tld}}{{end}}
{{define "keystone_api_endpoint_host_admin"}}keystone.{{.Release.Namespace}}.svc.{{.Values.global.region}}.{{.Values.global.tld}}{{end}}
{{define "keystone_api_endpoint_host_internal"}}keystone.{{.Release.Namespace}}.svc.{{.Values.global.region}}.{{.Values.global.tld}}{{end}}
{{define "keystone_api_endpoint_host_public"}}identity-3.{{.Values.global.region}}.{{.Values.global.tld}}{{end}}
{{define "keystone_api_endpoint_host_admin_ext"}}identity-admin-3.{{.Values.global.region}}.{{.Values.global.tld}}{{end}}
