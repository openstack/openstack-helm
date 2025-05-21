# Copyright (c) 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: Apache-2.0

set -ex

designate-manage \
  --config-file /etc/designate/designate.conf \
  service clean
