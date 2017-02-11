#!/bin/bash

set -ex

# show env
env > /tmp/env

echo "register-rack-controller URL: "{{ .Values.service_name }}.{{ .Release.Namespace }}

# note the secret must be a valid hex value

# register forever
while [ 1 ];
do
	if maas-rack register --url=http://{{ .Values.service_name }}.{{ .Release.Namespace }}/MAAS --secret={{ .Values.secret | quote }};
	then
		echo "Successfully registered with MaaS Region Controller"
		break
	else
		echo "Unable to register with http://{{ .Values.service_name }}.{{ .Release.Namespace }}/MAAS... will try again"
		sleep 10
	fi;

done;