#!/bin/bash -x

set -e

kubectl create secret docker-registry triliovault-image-registry \
   --docker-server="docker.io" \
   --docker-username=triliodocker \
   --docker-password=triliopassword \
   -n triliovault

kubectl describe secret triliovault-image-registry -n triliovault

echo "TrilioVault image pull secret created. Name: triliovault-image-registry"
