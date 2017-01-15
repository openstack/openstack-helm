#!/bin/sh

set -ex

. /usr/share/debconf/confmodule
db_version 2.0

if [ -f /usr/share/dbconfig-common/dpkg/postinst.pgsql ]; then
    . /usr/share/dbconfig-common/dpkg/postinst.pgsql
fi

RELEASE=`lsb_release -rs` || RELEASE=""

maas_sync_migrate_db(){
    maas-region dbupgrade
}

restart_postgresql(){
    invoke-rc.d --force postgresql restart || true
}

configure_maas_default_url() {
    local ipaddr="$1"
    # The given address is either "[IPv6_IP]" or "IPv4_IP" or "name", such as
    # [2001:db8::3:1]:5555 or 127.0.0.1 or maas.example.com.
    # The ugly sed splits the given thing as:
    #   (string of anything but ":", or [ipv6_ip]),
    #   optionally followed by :port.
    local address=$(echo "$ipaddr" |
        sed -rn 's/^([^:]*|\[[0-9a-fA-F:]*\])(|:[0-9]*)?$/\1/p')
    local port=$(echo "$ipaddr" |
        sed -rn 's/^([^:]*|\[[0-9a-fA-F:]*\])(|:[0-9]*)?$/\2/p')
    test -n "$port" || port=":80"
    ipaddr="${ipaddr}${port}"
    maas-region local_config_set --maas-url "http://${ipaddr}/MAAS"
}

get_default_route_ip6() {
    while read Src SrcPref Dest DestPref Gateway Metric RefCnt Use Flags Iface
    do
        [ "$SrcPref" = 00 ] && [ "$Iface" != lo ] && break
    done < /proc/net/ipv6_route
    if [ -n "$Iface" ]; then
        LC_ALL=C /sbin/ip -6 addr list dev "$Iface" scope global permanent |
            sed -n '/ inet6 /s/.*inet6 \([0-9a-fA-F:]*\).*/[\1]/p' | head -1
    fi
}

get_default_route_ip4() {
    while read Iface Destination Gateway Flags RefCnt Use Metric Mask MTU Window IRTT
    do
        [ "$Mask" = "00000000" ] && break
    done < /proc/net/route
    if [ -n "$Iface" ]; then
        ipaddr=$(LC_ALL=C /sbin/ip -4 addr list dev "$Iface" scope global)
        ipaddr=${ipaddr#* inet }
        ipaddr=${ipaddr%%/*}
        echo $ipaddr
    fi
}

extract_default_maas_url() {
    # Extract DEFAULT_MAAS_URL IP/host setting from config file $1.
    grep "^DEFAULT_MAAS_URL" "$1" | cut -d"/" -f3
}

configure_migrate_maas_dns() {
    # This only runs on upgrade. We only run this if the
    # there are forwarders to migrate or no
    # named.conf.options.inside.maas are present.
    maas-region edit_named_options \
        --migrate-conflicting-options --config-path \
        /etc/bind/named.conf.options
    invoke-rc.d bind9 restart || true
}

if [ "$1" = "configure" ] && [ -z "$2" ]; then
    #########################################################
    ##########  Configure DEFAULT_MAAS_URL  #################
    #########################################################

    # Obtain IP address of default route and change DEFAULT_MAAS_URL
    # if default-maas-url has not been preseeded.  Prefer ipv4 addresses if
    # present, and use "localhost" only if there is no default route in either
    # address family.
    db_get maas/default-maas-url
    ipaddr="$RET"
    if [ -z "$ipaddr" ]; then
        #ipaddr=$(get_default_route_ip4)
        ipaddr="maas-region-ui.{{ .Release.Namespace }}"
    fi
    if [ -z "$ipaddr" ]; then
        #ipaddr=$(get_default_route_ip6)
        ipaddr="maas-region-ui.{{ .Release.Namespace }}"
    fi
    # Fallback default is "localhost"
    if [ -z "$ipaddr" ]; then
        ipaddr=localhost
    fi
    # Set the IP address of the interface with default route
    configure_maas_default_url "$ipaddr"
    db_subst maas/installation-note MAAS_URL "$ipaddr"
    db_set maas/default-maas-url "$ipaddr"

    #########################################################
    ################  Configure Database  ###################
    #########################################################

    # Need to for postgresql start so it doesn't fail on the installer
    restart_postgresql

    # Create the database
    dbc_go maas-region-controller $@
    maas-region local_config_set \
        --database-host "localhost" --database-name "$dbc_dbname" \
        --database-user "$dbc_dbuser" --database-pass "$dbc_dbpass"

    # Only syncdb if we have selected to install it with dbconfig-common.
    db_get maas-region-controller/dbconfig-install
    if [ "$RET" = "true" ]; then
        maas_sync_migrate_db
        configure_migrate_maas_dns
    fi

    db_get maas/username
    username="$RET"
    if [ -n "$username" ]; then
        db_get maas/password
        password="$RET"
        if [ -n "$password" ]; then
            maas-region createadmin --username "$username" --password "$password" --email "$username@maas"
        fi
    fi

    # Display installation note
    db_input low maas/installation-note || true
    db_go

fi

systemctl enable maas-regiond >/dev/null || true
systemctl restart maas-regiond >/dev/null || true
invoke-rc.d apache2 restart || true

if [ -f /lib/systemd/system/maas-rackd.service ]; then
    systemctl restart maas-rackd >/dev/null || true
fi

db_stop
