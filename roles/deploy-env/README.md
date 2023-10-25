This role is used to deploy test environment which includes
- install necessary prerequisites including Helm
- deploy Containerd and a container runtime for Kubernetes
- deploy Kubernetes using Kubeadm with a single control plain node
- install Calico as a Kubernetes networking

The role works both for singlenode and multinode inventories and
assumes the inventory has the node called `primary` and the group called `nodes`.

See for example:

```yaml
all:
  children:
    ungrouped:
      hosts:
        primary:
          ansible_port: 22
          ansible_host: 10.10.10.10
          ansible_user: ubuntu
          ansible_ssh_private_key_file: /home/ubuntu/.ssh/id_rsa
          ansible_ssh_extra_args: -o StrictHostKeyChecking=no
    nodes:
      hosts:
        node-1:
          ansible_port: 22
          ansible_host: 10.10.10.11
          ansible_user: ubuntu
          ansible_ssh_private_key_file: /home/ubuntu/.ssh/id_rsa
          ansible_ssh_extra_args: -o StrictHostKeyChecking=no
        node-2:
          ansible_port: 22
          ansible_host: 10.10.10.12
          ansible_user: ubuntu
          ansible_ssh_private_key_file: /home/ubuntu/.ssh/id_rsa
          ansible_ssh_extra_args: -o StrictHostKeyChecking=no
```
