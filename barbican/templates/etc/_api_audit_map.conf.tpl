[DEFAULT]
# default target endpoint type
# should match the endpoint type defined in service catalog
target_endpoint_type = key-manager

# map urls ending with specific text to a unique action
# Don't need custom mapping for other resource operations
# Note: action should match action names defined in CADF taxonomy
[custom_actions]
acl/get = read


# path of api requests for CADF target typeURI
# Just need to include top resource path to identify class of resources
[path_keywords]
secrets=
containers=
orders=
cas=None
quotas=
project-quotas=


# map endpoint type defined in service catalog to CADF typeURI
[service_endpoints]
key-manager = service/security/keymanager
