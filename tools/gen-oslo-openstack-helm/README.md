# gen-oslo-openstack-helm
Oslo Config Generator Hack to Generate Helm Configs

## Usage

From this directory run the following commands, adjusting for the OpenStack
project and/or branch desired as necessary.

``` bash
docker build . -t gen-oslo-openstack-helm
docker run -it --rm \
  -e PROJECT="heat" \
  -e PROJECT_BRANCH="stable/newton" \
  -e PROJECT_REPO=https://git.openstack.org/openstack/heat.git \
  gen-oslo-openstack-helm
```

This container will then drop you into a shell, at the project root with
OpenStack-Helm formatted configuration files in the standard locations produced
by genconfig for the project.
