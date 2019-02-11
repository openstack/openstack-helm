#!/bin/bash
set -ex

echo "Start Redis Test"
echo "Print Environmental variables"
echo $REDIS_HOST
echo $REDIS_PORT
echo $REDIS_DB
apt-get update
apt-get -y install python-pip
yes w | pip install redis
python /tmp/python-tests.py
