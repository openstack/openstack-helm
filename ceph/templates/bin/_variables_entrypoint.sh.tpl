##########################################
# LIST OF ALL DAEMON SCENARIOS AVAILABLE #
##########################################

ALL_SCENARIOS="osd osd_directory osd_directory_single osd_ceph_disk osd_ceph_disk_prepare osd_ceph_disk_activate osd_ceph_activate_journal mgr"


#########################
# LIST OF ALL VARIABLES #
#########################

: ${CLUSTER:=ceph}
: ${CLUSTER_PATH:=ceph-config/${CLUSTER}} # For KV config
: ${CEPH_CLUSTER_NETWORK:=${CEPH_PUBLIC_NETWORK}}
: ${CEPH_DAEMON:=${1}} # default daemon to first argument
: ${CEPH_GET_ADMIN_KEY:=0}
: ${HOSTNAME:=$(uname -n)}
: ${MON_NAME:=${HOSTNAME}}
# (openstack-helm): we need the MONMAP to be stateful, so we retain it
: ${MONMAP=/etc/ceph/monmap-${CLUSTER}}
: ${MON_DATA_DIR:=/var/lib/ceph/mon/${CLUSTER}-${MON_NAME}}
: ${K8S_HOST_NETWORK:=0}
: ${NETWORK_AUTO_DETECT:=0}
: ${MDS_NAME:=mds-${HOSTNAME}}
: ${OSD_FORCE_ZAP:=0}
: ${OSD_JOURNAL_SIZE:=100}
: ${OSD_BLUESTORE:=0}
: ${OSD_DMCRYPT:=0}
: ${OSD_JOURNAL_UUID:=$(uuidgen)}
: ${OSD_LOCKBOX_UUID:=$(uuidgen)}
: ${CRUSH_LOCATION:=root=default host=${HOSTNAME}}
: ${CEPHFS_CREATE:=0}
: ${CEPHFS_NAME:=cephfs}
: ${CEPHFS_DATA_POOL:=${CEPHFS_NAME}_data}
: ${CEPHFS_DATA_POOL_PG:=8}
: ${CEPHFS_METADATA_POOL:=${CEPHFS_NAME}_metadata}
: ${CEPHFS_METADATA_POOL_PG:=8}
: ${RGW_NAME:=${HOSTNAME}}
: ${RGW_ZONEGROUP:=}
: ${RGW_ZONE:=}
: ${RGW_CIVETWEB_PORT:=8080}
: ${RGW_REMOTE_CGI:=0}
: ${RGW_REMOTE_CGI_PORT:=9000}
: ${RGW_REMOTE_CGI_HOST:=0.0.0.0}
: ${RGW_USER:="cephnfs"}
: ${MGR_NAME:=${HOSTNAME}}
: ${MGR_DASHBOARD:=1}
: ${MGR_IP:=0.0.0.0}
: ${MGR_PORT:=7000}
: ${RBD_POOL_PG:=128}

# This is ONLY used for the CLI calls, e.g: ceph $CLI_OPTS health
CLI_OPTS="--cluster ${CLUSTER}"

# This is ONLY used for the daemon's startup, e.g: ceph-osd $DAEMON_OPTS
DAEMON_OPTS="--cluster ${CLUSTER} --setuser ceph --setgroup ceph -d"

MOUNT_OPTS="-t xfs -o noatime,inode64"

# Internal variables
MDS_KEYRING=/var/lib/ceph/mds/${CLUSTER}-${MDS_NAME}/keyring
ADMIN_KEYRING=/etc/ceph/${CLUSTER}.client.admin.keyring
MON_KEYRING=/etc/ceph/${CLUSTER}.mon.keyring
RGW_KEYRING=/var/lib/ceph/radosgw/${RGW_NAME}/keyring
MGR_KEYRING=/var/lib/ceph/mgr/${CLUSTER}-${MGR_NAME}/keyring
MDS_BOOTSTRAP_KEYRING=/var/lib/ceph/bootstrap-mds/${CLUSTER}.keyring
RGW_BOOTSTRAP_KEYRING=/var/lib/ceph/bootstrap-rgw/${CLUSTER}.keyring
OSD_BOOTSTRAP_KEYRING=/var/lib/ceph/bootstrap-osd/${CLUSTER}.keyring
OSD_PATH_BASE=/var/lib/ceph/osd/${CLUSTER}
