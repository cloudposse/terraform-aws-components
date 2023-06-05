##################
#
# This file is a drop-in to provide a helm provider.
#
# All the following variables are just about configuring the Kubernetes provider
# to be able to modify EKS cluster. The reason there are so many options is
# because at various times, each one of them has had problems, so we give you a choice.
#
# The reason there are so many "enabled" inputs rather than automatically
# detecting whether or not they are enabled based on the value of the input
# is that any logic based on input values requires the values to be known during
# the "plan" phase of Terraform, and often they are not, which causes problems.
#
variable "kubeconfig_file_enabled" {
  type        = bool
  default     = false
  description = "If `true`, configure the Kubernetes provider with `kubeconfig_file` and use that kubeconfig file for authenticating to the EKS cluster"
}

variable "kubeconfig_file" {
  type        = string
  default     = ""
  description = "The Kubernetes provider `config_path` setting to use when `kubeconfig_file_enabled` is `true`"
}

variable "kubeconfig_context" {
  type        = string
  default     = ""
  description = "Context to choose from the Kubernetes kube config file"
}

variable "kube_data_auth_enabled" {
  type        = bool
  default     = false
  description = <<-EOT
    If `true`, use an `aws_eks_cluster_auth` data source to authenticate to the EKS cluster.
    Disabled by `kubeconfig_file_enabled` or `kube_exec_auth_enabled`.
    EOT
}

variable "kube_exec_auth_enabled" {
  type        = bool
  default     = true
  description = <<-EOT
    If `true`, use the Kubernetes provider `exec` feature to execute `aws eks get-token` to authenticate to the EKS cluster.
    Disabled by `kubeconfig_file_enabled`, overrides `kube_data_auth_enabled`.
    EOT
}

variable "kube_exec_auth_role_arn" {
  type        = string
  default     = ""
  description = "The role ARN for `aws eks get-token` to use"
}

variable "kube_exec_auth_role_arn_enabled" {
  type        = bool
  default     = true
  description = "If `true`, pass `kube_exec_auth_role_arn` as the role ARN to `aws eks get-token`"
}

variable "kube_exec_auth_aws_profile" {
  type        = string
  default     = ""
  description = "The AWS config profile for `aws eks get-token` to use"
}

variable "kube_exec_auth_aws_profile_enabled" {
  type        = bool
  default     = false
  description = "If `true`, pass `kube_exec_auth_aws_profile` as the `profile` to `aws eks get-token`"
}

variable "kubeconfig_exec_auth_api_version" {
  type        = string
  default     = "client.authentication.k8s.io/v1beta1"
  description = "The Kubernetes API version of the credentials returned by the `exec` auth plugin"
}

variable "helm_manifest_experiment_enabled" {
  type        = bool
  default     = false
  description = "Enable storing of the rendered manifest for helm_release so the full diff of what is changing can been seen in the plan"
}

locals {
  kubeconfig_file_enabled = var.kubeconfig_file_enabled
  kube_exec_auth_enabled  = local.kubeconfig_file_enabled ? false : var.kube_exec_auth_enabled
  kube_data_auth_enabled  = local.kube_exec_auth_enabled ? false : var.kube_data_auth_enabled

  # Eventually we might try to get this from an environment variable
  kubeconfig_exec_auth_api_version = var.kubeconfig_exec_auth_api_version

  exec_profile = local.kube_exec_auth_enabled && var.kube_exec_auth_aws_profile_enabled ? [
    "--profile", var.kube_exec_auth_aws_profile
  ] : []

  kube_exec_auth_role_arn = coalesce(var.kube_exec_auth_role_arn, var.import_role_arn, module.iam_roles.terraform_role_arn)
  exec_role = local.kube_exec_auth_enabled && var.kube_exec_auth_role_arn_enabled ? [
    "--role-arn", local.kube_exec_auth_role_arn
  ] : []

  certificate_authority_data = module.eks.outputs.eks_cluster_certificate_authority_data
  eks_cluster_id             = module.eks.outputs.eks_cluster_id
  eks_cluster_endpoint       = module.eks.outputs.eks_cluster_endpoint
}

data "aws_eks_cluster_auth" "eks" {
  count = local.kube_data_auth_enabled ? 1 : 0
  name  = local.eks_cluster_id
}

provider "helm" {
  kubernetes {
    host                   = local.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(local.certificate_authority_data)
    token                  = local.kube_data_auth_enabled ? data.aws_eks_cluster_auth.eks[0].token : null
    # The Kubernetes provider will use information from KUBECONFIG if it exists, but if the default cluster
    # in KUBECONFIG is some other cluster, this will cause problems, so we override it always.
    config_path    = local.kubeconfig_file_enabled ? var.kubeconfig_file : ""
    config_context = var.kubeconfig_context

    dynamic "exec" {
      for_each = local.kube_exec_auth_enabled ? ["exec"] : []
      content {
        api_version = local.kubeconfig_exec_auth_api_version
        command     = "aws"
        args = concat(local.exec_profile, [
          "eks", "get-token", "--cluster-name", local.eks_cluster_id
        ], local.exec_role)
      }
    }
  }
  experiments {
    manifest = var.helm_manifest_experiment_enabled
  }
}

provider "kubernetes" {
  host                   = local.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(local.certificate_authority_data)
  token                  = local.kube_data_auth_enabled ? data.aws_eks_cluster_auth.eks[0].token : null
  # The Kubernetes provider will use information from KUBECONFIG if it exists, but if the default cluster
  # in KUBECONFIG is some other cluster, this will cause problems, so we override it always.
  config_path    = local.kubeconfig_file_enabled ? var.kubeconfig_file : ""
  config_context = var.kubeconfig_context

  dynamic "exec" {
    for_each = local.kube_exec_auth_enabled ? ["exec"] : []
    content {
      api_version = local.kubeconfig_exec_auth_api_version
      command     = "aws"
      args = concat(local.exec_profile, [
        "eks", "get-token", "--cluster-name", local.eks_cluster_id
      ], local.exec_role)
    }
  }
}
