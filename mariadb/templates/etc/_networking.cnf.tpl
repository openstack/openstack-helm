[mysqld]
bind_address=0.0.0.0
port={{ .Values.network.port.mariadb }}

# When a client connects, the server will perform hostname resolution,
# and when DNS is slow, establishing the connection will become slow as well.
# It is therefore recommended to start the server with skip-name-resolve to
# disable all DNS lookups. The only limitation is that the GRANT statements
# must then use IP addresses only.
skip_name_resolve

[client]
protocol=tcp
port={{ .Values.network.port.mariadb }}
