Pod Disruption Budgets
----------------------

OpenStack-Helm leverages PodDisruptionBudgets to enforce quotas
that ensure that a certain number of replicas of a pod are available
at any given time.  This is particularly important in the case when a Kubernetes
node needs to be drained.


These quotas are configurable by modifying the ``minAvailable`` field
within each PodDisruptionBudget manifest, which is conveniently mapped
to a templated variable inside the ``values.yaml`` file.
The ``min_available`` within each service's ``values.yaml`` file can be
represented by either a whole number, such as ``1``, or a percentage,
such as ``80%``.  For example, when deploying 5 replicas of a pod (such as
keystone-api), using ``min_available: 3`` would enforce policy to ensure at
least 3 replicas were running, whereas using ``min_available: 80%`` would ensure
that 4 replicas of that pod are running.

**Note:** The values defined in a PodDisruptionBudget may
conflict with other values that have been provided if an operator chooses to
leverage Rolling Updates for deployments.  In the case where an
operator defines a ``maxUnavailable`` and ``maxSurge`` within an update strategy
that is higher than a ``minAvailable`` within a pod disruption budget,
a scenario may occur where pods fail to be evicted from a deployment.
