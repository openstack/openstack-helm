{
    "context_is_admin":  "role:admin",
    "admin_or_owner":  "is_admin:True or project_id:%(project_id)s",
    "default": "rule:admin_or_owner",
    "admin_api": "rule:context_is_admin",
    "admin_or_user": "is_admin:True or user_id:%(user_id)s",
    "cluster_user": "user_id:%(trustee_user_id)s",
    "deny_cluster_user": "not domain_id:%(trustee_domain_id)s",

    "bay:create": "rule:deny_cluster_user",
    "bay:delete": "rule:deny_cluster_user",
    "bay:detail": "rule:deny_cluster_user",
    "bay:get": "rule:deny_cluster_user",
    "bay:get_all": "rule:deny_cluster_user",
    "bay:update": "rule:deny_cluster_user",

    "baymodel:create": "rule:deny_cluster_user",
    "baymodel:delete": "rule:deny_cluster_user",
    "baymodel:detail": "rule:deny_cluster_user",
    "baymodel:get": "rule:deny_cluster_user",
    "baymodel:get_all": "rule:deny_cluster_user",
    "baymodel:update": "rule:deny_cluster_user",
    "baymodel:publish": "rule:admin_or_owner",

    "cluster:create": "rule:deny_cluster_user",
    "cluster:delete": "rule:deny_cluster_user",
    "cluster:detail": "rule:deny_cluster_user",
    "cluster:get": "rule:deny_cluster_user",
    "cluster:get_all": "rule:deny_cluster_user",
    "cluster:update": "rule:deny_cluster_user",

    "clustertemplate:create": "rule:deny_cluster_user",
    "clustertemplate:delete": "rule:deny_cluster_user",
    "clustertemplate:detail": "rule:deny_cluster_user",
    "clustertemplate:get": "rule:deny_cluster_user",
    "clustertemplate:get_all": "rule:deny_cluster_user",
    "clustertemplate:update": "rule:deny_cluster_user",
    "clustertemplate:publish": "rule:admin_or_owner",

    "rc:create": "rule:default",
    "rc:delete": "rule:default",
    "rc:detail": "rule:default",
    "rc:get": "rule:default",
    "rc:get_all": "rule:default",
    "rc:update": "rule:default",

    "certificate:create": "rule:admin_or_user or rule:cluster_user",
    "certificate:get": "rule:admin_or_user or rule:cluster_user",

    "magnum-service:get_all": "rule:admin_api"
}
