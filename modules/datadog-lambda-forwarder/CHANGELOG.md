## PR [#814](https://github.com/cloudposse/terraform-aws-components/pull/814)

### Fix for `enabled = false` or Destroy and Recreate

Previously, when `enabled = false` was set, the component would not necessarily
function as desired (deleting any existing resources and not creating any new ones).
Also, previously, when deleting the component, there was a race condition where
the log group could be deleted before the lambda function was deleted, causing
the lambda function to trigger automatic recreation of the log group. This
would result in re-creation failing because Terraform would try to create the
log group but it already existed.

These issues have been fixed in this PR.
