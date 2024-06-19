This role is used to deploy test environment which includes
- install necessary prerequisites including Helm
- deploy Containerd and a container runtime for Kubernetes
- deploy Kubernetes using Kubeadm with a single control plane node
- install Calico as a Kubernetes networking
- establish tunnel between primary node and K8s control plane ndoe

The role works both for single-node and multi-node inventories. The role
totally relies on inventory groups. The `primary` and `k8s_control_plane`
groups must include only one node and this can be the same node for these two
groups.

The `primary` group is where we install `kubectl` and `helm` CLI tools.
You can consider this group as a deployer's machine.

The `k8s_control_plane` is where we deploy the K8s control plane.

The `k8s_cluster` group must include all the K8s nodes including control plane
and worker nodes.

In case of running tests on a single-node environment the group `k8s_nodes`
must be empty. This means the K8s cluster will consist of a single control plane
node where all the workloads will be running.

See for example:

```yaml
all:
  vars:
    ansible_port: 22
    ansible_user: ubuntu
    ansible_ssh_private_key_file: /home/ubuntu/.ssh/id_rsa
    ansible_ssh_extra_args: -o StrictHostKeyChecking=no
  hosts:
    primary:
      ansible_host: 10.10.10.10
    node-1:
      ansible_host: 10.10.10.11
    node-2:
      ansible_host: 10.10.10.12
    node-3:
      ansible_host: 10.10.10.13
  children:
    primary:
      hosts:
        primary:
    k8s_cluster:
      hosts:
        node-1:
        node-2:
        node-3:
    k8s_control_plane:
      hosts:
        node-1:
    k8s_nodes:
      hosts:
        node-2:
        node-3:
```
