Backing up a PVC
^^^^^^^^^^^^^^^^

Backing up a PVC stored in Ceph, is fairly straigthforward, in this example we
use the PVC ``mysql-data-mariadb-server-0`` as an example, but this will also
apply to any other services using PVCs eg. RabbitMQ, Postgres.


.. code-block:: shell

    #  get all required details
    NS_NAME="openstack"
    PVC_NAME="mysql-data-mariadb-server-0"
    # you can check this by running  kubectl get pvc -n ${NS_NAME}

    PV_NAME="$(kubectl get -n ${NS_NAME} pvc "${PVC_NAME}" --no-headers | awk '{ print $3 }')"
    RBD_NAME="$(kubectl get pv "${PV_NAME}" -o json | jq -r '.spec.rbd.image')"
    MON_POD=$(kubectl get pods \
      --namespace=ceph \
      --selector="application=ceph" \
      --selector="component=mon" \
      --no-headers | awk '{ print $1; exit }')

    # copy admin keyring from ceph mon to host node

    kubectl exec -it ${MON_POD} -n ceph -- cat /etc/ceph/ceph.client.admin.keyring > /etc/ceph/ceph.client.admin.keyring
    sudo kubectl get cm -n ceph ceph-etc -o json|jq -j  .data[] > /etc/ceph/ceph.conf

    export CEPH_MON_NAME="ceph-mon-discovery.ceph.svc.cluster.local"

    # create snapshot and export to a file

    rbd snap create rbd/${RBD_NAME}@snap1 -m ${CEPH_MON_NAME}
    rbd snap list rbd/${RBD_NAME} -m ${CEPH_MON_NAME}

    # Export the snapshot and compress, make sure we have enough space on host to accommodate big files that we are working .

    # a. if we have enough space on host

    rbd export rbd/${RBD_NAME}@snap1 /backup/${RBD_NAME}.img -m ${CEPH_MON_NAME}
    cd /backup
    time xz -0vk --threads=0  /backup/${RBD_NAME}.img

    # b. if we have less space on host we can directly export  and compress in single command

    rbd export rbd/${RBD_NAME}@snap1 -m ${CEPH_MON_NAME} - | xz  -0v --threads=0 >  /backup/${RBD_NAME}.img.xz


Restoring is just as straightforward. Once the workload consuming the device has
been stopped, and the raw RBD device removed the following will import the
back up and create a device:

.. code-block:: shell

    cd /backup
    unxz -k ${RBD_NAME}.img.xz
    rbd import /backup/${RBD_NAME}.img rbd/${RBD_NAME} -m ${CEPH_MON_NAME}

Once this has been done the workload can be restarted.
