#!/bin/sh

set -e

# instantiate calicoctl in /opt/bin/cni, including
# a wrapper around the bin that points to the correct
# etcd endpoint and etcd certificate data
cp /calicoctl /host/opt/cni/bin/calicoctl.bin
chmod +x /host/opt/cni/bin/calicoctl.bin

if [ ! -z "$ETCD_KEY" ];
then
DIR=$(dirname /host/$ETCD_KEY_FILE)
mkdir -p $DIR
cat <<EOF>/host/$ETCD_KEY_FILE
$ETCD_KEY
EOF
chmod 600 /host/$ETCD_KEY_FILE
fi;

if [ ! -z "$ETCD_CA_CERT" ];
then
DIR=$(dirname /host/$ETCD_CA_CERT_FILE)
mkdir -p $DIR
cat <<EOF>/host/$ETCD_CA_CERT_FILE
$ETCD_CA_CERT
EOF
chmod 600 /host/$ETCD_CA_CERT_FILE
fi;

if [ ! -z "$ETCD_CERT" ];
then
DIR=$(dirname /host/$ETCD_CERT_FILE)
mkdir -p $DIR
cat <<EOF>/host/$ETCD_CERT_FILE
$ETCD_CERT
EOF
chmod 600 /host/$ETCD_CERT_FILE
fi;

cat <<EOF>/host/opt/cni/bin/calicoctl
export ETCD_ENDPOINTS=$ETCD_ENDPOINTS
if [ -e $ETCD_KEY_FILE ]; then export ETCD_KEY_FILE=$ETCD_KEY_FILE; fi;
if [ -e $ETCD_CERT_FILE ]; then export ETCD_CERT_FILE=$ETCD_CERT_FILE; fi;
if [ -e $ETCD_CA_CERT_FILE ]; then export ETCD_CA_CERT_FILE=$ETCD_CA_CERT_FILE; fi;
exec /opt/cni/bin/calicoctl.bin \$*
EOF

chmod +x /host/opt/cni/bin/calicoctl
