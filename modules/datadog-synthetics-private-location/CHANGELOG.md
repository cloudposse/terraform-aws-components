## PR [#814](https://github.com/cloudposse/terraform-aws-components/pull/814)

### Possible Breaking Change

Previously this component directly created the Kubernetes namespace for the agent when `create_namespace` was set to
`true`. Now this component delegates that responsibility to the `helm-release` module, which better coordinates the
destruction of resources at destruction time (for example, ensuring that the Helm release is completely destroyed and
finalizers run before deleting the namespace).

Generally the simplest upgrade path is to destroy the Helm release, then destroy the namespace, then apply the new
configuration. Alternatively, you can use `terraform state mv` to move the existing namespace to the new Terraform
"address", which will preserve the existing deployment and reduce the possibility of the destroy failing and leaving the
Kubernetes cluster in a bad state.
