# Submodule `roles-to-principals`

This submodule is used by other modules to map short role names and AWS
SSO Permission Set names in accounts designated by short account names
(for example, `terraform` in the `dev` account) to full IAM Role ARNs and
other related tasks.

## Special Configuration Needed

In order to avoid having to pass customization information through every module
that uses this submodule, if the default configuration does not suit your needs,
you are expected to customize `variables.tf` with the defaults you want to
use in your project. For example, if you are including the `tenant` label
in the designation of your "root" account (your Organization Management Account),
then you should modify `variables.tf` so that `global_tenant_name` defaults
to the appropriate value.
