[DEFAULT]
stack_user_domain_name = {{ .Values.keystone.heat_stack_user_domain }}
stack_domain_admin = {{ .Values.keystone.heat_stack_user }}
stack_domain_admin_password = {{ .Values.keystone.heat_stack_password }}
