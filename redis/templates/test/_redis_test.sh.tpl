#!/bin/bash
set -ex

echo "Start Redis Test"
echo "Print Environmental variables"
echo $REDIS_HOST
echo $REDIS_PORT
echo $REDIS_DB

python /tmp/python-tests.py
