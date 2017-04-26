# Openstack-Helm

**Join us on [Slack](http://slack.k8s.io/):** `#openstack-helm`<br>
**Join us on [Freenode](https://freenode.net/):** `#openstack-helm`<br>
**Community Meetings:** Every other Tuesday @ 3PM UTC in the `#openstack-helm` channel<br>
**Community Agenda Items:** [Google Docs](https://docs.google.com/document/d/1Vm2OnMzjSru3cuvxh4Oa7R_z7staU-7ivGy8foOzDCs/edit#heading=h.bfc0dkav9gk2)<br>
**Community Roadmap Items:** [Roadmap Docs](https://docs.google.com/spreadsheets/d/1N5AdAdLbvpZ9Tzi1TuqeJbHyczfZRysBIYE_ndnZx6c/edit?usp=sharing)

Openstack-Helm is a fully self-contained Helm-based OpenStack deployment on Kubernetes. It will provide baremetal provisioning, persistent storage, full-stack resiliency, full-stack scalability, performance monitoring and tracing, and an optional development pipeline (using Jenkins). This project, along with the tools used within are community-based and open sourced.

# Mission

The goal for Openstack-Helm is to provide an incredibly customizable *framework* for operators and developers alike. This framework will enable end-users to deploy, maintain, and upgrade a fully functioning Openstack environment for both simple and complex environments. Administrators or developers can either deploy all or individual Openstack components along with their required dependancies. It heavily borrows concepts from [Stackanetes](https://github.com/stackanetes/stackanetes) and [other complex Helm application deployments](https://github.com/sapcc/openstack-helm). This project is meant to be a collaborative project that brings Openstack applications into a [Cloud-Native](https://www.cncf.io/about/charter) model.

# Open Releases

Until a 1.0.0 release, this collection is a work in progress and components will continue to be added or modified over time. Please review our [Milestones](https://launchpad.net/openstack-helm), and  [Releases](https://github.com/openstack/openstack-helm/releases) for more information.

# Installation and Development

This project is under heavy development. We encourage anyone who is interested in Openstack-Helm to review our [Installation](https://github.com/openstack/openstack-helm/blob/master/docs/guides-install/readme.md) documentation, complete with verification procedures. Feel free to ask questions or check out our current [Issues and Bugs](https://bugs.launchpad.net/openstack-helm).

Openstack-Helm is intended to be packaged and served from your own Helm [repository](https://github.com/kubernetes/helm/blob/master/docs/chart_repository.md). However, for quick installation, evaluation, and convenience, you can use our online Helm repository. After you've configured your environment for [Minikube](https://github.com/openstack/openstack-helm/blob/master/docs/guides-install/developer/install-minikube.md#openstack-helm-minikube-deployment) (for hostPath) or [Bare Metal](https://github.com/openstack/openstack-helm/blob/master/docs/guides-install/install-multinode.md#overview).
