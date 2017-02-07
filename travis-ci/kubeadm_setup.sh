#!/bin/bash

docker run -it -e quay.io/attcomdev/kubeadm-ci:v1.1.0 --name kubeadm-ci --privileged=true -d --net=host --security-opt seccomp:unconfined --cap-add=SYS_ADMIN -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/run/docker.sock:/var/run/docker.sock quay.io/attcomdev/kubeadm-ci:v1.1.0 /sbin/init

docker exec kubeadm-ci kubeadm.sh
