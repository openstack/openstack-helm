==============
Openstack-Helm
==============

Openstack-Helm is a fully self-contained Helm-based OpenStack deployment on
Kubernetes. It will provide baremetal provisioning, persistent storage,
full-stack resiliency, full-stack scalability, performance monitoring and
tracing, and an optional development pipeline (using Jenkins). This project,
along with the tools used within are community-based and open sourced.

Mission
-------

The goal for Openstack-Helm is to provide an incredibly customizable
*framework* for operators and developers alike. This framework will enable
end-users to deploy, maintain, and upgrade a fully functioning Openstack
environment for both simple and complex environments. Administrators or
developers can either deploy all or individual Openstack components along with
their required dependancies. It heavily borrows concepts from
`Stackanetes <https://github.com/stackanetes/stackanetes>`_ and `other complex
Helm application deployments <https://github.com/sapcc/openstack-helm>`_. This
project is meant to be a collaborative project that brings Openstack
applications into a `Cloud-Native <https://www.cncf.io/about/charter>`_ model.

Communication
-------------

* Join us on `Slack <https://kubernetes.slack.com/messages/C3WERB7DE/>`_ - #openstack-helm
* Join us on `IRC <irc://chat.freenode.net:6697/openstack-helm>`_:
  #openstack-helm on freenode
* Community IRC Meetings: [Every Tuesday @ 3PM UTC],
  #openstack-meeting-5 on freenode
* Meeting Agenda Items: `Agenda
  <https://etherpad.openstack.org/p/openstack-helm-meeting-agenda>`_
* Community Roadmap Items: `Roadmap Docs
  <https://docs.google.com/spreadsheets/d/1N5AdAdLbvpZ9Tzi1TuqeJbHyczfZRysBIYE_ndnZx6c/edit?usp=sharing>`_

Open Releases
-------------

Until a 1.0.0 release, this collection is a work in progress and components
will continue to be added or modified over time. Please review our
`Milestones <https://launchpad.net/openstack-helm>`_, and `Releases
<https://github.com/openstack/openstack-helm/releases>`_ for more information.

Installation and Development
----------------------------

This project is under heavy development. We encourage anyone who is interested
in Openstack-Helm to review our `Installation <http://openstack-helm.readthedocs.io/en/latest/install/index.html>`_
documentation, complete with verification procedures. Feel free to ask
questions or check out our current `Issues and Bugs
<https://bugs.launchpad.net/openstack-helm>`_.

Please review our documentation at `Read the Docs <http://openstack-helm.readthedocs.io/>`_.
For quick installation, evaluation, and convenience, you can use our
online Helm repository and configure your environment with `Kubeadm-AIO
<http://openstack-helm.readthedocs.io/en/latest/install/all-in-one.html>`_.

For a production-like install, follow the
`Bare Metal <http://openstack-helm.readthedocs.io/en/latest/install/multinode.html>`_
install guide.
