#!/bin/bash
set -ex

exec heat-api-cfn --config-dir /etc/heat/conf
