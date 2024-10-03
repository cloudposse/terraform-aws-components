variable "apply_config_map_aws_auth" {
  type        = bool
  description = <<-EOT
    (Obsolete) Whether to execute `kubectl apply` to apply the ConfigMap to allow worker nodes to join the EKS cluster.
    This input is included to avoid breaking existing configurations that set it to `true`;
    a value of `false` is no longer allowed.
    This input is obsolete and will be removed in a future release.
    EOT
  default     = true
  nullable    = false
  validation {
    condition     = var.apply_config_map_aws_auth == true
    error_message = <<-EOT
      This component no longer supports the `aws-auth` ConfigMap and always updates the access.
      This input is obsolete and will be removed in a future release.
      EOT
  }
}

variable "map_additional_aws_accounts" {
  type        = list(string)
  description = <<-EOT
    (Obsolete) Additional AWS accounts to grant access to the EKS cluster.
    This input is included to avoid breaking existing configurations that
    supplied an empty list, but the list is no longer allowed to have entries.
    (It is not clear that it worked properly in earlier versions in any case.)
    This component now only supports EKS access entries, which require full principal ARNs.
    This input is deprecated and will be removed in a future release.
    EOT
  default     = []
  nullable    = false
  validation {
    condition     = length(var.map_additional_aws_accounts) == 0
    error_message = <<-EOT
      This component no longer supports `map_additional_aws_accounts`.
      (It is not clear that it worked properly in earlier versions in any case.)
      This component only supports EKS access entries, which require full principal ARNs.
      This input is deprecated and will be removed in a future release.
      EOT
  }
}

variable "map_additional_worker_roles" {
  type        = list(string)
  description = <<-EOT
    (Deprecated) AWS IAM Role ARNs of unmanaged Linux worker nodes to grant access to the EKS cluster.
    In earlier versions, this could be used to grant access to worker nodes of any type
    that were not managed by the EKS cluster. Now EKS requires that unmanaged worker nodes
    be classified as Linux or Windows servers, in this input is temporarily retained
    with the assumption that all worker nodes are Linux servers. (It is likely that
    earlier versions did not work properly with Windows worker nodes anyway.)
    This input is deprecated and will be removed in a future release.
    In the future, this component will either have a way to separate Linux and Windows worker nodes,
    or drop support for unmanaged worker nodes entirely.
    EOT
  default     = []
  nullable    = false
}
