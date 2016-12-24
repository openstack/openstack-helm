Listen 0.0.0.0:{{ .Values.network.port}}

<VirtualHost *:{{ .Values.network.port}}>
    LogLevel warn
    ErrorLog /var/log/apache2/horizon.log
    CustomLog /var/log/apache2/horizon-access.log combined

    WSGIScriptReloading On
    WSGIDaemonProcess horizon-http processes=5 threads=1 user=horizon group=horizon display-name=%{GROUP} python-path=/var/lib/kolla/venv/lib/python2.7/site-packages
    WSGIProcessGroup horizon-http
    WSGIScriptAlias / /var/lib/kolla/venv/lib/python2.7/site-packages/openstack_dashboard/wsgi/django.wsgi
    WSGIPassAuthorization On

    <Location "/">
        Require all granted
    </Location>

    Alias /static /var/lib/kolla/venv/lib/python2.7/site-packages/static
    <Location "/static">
        SetHandler None
    </Location>
</Virtualhost>

