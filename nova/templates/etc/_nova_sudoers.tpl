{{/*
Copyright 2017 The Openstack-Helm Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

# This sudoers file supports rootwrap for both Kolla and LOCI Images.
Defaults !requiretty
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/var/lib/openstack/bin:/var/lib/kolla/venv/bin"
nova ALL = (root) NOPASSWD: /var/lib/kolla/venv/bin/nova-rootwrap /etc/nova/rootwrap.conf *, /var/lib/openstack/bin/nova-rootwrap /etc/nova/rootwrap.conf *
