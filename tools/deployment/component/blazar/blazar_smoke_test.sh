#!/bin/bash

#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
set -ex

export OS_CLOUD=openstack_helm

BLAZAR_DIR="$(readlink -f ./tools/deployment/component/blazar)"
SSH_DIR="${HOME}/.ssh"

OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS="${OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS} -v ${BLAZAR_DIR}:${BLAZAR_DIR} -v ${SSH_DIR}:${SSH_DIR}"
export OPENSTACK_CLIENT_CONTAINER_EXTRA_ARGS

echo "Test: Starting the process to delete all existing Blazar leases, if any"

lease_ids=$(openstack reservation lease list -c id -f value)
sleep 2

# Check if the list of leases is empty.
if [ -z "$lease_ids" ]; then
  echo "Test: No leases found to delete"
else
  echo "Test: The following lease IDs will be deleted:"
  echo "$lease_ids"
  echo "-------------------------------------"

  while IFS= read -r lease_id; do
    echo "Test: Deleting lease with ID: $lease_id"
    openstack reservation lease delete "$lease_id"
    sleep 2
    echo "Test: Lease $lease_id deleted."
  done <<< "$lease_ids"

  echo "-------------------------------------"
  echo "Test: All Blazar leases have been successfully deleted"
fi

echo "Test: Starting the process to delete all existing Blazar hosts, if any"

openstack host list
sleep 2
openstack reservation host list
sleep 2

host_ids=$(openstack reservation host list -c id -f value)
sleep 2

# Check if the list of hosts is empty.
if [ -z "$host_ids" ]; then
  echo "Test: No hosts found to delete"
else
  echo "Test: The following host IDs will be deleted:"
  echo "$host_ids"
  echo "-------------------------------------"

  while IFS= read -r host_id; do

    # Get the list of servers on the specified host
    SERVER_LIST=$(openstack server list --host "$host_id" -f value -c id)
    sleep 2

    # Check if any servers were found
    if [ -z "$SERVER_LIST" ]; then
      echo "No servers found on host '$host_id'"
    else
      # Delete all servers on the host
      echo "Deleting servers on host '$host_id'"
      for SERVER_ID in $SERVER_LIST; do
        echo "Deleting server $SERVER_ID"
        openstack server delete "$SERVER_ID"
      done
      echo "All servers on host '$host_id' have been deleted"
    fi

    echo "Test: Deleting host with ID: $host_id"
    openstack reservation host delete "$host_id"
    sleep 2
    echo "Test: Host $host_id deleted"
  done <<< "$host_ids"

  echo "-------------------------------------"
  echo "Test: All Blazar hosts have been successfully deleted"
fi

echo "Test: list all the services"
openstack service list
sleep 2

echo "Test: list all the endpoints"
openstack endpoint list
sleep 2

echo "Test: list all the hypervisors"
openstack hypervisor list
sleep 2

echo "Extract the first available compute host name from the list of hosts"
FIRST_COMPUTE_HOST=$(openstack host list | grep 'compute' | awk '{print $2}' | head -n 1)
sleep 2

# A simple check to see if a host name was successfully found.
if [ -z "$FIRST_COMPUTE_HOST" ]; then
    echo "Error: No compute host found in the list"
    exit 1
else
    echo "The first compute host found is: $FIRST_COMPUTE_HOST"
fi
sleep 2

# Set a variable for the aggregate name
AGGREGATE_NAME="freepool"

echo "Test: Checking if aggregate '${AGGREGATE_NAME}' already exists"
AGGREGATE_FOUND=$(openstack aggregate list | grep " ${AGGREGATE_NAME} " | cut -d '|' -f 3 | tr -d ' ' 2>/dev/null || true)
sleep 2

# Check if the AGGREGATE_FOUND variable is empty.
if [ -z "$AGGREGATE_FOUND" ]; then
  echo "Test: Aggregate '${AGGREGATE_NAME}' not found, Creating it now"
  openstack aggregate create "${AGGREGATE_NAME}"
  sleep 5
  # Check the exit status of the previous command.
  if [ $? -eq 0 ]; then
    echo "Test: Aggregate '${AGGREGATE_NAME}' created successfully"
  else
    echo "Test: Failed to create aggregate '${AGGREGATE_NAME}'"
  fi
else
  echo "Test: Aggregate '${AGGREGATE_NAME}' already exists"
fi
sleep 2

echo "Test: list all the aggregates after creating/checking freepool aggregate"
openstack aggregate list
sleep 2

echo "Test: Add host into the Blazar freepool"
openstack reservation host create $FIRST_COMPUTE_HOST
sleep 5

echo "Test: Add extra capabilities to host to add other properties"
openstack reservation host set --extra gpu=True $FIRST_COMPUTE_HOST
sleep 2

echo "Test: list hosts in the blazar freepool after adding a host"
openstack reservation host list
sleep 2

# Get the current date in YYYY-MM-DD format, generate start and end dates
current_date=$(date +%Y-%m-%d)
start_date=$(date -d "$current_date + 1 day" +%Y-%m-%d\ 12:00)
end_date=$(date -d "$current_date + 2 day" +%Y-%m-%d\ 12:00)

echo "Test: Create a lease (compute host reservation)"
openstack reservation lease create \
 --reservation resource_type=physical:host,min=1,max=1,hypervisor_properties='[">=", "$vcpus", "2"]' \
 --start-date "$start_date" \
 --end-date "$end_date" \
 lease-test-comp-host-res
sleep 5

echo "Test: list leases after creating a lease"
openstack reservation lease list
sleep 2

echo "Test: list projects"
openstack project list
sleep 2

echo "Test: list flavors"
openstack flavor list
sleep 2

echo "Test: list images"
openstack image list
sleep 2

echo "Test: list networks"
openstack network list
sleep 2

# Get the flavor ID for m1.tiny
FLAVOR_ID=$(openstack flavor show m1.tiny -f value -c id)
sleep 2

# Get the image ID for Cirros 0.6.2 64-bit
IMAGE_ID=$(openstack image show "Cirros 0.6.2 64-bit" -f value -c id)
sleep 2

# --- Network ---
# Check if a network named "net1" exists
if ! openstack network show net1 &> /dev/null; then
  echo "Network 'net1' not found. Creating now"
  sleep 2
  openstack network create net1
  sleep 2
else
  echo "Network 'net1' already exists."
fi

NETWORK_ID=$(openstack network show net1 -f value -c id)
sleep 2

# --- Subnet ---
# Check if a subnet named "subnet1" exists
if ! openstack subnet show subnet1 &> /dev/null; then
  echo "Subnet 'subnet1' not found. Creating now"
  sleep 2
  openstack subnet create \
    --network "$NETWORK_ID" \
    --subnet-range 10.0.0.0/24 \
    --allocation-pool start=10.0.0.2,end=10.0.0.254 \
    --gateway 10.0.0.1 \
    subnet1
    sleep 2
else
  echo "Subnet 'subnet1' already exists."
fi

SUBNET_ID=$(openstack subnet show subnet1 -f value -c id)
sleep 2

# --- Router ---
# Check if a router named "router1" exists
if ! openstack router show router1 &> /dev/null; then
  sleep 2
  echo "Router 'router1' not found. Creating now"
  openstack router create router1
  sleep 2
  ROUTER_ID=$(openstack router show router1 -f value -c id)
  sleep 2
  openstack router add subnet "$ROUTER_ID" "$SUBNET_ID"
  sleep 2
else
  echo "Router 'router1' already exists."
fi

echo "Test: get the lease ID"
LEASE_ID=$(openstack reservation lease list | grep "lease-test-comp-host-res" | awk '{print $2}')
sleep 2

echo "Test: get the reservation ID"
# Check if the lease ID was found
if [ -z "$LEASE_ID" ]; then
  echo "Error: Lease 'lease-test-comp-host-res' not found."
else
  RESERVATION_ID=$(openstack reservation lease show "$LEASE_ID" | grep -A 100 'reservations' | sed -n 's/.*"id": "\([^"]*\)".*/\1/p')
  sleep 2
  echo "Test: RESERVATION ID: $RESERVATION_ID"
fi

echo "Test: list servers"
openstack server list
sleep 2

if [ -n "$RESERVATION_ID" ]; then
  echo "Test: Create a server with the reservation hint"
  openstack server create \
    --flavor "$FLAVOR_ID" \
    --image "$IMAGE_ID" \
    --network "$NETWORK_ID" \
    --hint reservation="$RESERVATION_ID" \
    server_test_blazar_with_reservation
  sleep 60

  echo "Test: list servers after creating a server with reservation"
  openstack server list
  sleep 2
fi

echo "Test: delete the created servers"
# Get the list of servers and delete them
SERVER_LIST=$(openstack server list -f value -c id)
sleep 2

# Check if any servers were found
if [ -z "$SERVER_LIST" ]; then
  echo "No servers found"
else
  # Delete the servers
  for SERVER_ID in $SERVER_LIST; do
    echo "Deleting server: $SERVER_ID"
    openstack server delete "$SERVER_ID"
    sleep 5
  done
  echo "All servers on host '$host_id' have been deleted"
fi

echo "Test: list servers after deleting"
openstack server list
sleep 2

echo "Test: Starting the process to delete all Blazar leases"

lease_ids=$(openstack reservation lease list -c id -f value)
sleep 2

# Check if the list of leases is empty.
if [ -z "$lease_ids" ]; then
  echo "Test: No leases found to delete"
else
  echo "Test: The following lease IDs will be deleted:"
  echo "$lease_ids"
  echo "-------------------------------------"

  while IFS= read -r lease_id; do
    echo "Test: Deleting lease with ID: $lease_id"
    openstack reservation lease delete "$lease_id"
    sleep 2
    echo "Test: Lease $lease_id deleted."
  done <<< "$lease_ids"

  echo "-------------------------------------"
  echo "Test: All Blazar leases have been successfully deleted"
fi

echo "Test: Starting the process to delete all Blazar hosts"

host_ids=$(openstack reservation host list -c id -f value)
sleep 2

# Check if the list of hosts is empty.
if [ -z "$host_ids" ]; then
  echo "Test: No hosts found to delete"
else
  echo "Test: The following host IDs will be deleted:"
  echo "$host_ids"
  echo "-------------------------------------"

  while IFS= read -r host_id; do
    echo "Test: Deleting host with ID: $host_id"
    openstack reservation host delete "$host_id"
    sleep 2
    echo "Test: Host $host_id deleted"
  done <<< "$host_ids"

  echo "-------------------------------------"
  echo "Test: All Blazar hosts have been successfully deleted"
fi

exit 0
