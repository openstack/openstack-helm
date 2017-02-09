# Openstack-Helm Documentation


## Table of Contents

## &nbsp;1. Openstack-Helm Design Principles
### &nbsp;&nbsp;&nbsp;1.1 [Mission](mission.md)
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.1.1 [Resiliency](mission.md#resiliency)
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.1.2 [Scaling](mission.md#scaling)
### &nbsp;&nbsp;&nbsp;1.2 Helm Overrides
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.2.1 [Values Philosophy](helm_overrides.md#values)
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.2.1 [Replicas](helm_overrides.md#replicas)
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.2.1 [Labels](helm_overrides.md#labels)
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.2.1 [Images](helm_overrides.md#images)
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.2.1 [Upgrades](helm_overrides.md#upgrades)
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.2.1 [Resource Limits](helm_overrides.md#resource limits)
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.2.2 [Endpoints](#helm_overrides.md#endpoints)
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.2.2 [Common Conditionals](helm_overrides.md#common conditionals)
### &nbsp;&nbsp;&nbsp;1.3 Init-Containers
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.3.1 Dependency Checking
### &nbsp;&nbsp;&nbsp;1.4 Kubernetes Jobs
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.4.1 Service Registration
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.4.2 User Registration
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.4.3 Database Creation
##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.4.4 Database Migration
### &nbsp;&nbsp;&nbsp;1.5 Complimentary Efforts
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.5.1 Image-Based Project Considerations
### &nbsp;&nbsp;&nbsp;1.6 Kubernetes State
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.6.1 Third Party Resources
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.6.2 Add-Ons
## &nbsp;2. Repository Structure
### &nbsp;&nbsp;&nbsp;2.1 Infrastructure Components
### &nbsp;&nbsp;&nbsp;2.2 Openstack-Helm Core Services
### &nbsp;&nbsp;&nbsp;2.3 Openstack-Helm Add-Ons
## &nbsp;3. Operator Resources
### &nbsp;&nbsp;&nbsp;&nbsp;3.1 [Installation](https://github.com/att-comdev/openstack-helm/blob/master/docs/installation/getting-started.md)
### &nbsp;&nbsp;&nbsp;&nbsp;3.2 Openstack-Helm Chart Definition Overrides
### &nbsp;&nbsp;&nbsp;&nbsp;3.2 Openstacak-Helm Upgrades
## &nbsp;4. Openstack-Helm Networking
### &nbsp;&nbsp;&nbsp;4.1 Kubernetes Control Plane
#### &nbsp;&nbsp;&nbsp;&nbsp;4.1.1 CNI SDN Considerations
#### &nbsp;&nbsp;&nbsp;&nbsp;4.1.2 Calico Networking
### &nbsp;&nbsp;&nbsp;4.2 Ingress Philosophy
### &nbsp;&nbsp;&nbsp;4.3 Openstack Networking
#### &nbsp;&nbsp;&nbsp;&nbsp;4.3.1 Flat Networking
#### &nbsp;&nbsp;&nbsp;&nbsp;4.3.1 L2 Networking
## &nbsp;5. Security Guidelines
### &nbsp;&nbsp;&nbsp;5.1 Network Policies
### &nbsp;&nbsp;&nbsp;5.2 Advanced Network Policies
### &nbsp;&nbsp;&nbsp;5.3 Role-Based Access Controls
### &nbsp;&nbsp;&nbsp;5.4 Security Contexts
### &nbsp;&nbsp;&nbsp;5.5 Security Add-Ons
## &nbsp;6. Developer Resources
### &nbsp;&nbsp;&nbsp;6.1 Contributions and Guidelines
### &nbsp;&nbsp;&nbsp;6.2 Development Tools
#### &nbsp;&nbsp;&nbsp;&nbsp;6.2.1 [Minikube Development](https://github.com/att-comdev/openstack-helm/blob/master/docs/developer/minikube.md)
### &nbsp;&nbsp;&nbsp;6.3 Tips and Considerations
