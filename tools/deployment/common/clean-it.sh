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

set -eux
export OS_CLOUD=openstack_helm

clear
echo
echo "**************************************************************"
echo "Clean-Up script to remove OSH-AIO (Ceph) artifacts created"
echo "from execution of the 900-use-it.sh script"
echo "**************************************************************"
echo

# Check if 900-use-it.sh was run.  Verify existance of heat stacks and key-pairs.
echo "**************************************************************"
echo "Checking for heat stacks created from 900-use-it.sh:"
if [[ $(openstack stack list) ]]; then
        echo "HEAT STACKS PRESENT *** 900-use-it.sh was run"
else
        echo "HEAT STACKS 'NOT' PRESENT **"
        echo
        echo "Stopping the clean-up script as 900-use-it.sh does"
        echo "NOT appear to have been run, or pre-requisite heat"
        echo "stack info is not available."
        echo
        exit
fi
echo "**************************************************************"
echo
echo "**************************************************************"
echo "Checking for key-pair created from 900-use-it.sh:"
if [[ $(openstack keypair list) ]]; then
        echo "KEYPAIR PRESENT *** 900-use-it.sh was run"
else
        echo "KEYPAIR 'NOT' PRESENT **"
        echo
        echo "Stopping the clean-up script as 900-use-it.sh does"
        echo "NOT appear to have been run, or pre-requisite key-pair"
        echo "info is not available."
        echo
        exit
fi
echo "**************************************************************"
echo

# DELETE HEAT STACKS.
# CAPTURE FLOATING_IP FIRST.  USED LATER TO DELETE FROM KNOWN_HOSTS.
FLOATING_IP=$(sudo openstack --os-cloud openstack_helm stack output show heat-basic-vm-deployment floating_ip -f value -c output_value)
export FLOATING_IP
echo "**************************************************************"
echo "Deleting heat stacks:"
echo
declare -a osStackList=("heat-vm-volume-attach" "heat-basic-vm-deployment" "heat-subnet-pool-deployment" "heat-public-net-deployment")
for eachStack in "${osStackList[@]}"; do
    echo "Deleteing OSH-AIO stack= " $eachStack
    openstack stack delete -y --wait $eachStack
    echo
done
echo
echo "Heat stacks deleted."
echo "**************************************************************"

# DELETE KEY PAIR.
echo
echo "**************************************************************"
echo "Deleting key-pair:"
echo
declare -a osKeyPairList=("heat-vm-key")
for eachKey in "${osKeyPairList[@]}"; do
    echo "Deleteing OSH-AIO keypair= " $eachKey
    openstack keypair delete $eachKey
    echo
done
echo
echo "Key-pair deleted"
echo "**************************************************************"

# DELETE RESIDUAL KEY ARTIFACTS CREATED DURING 900-USE-IT.sh.
echo
echo "**************************************************************"
echo "Deleting files:"$HOME"/.ssh/known_hosts and osh_key"
echo "Checking for known_hosts file in the $HOME/.ssh/ directory."
if [[ $(ls -A $HOME/.ssh/known_hosts) ]]; then
    sudo sed -i /$FLOATING_IP/d $HOME/.ssh/known_hosts
    echo "FLOATING_IP deleted from $HOME/.ssh/known_hosts."
else
    echo "No known_hosts file found."
fi
echo
echo "Checking for osh_key file in the $HOME/.ssh/ directory"
if [[ $(ls -A $HOME/.ssh/osh_key) ]]; then
    rm $HOME/.ssh/osh_key
    echo "$HOME/.ssh/osh_key file removed."
else
    echo "No osh_key file found."
fi
echo "KEY FILES DELETED SUCCESSFULLY, WHERE AVAILABLE."
echo "**************************************************************"

# FINAL VERIFICATION.  CONFIRM HEAT STACK AND KEY-PAIR DATA HAS BEEN REMOVED.
echo
echo "**************************************************************"
echo "Final verification to confirm Heat Stack and Key Pair"
echo "artrifacts have been removed."
echo
echo "Checking for Heat Stack Data:"
echo "Please wait."
sleep 10
if [[ $(openstack stack list) ]]; then
        echo "HEAT STACKS STILL PRESENT *** STOPPING SCRIPT.  Verify manually please."
        exit
else
        echo "HEAT STACK DATA REMOVED SUCCESSFULLY."
fi

echo
echo "Checking for Key-Pair Data:"
if [[ $(openstack keypair list) ]]; then
        echo "KEYPAIR STILL PRESENT ** STOPPING SCRIPT. Verify manually please."
        exit
else
        echo "KEYPAIR DATA REMOVED SUCCESSFULLY."
fi
echo "**************************************************************"
echo
echo "Clean-up Completed Successfully!"
echo