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
set -e
if [[ "$2" -gt 0 ]];then
    seconds=$2
else
    seconds=900
fi

end=$(date +%s)
timeout=${2:-$seconds}
end=$((end + timeout))
while true; do
    kubectl get pods --namespace=$1 -o json | jq -r \
        '.items[].status.phase' | grep Pending > /dev/null && \
        PENDING="True" || PENDING="False"
    query='.items[]|select(.status.phase=="Running")'
    query="$query|.status.containerStatuses[].ready"
    kubectl get pods --namespace=$1 -o json | jq -r "$query" | \
        grep false > /dev/null && READY="False" || READY="True"
    kubectl get jobs --namespace=$1 -o json | jq -r \
        '.items[] | .spec.completions == .status.succeeded' | \
        grep false > /dev/null && JOBR="False" || JOBR="True"
    [ $PENDING == "False" -a $READY == "True" -a $JOBR == "True" ] && \
        break || true
    sleep 5
    now=$(date +%s)
    if [ $now -gt $end ] ; then
        echo "Containers failed to start after $timeout seconds"
        echo
        kubectl get pods --namespace $1 -o wide
        echo
        if [ $PENDING == "True" ] ; then
            echo "Some pods are in pending state:"
            kubectl get pods --field-selector=status.phase=Pending -n $1 -o wide
        fi
        [ $READY == "False" ] && echo "Some pods are not ready"
        [ $JOBR == "False" ] && echo "Some jobs have not succeeded"
        exit -1
    fi
done
