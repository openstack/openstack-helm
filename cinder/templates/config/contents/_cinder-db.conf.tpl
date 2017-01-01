[database]
connection = mysql+pymysql://{{ .Values.database.cinder_user }}:{{ .Values.database.cinder_password }}@{{ .Values.database.address }}:{{ .Values.database.port }}/{{ .Values.database.cinder_database_name }}
max_retries = -1
