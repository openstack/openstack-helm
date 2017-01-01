#!/bin/bash
set -ex

exec heat-api-cloudwatch --config-dir /etc/heat/conf
