chown -R rabbitmq:rabbitmq /var/lib/rabbitmq

/etc/init.d/rabbitmq-server start

rabbitmq-plugins enable rabbitmq_tracing
rabbitmqctl trace_on

rabbitmqctl add_user {{ .Values.auth.default_user }} {{ .Values.auth.default_pass }} || true
rabbitmqctl set_permissions {{ .Values.auth.default_user }} ".*" ".*" ".*" || true

rabbitmqctl add_user {{ .Values.auth.admin_user }} {{ .Values.auth.admin_pass }}|| true
rabbitmqctl set_permissions {{ .Values.auth.admin_user }} ".*" ".*" ".*" || true
rabbitmqctl set_user_tags {{ .Values.auth.admin_user }} administrator || true

rabbitmqctl change_password guest  {{ .Values.auth.default_pass }} || true
rabbitmqctl set_user_tags guest monitoring || true
/etc/init.d/rabbitmq-server stop
exec rabbitmq-server