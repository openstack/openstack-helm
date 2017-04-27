## Welcome: Scaling Philosophy

Scaling is another first class citizen in openstack-helm.  We will be working to ensure that we support various deployment models that can support hyperscale, such as:

- Ensuring that by default, clusters include multiple replicas to verify that scaling issues are identified early and often (unless development mode is enabled).
- Ensuring that every chart can support more then one replica and allowing operators to override those replica counts. For some applications, this means that they support clustering.
- Ensuring clustering style applications are not limited to fixed replica counts.  For instance, we want to ensure that we can support n=Galera members and have those scale linearly, within reason, as opposed to only supporting a fixed count.
- Duplicate charts of the same type within the same namespace.  For example, deploying rabbitmq twice, to the openstack namespace resulting in two fully functioning clusters.
- Allowing charts to be deployed to a diverse set of namespaces.  For example, allowing infrastructure to be deployed in one namespace and OpenStack in another, or deploying each chart in its own namespace.
- Supporting hyperscale configurations that call for per-component infrastructure, such as a dedicated database and RabbitMQ solely for Ceilometer, or even dedicated infrastructure(s) for every component you deploy. It is unique, large scale deployment designs such as this that only become practical under a Kubernetes/Container framework and we want to ensure that we can support them.
