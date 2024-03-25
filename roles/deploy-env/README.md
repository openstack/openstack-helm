This role is used to deploy test environment which includes
- install necessary prerequisites including Helm
- deploy Containerd and a container runtime for Kubernetes
- deploy Kubernetes using Kubeadm with a single control plane node
- install Calico as a Kubernetes networking
- establish tunnel between primary node and K8s control plane ndoe

The role works both for singlenode and multinode inventories and
assumes the inventory has the node called `primary` and the group called `nodes`.

See for example:

```yaml
all:
  vars:
    ansible_port: 22
    ansible_user: ubuntu
    ansible_ssh_private_key_file: /home/ubuntu/.ssh/id_rsa
    ansible_ssh_extra_args: -o StrictHostKeyChecking=no
  children:
    primary:
      hosts:
        primary:
          ansible_host: 10.10.10.10
    k8s_cluster:
      hosts:
        node-1:
          ansible_host: 10.10.10.11
        node-2:
          ansible_host: 10.10.10.12
        node-3:
          ansible_host: 10.10.10.13
    k8s_control-plane:
      hosts:
        node-1:
          ansible_host: 10.10.10.11
    k8s_nodes:
      hosts:
        node-2:
          ansible_host: 10.10.10.12
        node-3:
          ansible_host: 10.10.10.13
```
