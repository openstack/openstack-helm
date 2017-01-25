#!/bin/bash
set -ex

if [ -f /etc/apache2/envvars ]; then
   # Loading Apache2 ENV variables
   source /etc/apache2/envvars
fi

# Start Apache2
exec apache2 -DFOREGROUND
