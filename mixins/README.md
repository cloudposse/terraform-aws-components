# Terraform Mixins

A Terraform mixin (inspired by the
[concept of the same name in OOP languages such as Python and Ruby](https://en.wikipedia.org/wiki/Mixin)) is a Terraform
configuration file that can be dropped into a root-level module, i.e. a component, in order to add additional
functionality.

Mixins are meant to encourage code reuse, leading to more simple components with less code repetition between component
to component.

<!-- prettier-ignore-start -->
<!-- BEGINNING OF TERRAFORM-MIXINS DOCS HOOK -->
## Mixin: `infra-state.mixin.tf`

This mixin is meant to be placed in a Terraform configuration outside the organization's infrastructure monorepo in order to:

1. Instantiate an AWS Provider using roles managed by the infrastructure monorepo. This is required because Cloud Posse's `providers.tf` pattern
requires an invocation of the `account-map` component’s `iam-roles` submodule, which is not present in a repository
outside of the infrastructure monorepo.
2. Retrieve outputs from a component in the infrastructure monorepo. This is required because Cloud Posse’s `remote-state` module expects
a `stacks` directory, which will not be present in other repositories, the monorepo must be cloned via a `monorepo` module
instantiation.

Because the source attribute in the `monorepo` and `remote-state` modules cannot be interpolated and refers to a monorepo
in a given organization, the following dummy placeholders have been put in place upstream and need to be replaced accordingly
when "dropped into" a Terraform configuration:

1. Infrastructure monorepo: `github.com/ACME/infrastructure`
2. Infrastructure monorepo ref: `0.1.0`

## Mixin: `introspection.mixin.tf`

This mixin is meant to be added to Terraform components in order to append a `Component` tag to all resources in the
configuration, specifying which component the resources belong to.

It's important to note that all modules and resources within the component then need to use `module.introspection.context`
and `module.introspection.tags`, respectively, rather than `module.this.context` and `module.this.tags`.

## Mixin: `provider-awsutils.mixin.tf`

This mixin is meant to be added to a terraform module that wants to use the awsutils provider.
It assumes the standard `providers.tf` file is present in the module.

## Mixin: `sops.mixin.tf`

This mixin is meant to be added to Terraform EKS components which are used in a cluster where sops-secrets-operator (see: https://github.com/isindir/sops-secrets-operator)
is deployed. It will then allow for SOPS-encrypted SopsSecret CRD manifests (such as `example.sops.yaml`) placed in a
`resources/` directory to be deployed to the cluster alongside the EKS component.

This mixin assumes that the EKS component in question follows the same pattern as `alb-controller`, `cert-manager`, `external-dns`,
etc. That is, that it has the following characteristics:

1. Has a `var.kubernetes_namespace` variable.
2. Does not already instantiate a Kubernetes provider (only the Helm provider is necessary, typically, for EKS components).

<!-- END OF TERRAFORM-MIXINS DOCS HOOK -->
<!-- prettier-ignore-end -->
