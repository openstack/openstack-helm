helm delete mariadb --purge && rm mariadb-0.1.0.tgz && helm lint mariadb && helm package mariadb && helm install --replace --name mariadb mariadb-0.1.0.tgz
helm delete keystone --purge && rm keystone-0.1.0.tgz && helm lint keystone && helm package keystone && helm install --replace --name keystone keystone-0.1.0.tgz --dry-run
helm delete memcached --purge && rm memcached-0.1.0.tgz && helm lint memcached && helm package memcached && helm install --replace --name memcached memcached-0.1.0.tgz
helm delete common --purge && rm common-0.1.0.tgz && helm lint common && helm package common && helm install --replace --name common common-0.1.0.tgz
helm delete glance --purge && rm glance-0.1.0.tgz && helm lint glance && helm package glance && helm install --replace --name glance glance-0.1.0.tgz
helm delete nova --purge && rm nova-0.1.0.tgz && helm lint nova && helm package nova && helm install --replace --name nova nova-0.1.0.tgz
helm delete rabbitmq --purge && rm rabbitmq-0.1.0.tgz && helm lint rabbitmq && helm package rabbitmq && helm install --replace --name rabbitmq rabbitmq-0.1.0.tgz


