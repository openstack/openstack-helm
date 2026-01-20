#!/bin/bash
set -ex

{{ include "helm-toolkit.scripts.keystone_user" . }}
