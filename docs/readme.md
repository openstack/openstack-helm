# Openstack-Helm

Welcome to the Openstack-Helm project!

## Mission Statement

Openstack-Helm is a project that provides a flexible, production-grade  Kubernetes deployment of Openstack Services using Kubernetes/Helm deployment primitives. The charts contained within the Openstack-Helm project are designed to be a plenary framework of self-contained, service-level manifest templates for development, operations, and troubleshooting, leveraging upstream Kubernetes and Helm best practices with third-party add-ons treated as a last resort.

## Table of Contents

The documentation provided for Openstack-Helm are provided in the following role-specific guides:

- [Welcome Guide](guides-welcome/readme.md)
  - [Mission](#mission-statement) - Openstack-Helm Mission Statement
  - [Project Overview](guides-welcome/welcome-overview.md)
  - [Resiliency Philosophy](guides-welcome/welcome-resiliency.md)
  - [Scalability Philosophy](guides-welcome/welcome-scaling.md)
- [Installation Guides](guides-install/readme.md) - Various Installation Options
  - [Developer Installation](guides-install/developer/readme.md) - Environment for Openstack-Helm Development
    - [Minikube](guides-install/developer/install-minikube.md)
    - [Vagrant](guides-install/developer/install-vagrant.md)
  - [All-in-One](guides-install/install-aio.md) - Evaluation of Openstack-Helm
  - [Multinode](guides-install/install-multinode.md) - Multinode or Production Deployments
- [Developer Guides](guides-developer/readme.md) - Resources for Openstack-Helm Developers
  - [Getting Started](guides-developer/getting-started/readme.md) - Development Philosophies
    - [Default Values](guides-developer/getting-started/gs-values.md)
    - [Chart Overrides](guides-developer/getting-started/gs-overrides.md)
    - [Replica Guidelines](guides-developer/getting-started/gs-replicas.md)
    - [Image Guidelines](guides-developer/getting-started/gs-images.md)
    - [Resource Guidelines](guides-developer/getting-started/gs-resources.md)
    - [Labeling Guidelines](guides-developer/getting-started/gs-labels.md)
    - [Endpoint Considerations](guides-developer/getting-started/gs-endpoints.md)
    - [Helm Upgrades Considerations](guides-developer/getting-started/gs-upgrades.md)
    - [Using Conditionals](guides-developer/getting-started/gs-conditionals.md)
  - [Helm Development Handbook](guides-developer/readme.md) - Hands-On Development Guide
    - [Getting Started](guides-developer/getting-started/readme.md) - Development Philosophies
      - [Default Values](guides-developer/getting-started/gs-values.md)
      - [Chart Overrides](guides-developer/getting-started/gs-overrides.md)
      - [Replica Guidelines](guides-developer/getting-started/gs-replicas.md)
      - [Image Guidelines](guides-developer/getting-started/gs-images.md)
      - [Resource Guidelines](guides-developer/getting-started/gs-resources.md)
      - [Labeling Guidelines](guides-developer/getting-started/gs-labels.md)
      - [Endpoint Considerations](guides-developer/getting-started/gs-endpoints.md)
      - [Helm Upgrades Considerations](guides-developer/getting-started/gs-upgrades.md)
      - [Using Conditionals](guides-developer/getting-started/gs-conditionals.md)
    - [Helm-Toolkit Overview](guides-developer/dev-helm/helm-toolkit.md) - Overview of Helm-Toolkit
    - [User Registration](guides-developer/dev-helm/registration-user.md)
    - [Domain Registration](guides-developer/dev-helm/registration-domain.md)
    - [Host Registration](guides-developer/dev-helm/registration-host.md)
    - [Endpoint Registration](guides-developer/dev-helm/registration-endpoint.md)
    - [Service Registration](guides-developer/dev-helm/registration-service.md)
  - [Kubernetes Development Handbook](guides-developer/dev-kubernetes/readme.md)
    - [Kubernetes Development Considerations](guides-developer/dev-kubernetes/considerations.md)
- [Operator Guides](guides-operator/readme.md) - Resources for Openstack-Helm Developers
  - [Helm Operations](guides-operator/ops-helm/readme.md) - Helm Operator Guides
    - [Openstack-Helm Operations](guides-operator/ops-helm/osh-operations.md)
    - [Addons and Plugins](guides-operator/ops-helm/osh-addons.md)
  - [Kubernetes Operations](guides-operator/ops-kubernetes/readme.md)
    - [Init-Containers](guides-operator/ops-kubernetes/kb-init-containers.md)
    - [Jobs](guides-operator/ops-kubernetes/kb-jobs.md)
  - [Openstack Operations](guides-operator/readme.md)
    - [Config Generation](guides-operator/ops-openstack/os-config/os-config-gen.md) - Openstack-Helm Configuration Management
  - [Networking Guides](guides-operator/ops-network/readme.md) - Network Operations
    - [Ingress](guides-operator/ops-network/net-ingress.md)
    - [Nodeports](guides-operator/ops-network/net-nodeport.md)
  - [Security Guides](guides-operator/readme.md) - Security Operations
    - [Using Namespaces](guides-operator/ops-security/sec-namespaces.md)
    - [SELinux and SECCOMP](guides-operator/ops-security/sec-appsec.md)
    - [Role-Based Access Control](guides-operator/ops-security/sec-rbac.md)
- [Troubleshooting Guides](guides-operator/troubleshooting/readme.md)
  - [Database Issues](guides-operator/troubleshooting/ts-database.md)
  - [Development Issues](troubleshooting/ts-development.md)
  - [Networking Issues](guides-operator/troubleshooting/ts-networking.md)
  - [Storage Issues](guides-operator/troubleshooting/ts-persistent-storage.md)
- [Appendix A: Helm Resources](appendix/resources-helm.md) - Curated List of Helm Resources
- [Appendix B: Kubernetes Resources](appendix/resources-kubernetes.md) - Curated List of Kubernetes Resources
