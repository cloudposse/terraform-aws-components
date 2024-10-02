# Submodule `iam-roles`

This submodule is used by other modules to determine which IAM Roles or AWS CLI Config Profiles to use for various
tasks, most commonly for applying Terraform plans.

## Special Configuration Needed

In order to avoid having to pass customization information through every module that uses this submodule, if the default
configuration does not suit your needs, you are expected to add `variables_override.tf` to override the variables with
the defaults you want to use in your project. For example, if you are not using "core" as the `tenant` portion of your
"root" account (your Organization Management Account), then you should include the
`variable "overridable_global_tenant_name"` declaration in your `variables_override.tf` so that
`overridable_global_tenant_name` defaults to the value you are using (or the empty string if you are not using `tenant`
at all).
