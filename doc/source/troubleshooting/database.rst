====================
Database Deployments
====================

This guide is to help users debug any general storage issues when
deploying Charts in this repository.

Galera Cluster
==============

To test MariaDB, do the following:

::

    admin@kubenode01:~/projects/openstack-helm$ kubectl exec mariadb-0 -it -n openstack -- mysql -h mariadb.openstack -uroot -ppassword -e 'show databases;'
    +--------------------+
    | Database           |
    +--------------------+
    | information_schema |
    | keystone           |
    | mysql              |
    | performance_schema |
    +--------------------+
    admin@kubenode01:~/projects/openstack-helm$
