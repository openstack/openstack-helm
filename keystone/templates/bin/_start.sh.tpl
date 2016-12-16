#!/bin/bash		
set -ex		
		
# Loading Apache2 ENV variables		
source /etc/apache2/envvars		

# start apache with any container arguments
apache2 -DFOREGROUND $*
