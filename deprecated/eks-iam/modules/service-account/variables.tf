variable "cluster_context" {
  type = object({
    aws_account_number          = string
    eks_cluster_oidc_issuer_url = string
    service_account_list        = list(string)
  })
}

variable "service_account_name" {
  type        = string
  description = "Kubernetes ServiceAccount name"
}

variable "service_account_namespace" {
  type        = string
  description = "Kubernetes Namespace where service account is deployed"
}

variable "aws_iam_policy_document" {
  type        = string
  description = "JSON string representation of the IAM policy for this service account"
}
