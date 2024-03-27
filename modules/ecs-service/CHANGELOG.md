## PR [#1008](https://github.com/cloudposse/terraform-aws-components/pull/1008)

### Possible Breaking Change

- Refactored how S3 Task Definitions and the Terraform Task definition are merged.
  - Introduced local `local.containers_priority_terraform` to be referenced whenever terraform Should take priority
  - Introduced local `local.containers_priority_s3` to be referenced whenever S3 Should take priority
- `map_secrets` pulled out from container definition to local where it can be better maintained. Used Terraform as
  priority as it is a calculated as a map of arns.
- `s3_mirror_name` now automatically uploads a task-template.json to s3 mirror where it can be pulled from GitHub
  Actions.
