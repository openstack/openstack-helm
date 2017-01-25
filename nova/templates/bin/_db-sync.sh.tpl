#!/bin/bash
set -ex

nova-manage db sync
nova-manage api_db sync
nova-manage db online_data_migrations
