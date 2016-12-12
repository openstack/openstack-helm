Listen {{ .Values.network.ip_address }}:{{ .Values.network.port.public }}
Listen {{ .Values.network.ip_address }}:{{ .Values.network.port.admin }}

<VirtualHost *:{{ .Values.network.port.public }}>
    WSGIDaemonProcess keystone-public processes=16 threads=6 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-public
    WSGIScriptAlias / /var/www/cgi-bin/keystone/main
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    <IfVersion >= 2.4>
      ErrorLogFormat "%{cu}t %M"
    </IfVersion>
    ErrorLog "|$/bin/cat 1>&2"
    CustomLog "|/bin/cat" combined
</VirtualHost>

<VirtualHost *:{{ .Values.network.port.admin }}>
    WSGIDaemonProcess keystone-admin processes=16 threads=5 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-admin
    WSGIScriptAlias / /var/www/cgi-bin/keystone/admin
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    <IfVersion >= 2.4>
      ErrorLogFormat "%{cu}t %M"
    </IfVersion>
    ErrorLog "|$/bin/cat 1>&2"
    CustomLog "|/bin/cat" combined
</VirtualHost>
