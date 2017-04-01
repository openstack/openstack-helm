# Openstack-Helm

Welcome to the Openstack-Helm project!

## Mission Statement

Openstack-Helm is a project that provides a flexible, production-grade  Kubernetes deployment of Openstack Services using Kubernetes/Helm deployment primitives. The charts contained within the Openstack-Helm project are designed to be a plenary framework of self-contained, service-level manifest templates for development, operations, and troubleshooting, leveraging upstream Kubernetes and Helm best practices with third-party add-ons treated as a last resort.

## Table of Contents

The documentation provided for Openstack-Helm are provided in the following role-specific guides:

- [Welcome Guide](guides_welcome/readme.md)
  - [Mission](guides_welcome/mission.md) - Openstack-Helm Mission Statement
  - [Project Overview](guides_welcome/welcome-overview.md)
  - [Resiliency Philosophy](guides_welcome/welcome-resiliency.md)
  - [Scalability Philosophy](guides_welcome/welcome-scaling.md)
- [Installation Guides](guides-install/readme.md) -
  - [All-in-One](guides-install/install-aio.md) - Evaluation of Openstack-Helm
  - [Developer Installation](guides-install/install-minikube.md) - Envirnment for Openstack-Helm Development
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
  - [Helm Development Handbook](guides-developer/install-minikube.md) - Hands-On Development Guide
    - [Helm-Toolkit Overview](guides-developer/) - Overview of Helm-Toolkit
    - [User Registration](guides-developer/guides-devs-helm/registration-user.md)
    - [Domain Registration](guides-developer/guides-devs-helm/registration-domain.md)
    - [Host Registration](guides-developer/guides-devs-helm/registration-host.md)
    - [Service Registration](guides-developer/guides-devs-helm/registration-service.md)
  - [Kubernetes Development Handbook](guides-developer/install-multinode.md) -
- [Operator Guides](guides-operator/readme.md) - Resources for Openstack-Helm Developers
  - [Helm Operations](guides-operator/getting-started/readme.md) - Helm Operator Guides
    - [Addons and Plugins](guides-operator/getting-started/helm-addons.md)
  - [Kubernetes Operations](guides-operator/readme.md)
    - [Init Containers](guides-operator/readme.md)
    - [Jobs](guides-operator/readme.md)
  - [Openstack Operations](guides-operator/readme.md)
    - [Config Generation](guides-operator/readme.md) - Openstack-Helm Configuration Management
  - [Networking Guides](guides-operator/readme.md) - Network Operations
    - [Ingress](guides-operator/readme.md)
    - [Nodeports](guides-operator/readme.md)
  - [Security Guides](guides-operator/readme.md) - Security Operations
    - [Namespace Isolation](guides-operator/readme.md)
    - [SELinux and SECCOMP](guides-operator/readme.md)
    - [Role-Based Access Control](guides-operator/readme.md)
- [Troubleshooting Guides](charts.md)
- [Appendix A: Helm Resources](charts.md) - Curated List of Helm Resources
- [Appendix B: Kubernetes Resources](charts.md) - Curated List of Kubernetes Resources
