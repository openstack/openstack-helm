[database]
connection = mysql+pymysql://{{ .Values.database.heat_user }}:{{ .Values.database.heat_password }}@{{ .Values.database.address }}:{{ .Values.database.port }}/{{ .Values.database.heat_database_name }}
max_retries = -1
