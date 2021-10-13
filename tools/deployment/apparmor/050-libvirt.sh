#!/bin/bash

#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
set -xe

#NOTE: Lint and package chart
make libvirt

tee /tmp/libvirt.yaml <<EOF
images:
  tags:
    apparmor_loader: google/apparmor-loader:latest
pod:
  mandatory_access_control:
    type: apparmor
    configmap_apparmor: true
    libvirt-libvirt-default:
      libvirt-libvirt-default: localhost/my-apparmor-v1
      apparmor-loader: unconfined
conf:
  apparmor_profiles:
    my-apparmor-v1.profile: |-
      #include <tunables/global>
      @{LIBVIRT}="libvirt"
      profile my-apparmor-v1 flags=(attach_disconnected) {
        #include <abstractions/base>
        #include <abstractions/dbus>

        capability kill,
        capability audit_write,
        capability audit_control,
        capability net_admin,
        capability net_raw,
        capability setgid,
        capability sys_admin,
        capability sys_module,
        capability sys_ptrace,
        capability sys_pacct,
        capability sys_nice,
        capability sys_chroot,
        capability setuid,
        capability dac_override,
        capability dac_read_search,
        capability fowner,
        capability chown,
        capability setpcap,
        capability mknod,
        capability fsetid,
        capability audit_write,
        capability ipc_lock,

        # Needed for vfio
        capability sys_resource,

        mount options=(rw,rslave)  -> /,
        mount options=(rw, nosuid) -> /{var/,}run/libvirt/qemu/*.dev/,

        mount options=(rw, move) /dev/           -> /{var/,}run/libvirt/qemu/*.dev/,
        mount options=(rw, move) /dev/hugepages/ -> /{var/,}run/libvirt/qemu/*.hugepages/,
        mount options=(rw, move) /dev/mqueue/    -> /{var/,}run/libvirt/qemu/*.mqueue/,
        mount options=(rw, move) /dev/pts/       -> /{var/,}run/libvirt/qemu/*.pts/,
        mount options=(rw, move) /dev/shm/       -> /{var/,}run/libvirt/qemu/*.shm/,

        mount options=(rw, move) /{var/,}run/libvirt/qemu/*.dev/       -> /dev/,
        mount options=(rw, move) /{var/,}run/libvirt/qemu/*.hugepages/ -> /dev/hugepages/,
        mount options=(rw, move) /{var/,}run/libvirt/qemu/*.mqueue/    -> /dev/mqueue/,
        mount options=(rw, move) /{var/,}run/libvirt/qemu/*.pts/       -> /dev/pts/,
        mount options=(rw, move) /{var/,}run/libvirt/qemu/*.shm/       -> /dev/shm/,

        network inet stream,
        network inet dgram,
        network inet6 stream,
        network inet6 dgram,
        network netlink raw,
        network packet dgram,
        network packet raw,

        # for --p2p migrations
        unix (send, receive) type=stream addr=none peer=(label=unconfined addr=none),

        ptrace (trace) peer=unconfined,
        ptrace (trace) peer=/usr/sbin/libvirtd,
        ptrace (trace) peer=/usr/sbin/dnsmasq,
        ptrace (trace) peer=libvirt-*,

        signal (send) peer=/usr/sbin/dnsmasq,
        signal (read, send) peer=libvirt-*,
        signal (send) set=("kill", "term") peer=unconfined,

        # For communication/control to qemu-bridge-helper
        unix (send, receive) type=stream addr=none peer=(label=/usr/sbin/libvirtd//qemu_bridge_helper),
        signal (send) set=("term") peer=/usr/sbin/libvirtd//qemu_bridge_helper,

        # Very lenient profile for libvirtd since we want to first focus on confining
        # the guests. Guests will have a very restricted profile.
        / r,
        /** rwmkl,

        /bin/* PUx,
        /sbin/* PUx,
        /usr/bin/* PUx,
        /usr/sbin/virtlogd pix,
        /usr/sbin/* PUx,
        /{usr/,}lib/udev/scsi_id PUx,
        /usr/{lib,lib64}/xen-common/bin/xen-toolstack PUx,
        /usr/{lib,lib64}/xen/bin/* Ux,
        /usr/lib/xen-*/bin/libxl-save-helper PUx,

        # Required by nwfilter_ebiptables_driver.c:ebiptablesWriteToTempFile() to
        # read and run an ebtables script.
        /var/lib/libvirt/virtd* ixr,

        # force the use of virt-aa-helper
        audit deny /{usr/,}sbin/apparmor_parser rwxl,
        audit deny /etc/apparmor.d/libvirt/** wxl,
        audit deny /sys/kernel/security/apparmor/features rwxl,
        audit deny /sys/kernel/security/apparmor/matching rwxl,
        audit deny /sys/kernel/security/apparmor/.* rwxl,
        /sys/kernel/security/apparmor/profiles r,
        /usr/{lib,lib64}/libvirt/* PUxr,
        /usr/{lib,lib64}/libvirt/libvirt_parthelper ix,
        /usr/{lib,lib64}/libvirt/libvirt_iohelper ix,
        /etc/libvirt/hooks/** rmix,
        /etc/xen/scripts/** rmix,

        # allow changing to our UUID-based named profiles
        change_profile -> @{LIBVIRT}-[0-9a-f]*-[0-9a-f]*-[0-9a-f]*-[0-9a-f]*-[0-9a-f]*,

        /usr/{lib,lib64,lib/qemu,libexec}/qemu-bridge-helper Cx -> qemu_bridge_helper,
        # child profile for bridge helper process
        profile qemu_bridge_helper {
         #include <abstractions/base>

         capability setuid,
         capability setgid,
         capability setpcap,
         capability net_admin,

         network inet stream,

         # For communication/control from libvirtd
         unix (send, receive) type=stream addr=none peer=(label=/usr/sbin/libvirtd),
         signal (receive) set=("term") peer=/usr/sbin/libvirtd,

         /dev/net/tun rw,
         /etc/qemu/** r,
         owner @{PROC}/*/status r,

         /usr/{lib,lib64,lib/qemu,libexec}/qemu-bridge-helper rmix,
        }
      }
EOF

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS_LIBVIRT:="$(./tools/deployment/common/get-values-overrides.sh libvirt)"}

helm upgrade --install libvirt ./libvirt \
  --namespace=openstack \
  --values=/tmp/libvirt.yaml \
  --set network.backend="null" \
  ${OSH_EXTRA_HELM_ARGS} \
  ${OSH_EXTRA_HELM_ARGS_LIBVIRT}

#NOTE: Validate Deployment info
./tools/deployment/common/wait-for-pods.sh openstack
