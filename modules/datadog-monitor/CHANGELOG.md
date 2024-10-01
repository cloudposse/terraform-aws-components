## PR [#814](https://github.com/cloudposse/terraform-aws-components/pull/814)

### Removed Dead Code, Possible Breaking Change

The following inputs were removed because they no longer have any effect:

- datadog_api_secret_key
- datadog_app_secret_key
- datadog_secrets_source_store_account
- monitors_roles_map
- role_paths
- secrets_store_type

Except for `monitors_roles_map` and `role_paths`, these inputs were deprecated in an earlier PR, and replaced with
outputs from `datadog-configuration`.

The implementation of `monitors_roles_map` and `role_paths` has been lost.
