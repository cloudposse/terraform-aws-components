# Submodule `roles-to-principals`

This submodule is used by other modules to map short role names and AWS SSO Permission Set names in accounts designated
by short account names (for example, `terraform` in the `dev` account) to full IAM Role ARNs and other related tasks.

## Special Configuration Needed

As with `iam-roles`, in order to avoid having to pass customization information through every module that uses this
submodule, if the default configuration does not suit your needs, you are expected to add `variables_override.tf` to
override the variables with the defaults you want to use in your project. For example, if you are not using "core" as
the `tenant` portion of your "root" account (your Organization Management Account), then you should include the
`variable "overridable_global_tenant_name"` declaration in your `variables_override.tf` so that
`overridable_global_tenant_name` defaults to the value you are using (or the empty string if you are not using `tenant`
at all).
