# Mission

The goal for openstack-helm is to provide an incredibly customizable *framework* for operators and developers alike. This framework will enable end-users to deploy, maintain, and upgrade a fully functioning Openstack environment for both simple and complex environments. Administrators or developers can either deploy all or individual Openstack components along with their required dependancies. It heavily borrows concepts from [Stackanetes](https://github.com/stackanetes/stackanetes) and [other complex Helm application deployments](https://github.com/sapcc/openstack-helm). This project is meant to be a collaborative project that brings Openstack applications into a [Cloud-Native](https://www.cncf.io/about/charter) model.

## Resiliency

One of the goals of this project is to produce a set of charts that can be used in a production setting to deploy and upgrade OpenStack.  To meet achieve this goal, all components must be resilient.  This includes both OpenStack and Infrastructure components leveraged by this project.  In addition, this also includes Kubernetes itself.  It is part of our mission to ensure that all infrastructure components are highly available and that a deployment can withstand a physical host failure out of the box. This means that:

- OpenStack components will need to support, and deploy with multiple replicas out of the box (unless development mode is enabled) to make sure this leveraging this chart for production deployments is a first class citizen at all times.
- Infrastructure elements such as Ceph, RabbitMQ, Galera (MariaDB), Memcache, and all others need to support resiliency and leverage multiple replicas for resiliency where applicable.  These components also need to be validated that their application level configurations (for instance the underlying galera cluster) can tolerate host crashes and withstand physical host failures.
- Scheduling annotations need to be employed to ensure maximum resiliency for multi-host environments.  They also need to be flexible to allow all-in-one deployments.  To this end, we promote the usage of `podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for most infrastructure elements.
- We make the assumption that we can depend on a reliable implementation of centralized storage to create PVCs within Kubernetes to support resiliency and complex application design.  Today, this is powered by our own cheph chart as there is much work to do making even a single backend production ready and we need to focus bringing that to a production ready state, which includes handling real world deployment scenarios, resiliency, and pool configuration.  In the future, we would like to support more choice for hardened backends.
- We will document the best practices for running a resilient Kubernetes cluster in production.  This includes the steps necessary to make all components resilient, such as etcd, and skydns where possible, and point out gaps due to missing features.

## Scaling

Scaling is another first class citizen in openstack-helm.  We will be working to ensure we support various deployment models that can support hyperscale, such as:

- Ensuring that out of the box, unless development mode is enabled, clusters receive multiple replicas to ensure scaling issues are identified early and often.
- Ensuring that every chart can support more then one replica and allowing operators to override those replica counts.  For some applications, means ensuring they can support clustering.
- Ensuring clustering style applications are not limited to fixed replica counts.  For instance, we want to ensure we can support N galera members and have those scale linearly within reason as opposed to only supporting a fixed count.
- Duplicate charts of the same type within the same namespace.  For example, deploying rabbitmq twice, to the openstack namespace resulting in two fully functioning clusters.
- Allowing charts to be deployed to a diverse set of namespaces.  Allowing infrastructure to be deployed in one namespace, and OpenStack in another, for example or each chart in its own namespace.
- Supporting hyperscale by ensuring we can support configurations that call for per-component infrastructure, such as dedicated database and rabbitmq solely for ceilometer or even dedicated infrastructure for every component you deploy.  It is unique large scale deployment designs such as this that only become practical under a Kubernetes/Container framework and we want to ensure that we can support them.