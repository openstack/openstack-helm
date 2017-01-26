#!/bin/sh

set -ex

function check_for_download {

    TIMEOUT={{ .Values.jobs.import_boot_resources.timeout }}
    while [[ ${TIMEOUT} -gt 0 ]]; do
        if maas {{ .Values.credentials.admin_username }} boot-resources read | grep -q '\[\]';
        then
            echo 'Did not find boot resources.  Will try again'
            let TIMEOUT-={{ .Values.jobs.import_boot_resources.retry_timer }}
            sleep {{ .Values.jobs.import_boot_resources.retry_timer }}
        else
            echo 'Boot resources found'
            exit 0
        fi
    done
    exit 1
}

maas-region local_config_set \
        --database-host "{{ .Values.db_service_name }}.{{ .Release.Namespace }}" \
        --database-name "{{ .Values.database.db_name }}" \
        --database-user "{{ .Values.database.db_user }}" \
        --database-pass "{{ .Values.database.db_password }}" \
        --maas-url "http://{{ .Values.ui_service_name }}.{{ .Release.Namespace }}:{{ .Values.network.port.service_gui }}/MAAS"

KEY=$(maas-region apikey --username={{ .Values.credentials.admin_username }})
maas login {{ .Values.credentials.admin_username }} http://{{ .Values.ui_service_name }}.{{ .Release.Namespace }}/MAAS/ $KEY

# make call to import images
maas {{ .Values.credentials.admin_username }} boot-resources import
# see if we can find > 0 images
sleep {{ .Values.jobs.import_boot_resources.retry_timer }}
check_for_download