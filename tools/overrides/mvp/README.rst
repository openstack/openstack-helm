============================
OpenStack-Helm MVP Overrides
============================

The project specific overrides in this directory allow you to reduce the default
resilience of OpenStack-Helm, by turning off HA of the Neutron Agents.
Additionally the default distributed storage backend, Ceph, is disabled and
replaced by local storage for OpenStack components.

These changed are made to achieve these goals:
 * Demonstrating how values can be set and defined within OpenStack-Helm
 * Allowing OpenStack-Helm to run on a single node for:
  * Development
  * Demonstration
  * Basic integration pipelines in a CI System
