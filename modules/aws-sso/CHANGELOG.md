# Change log for aws-sso component

**_NOTE_**: This file is manually generated and is a work-in-progress.

### PR 830

- Fix `providers.tf` to properly assign roles for `root` account when deploying to `identity` account.
- Restore the `sts:SetSourceIdentity` permission for Identity-role-TeamAccess permission sets added in PR 738 and
  inadvertently removed in PR 740.
- Update comments and documentation to reflect Cloud Posse's current recommendation that SSO **_not_** be delegated to
  the `identity` account.

### Version 1.240.1, PR 740

This PR restores compatibility with `account-map` prior to version 1.227.0 and fixes bugs that made versions 1.227.0 up
to this release unusable.

Access control configuration (`aws-teams`, `iam-primary-roles`, `aws-sso`, etc.) has undergone several transformations
over the evolution of Cloud Posse's reference architecture. This update resolves a number of compatibility issues with
some of them.

If the roles you are using to deploy this component are allowed to assume the `tfstate-backend` access roles (typically
`...-gbl-root-tfstate`, possibly `...-gbl-root-tfstate-ro` or `...-gbl-root-terraform`), then you can use the defaults.
This configuration was introduced in `terraform-aws-components` v1.227.0 and is the default for all new deployments.

If the roles you are using to deploy this component are not allowed to assume the `tfstate-backend` access roles, then
you will need to configure this component to include the following:

```yaml
components:
  terraform:
    aws-sso:
      backend:
        s3:
          role_arn: null
      vars:
        privileged: true
```

If you are deploying this component to the `identity` account, then this restriction will require you to deploy it via
the SuperAdmin user. If you are deploying this component to the `root` account, then any user or role in the `root`
account with the `AdministratorAccess` policy attached will be able to deploy this component.

## v1.227.0

This component was broken by changes made in v1.227.0. Either use a version before v1.227.0 or use the version released
by PR 740 or later.
