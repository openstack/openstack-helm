#!/bin/bash

</dev/tcp/{{ .Values.ui_service_name }}.{{ .Release.Namespace }}/{{ .Values.network.port.service_gui }} && \
</dev/tcp/{{ .Values.db_service_name }}.{{ .Release.Namespace }}/{{ .Values.network.port.db_service }} && \
pg_isready -h {{ .Values.db_service_name }}.{{ .Release.Namespace }} && \
maas-region apikey --username={{ .Values.credentials.admin_username }} || exit 1
