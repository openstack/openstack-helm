#!/bin/bash

set -ex

ceph mon remove $(hostname -s)
