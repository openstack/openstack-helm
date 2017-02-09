[![Travis CI](https://travis-ci.org/att-comdev/openstack-helm.svg?branch=master)](https://travis-ci.org/att-comdev/openstack-helm)

# Openstack-Helm

**Join us on [Slack](http://slack.k8s.io/):** `#openstack-helm`<br>
**Join us on [Freenode](https://freenode.net/):** `#openstack-helm`<br>
**Community Meetings:** [Every other Tuesday @ 3PM UTC](https://calendar.google.com/calendar/embed?src=rnd4tpeoncig91pvs05il4p29o%40group.calendar.google.com&ctz=America/New_York) (Provided by [Zoom](https://zoom.us/j/562328746))<br>
**Community Agenda Items:** [Google Docs](https://docs.google.com/document/d/1Vm2OnMzjSru3cuvxh4Oa7R_z7staU-7ivGy8foOzDCs/edit#heading=h.bfc0dkav9gk2)

Openstack-Helm is a fully self-contained Helm-based OpenStack deployment on Kubernetes. It will provide baremetal provisioning, persistent storage, full-stack resiliency, full-stack scalability, performance monitoring and tracing, and an optional development pipeline (using Jenkins). This project, along with the tools used within are community-based and open sourced.

# Mission

The goal for Openstack-Helm is to provide an incredibly customizable *framework* for operators and developers alike. This framework will enable end-users to deploy, maintain, and upgrade a fully functioning Openstack environment for both simple and complex environments. Administrators or developers can either deploy all or individual Openstack components along with their required dependancies. It heavily borrows concepts from [Stackanetes](https://github.com/stackanetes/stackanetes) and [other complex Helm application deployments](https://github.com/sapcc/openstack-helm). This project is meant to be a collaborative project that brings Openstack applications into a [Cloud-Native](https://www.cncf.io/about/charter) model.

# Open Releases

Until a 1.0.0 release, this collection is a work in progress and components will continue to be added or modified over time. Please review our [Milestones](https://github.com/att-comdev/openstack-helm/milestones), [Releases](https://github.com/att-comdev/openstack-helm/releases), and [Project](https://github.com/att-comdev/openstack-helm/projects/1) timelines.

# Installation and Development

This project is under heavy development. We encourage anyone who is interested in Openstack-Helm to review our [Getting Started](https://github.com/att-comdev/openstack-helm/blob/master/docs/installation/getting-started.md) documentation, complete with verification procedures. Feel free to ask questions or check out our current [Issues](https://github.com/att-comdev/openstack-helm/issues), [Project Plan](https://github.com/att-comdev/openstack-helm/projects/1) or submit a [Pull Request](https://github.com/att-comdev/openstack-helm/pulls).

Openstack-Helm is intended to be packaged and served from your own Helm [repository](https://github.com/kubernetes/helm/blob/master/docs/chart_repository.md). However, for quick installation, evaluation, and convenience, you can use our online Helm repository. After you've configured your environment for [Minikube](https://github.com/att-comdev/openstack-helm/blob/master/docs/developer/minikube.md) (for hostPath) or [Bare Metal](https://github.com/att-comdev/openstack-helm/blob/master/docs/installation/getting-started.md) (for PVC support), you can add our most recent repository by using the following command:

```
$ helm repo add openstack-helm https://att-comdev.github.io/openstack-helm/charts/
```

To verify your Helm chart version, once the repository has been added, issue the following:

```
$ helm search | grep openstack-helm
local/bootstrap         	0.1.0  	openstack-helm namespace bootstrap
openstack-helm/bootstrap	0.1.0  	openstack-helm namespace bootstrap
openstack-helm/ceph     	0.1.0  	A Helm chart for Kubernetes
openstack-helm/common   	0.1.0  	A base chart for all openstack charts
openstack-helm/glance   	0.1.0  	A Helm chart for glance
openstack-helm/horizon  	0.1.0  	A Helm chart for horizon
openstack-helm/keystone 	0.1.0  	A Helm chart for keystone
openstack-helm/mariadb  	0.1.0  	A helm chart for mariadb
openstack-helm/memcached	0.1.0  	Chart for memcached
openstack-helm/openstack	0.1.0  	A Helm chart for Kubernetes
openstack-helm/rabbitmq 	0.1.0  	A Helm chart for Kubernetes
$
```

**UPDATED:** Please see our new [developer documentation](https://github.com/att-comdev/openstack-helm/blob/master/docs/developer/minikube.md) for Minikube.

# Additional Details

For additional details, and instructions on how to use this project, please see the [wiki](https://github.com/att-comdev/openstack-helm/wiki) for more details.
