set -ex

ospurge --purge-project $OS_TEST_PROJECT_NAME

openstack quota set $OS_TEST_PROJECT_NAME --networks $NETWORK_QUOTA --ports $PORT_QUOTA --routers $ROUTER_QUOTA --subnets $SUBNET_QUOTA --secgroups $SEC_GROUP_QUOTA
