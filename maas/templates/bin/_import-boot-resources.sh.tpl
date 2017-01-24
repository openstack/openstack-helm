#!/bin/sh

set -ex

function check_for_download {

    if maas {{ .Values.credentials.admin_username }} boot-resources read | grep -q '\[\]';
    then
        echo 'Did not find boot resources.  Will try again'
        sleep 60
        exit 1
    else
        echo 'Boot resources found'
        exit 0
    fi

}

maas-region local_config_set \
        --database-host "{{ .Values.db_service_name }}.{{ .Release.Namespace}}" \
        --database-name "{{ .Values.database.db_name }}" \
        --database-user "{{ .Values.database.db_user }}" \
        --database-pass "{{ .Values.database.db_password }}" \
        --maas-url "http://{{ .Values.ui_service_name }}.{{ .Release.Namespace }}:80/MAAS"

KEY=$(maas-region apikey --username={{ .Values.credentials.admin_username }})
maas login {{ .Values.credentials.admin_username }} http://{{ .Values.ui_service_name }}.{{ .Release.Namespace }}/MAAS/ $KEY

# make call to import images
maas {{ .Values.credentials.admin_username }} boot-resources import
# see if we can find > 0 images
sleep 10
check_for_download
