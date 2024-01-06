###########################################
# The lines not confirmed to be working with operator are disabled
###########################################
# DELETE FROM mysql.user WHERE user != 'mariadb.sys';
# CREATE OR REPLACE USER '{{ .Values.endpoints.oslo_db.auth.admin.username }}'@'%' IDENTIFIED BY '{{ .Values.endpoints.oslo_db.auth.admin.password }}';
{{- if .Values.manifests.certificates }}
GRANT ALL ON *.* TO '{{ .Values.endpoints.oslo_db.auth.admin.username }}'@'%' REQUIRE X509 WITH GRANT OPTION;
{{- else }}
GRANT ALL ON *.* TO '{{ .Values.endpoints.oslo_db.auth.admin.username }}'@'%' WITH GRANT OPTION;
{{- end }}
DROP DATABASE IF EXISTS test ;
# CREATE OR REPLACE USER '{{ .Values.endpoints.oslo_db.auth.sst.username }}'@'127.0.0.1' IDENTIFIED BY '{{ .Values.endpoints.oslo_db.auth.sst.password }}';
# GRANT PROCESS, RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '{{ .Values.endpoints.oslo_db.auth.sst.username }}'@'127.0.0.1' ;
CREATE OR REPLACE USER '{{ .Values.endpoints.oslo_db.auth.audit.username }}'@'%' IDENTIFIED BY '{{ .Values.endpoints.oslo_db.auth.audit.password }}';
{{- if .Values.manifests.certificates }}
GRANT SELECT ON *.* TO '{{ .Values.endpoints.oslo_db.auth.audit.username }}'@'%' REQUIRE X509;
{{- else }}
GRANT SELECT ON *.* TO '{{ .Values.endpoints.oslo_db.auth.audit.username }}'@'%' ;
{{- end }}
FLUSH PRIVILEGES ;
