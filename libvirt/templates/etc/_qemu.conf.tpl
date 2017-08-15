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

# The backend to use for handling stdout/stderr output from
# QEMU processes.
#
#  'file': QEMU writes directly to a plain file. This is the
#          historical default, but allows QEMU to inflict a
#          denial of service attack on the host by exhausting
#          filesystem space
#
#  'logd': QEMU writes to a pipe provided by virtlogd daemon.
#          This is the current default, providing protection
#          against denial of service by performing log file
#          rollover when a size limit is hit.
#
stdio_handler = "file"
