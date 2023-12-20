variable "region" {
  type        = string
  description = "AWS Region"
}

variable "iam_policies" {
  type        = list(string)
  description = "List of policies to attach to the IAM role, should be either an ARN of an AWS Managed Policy or a name of a custom policy e.g. `gitops`"
  default     = []
}

variable "iam_policy" {
  type = list(object({
    policy_id = optional(string, null)
    version   = optional(string, null)
    statements = list(object({
      sid           = optional(string, null)
      effect        = optional(string, null)
      actions       = optional(list(string), null)
      not_actions   = optional(list(string), null)
      resources     = optional(list(string), null)
      not_resources = optional(list(string), null)
      conditions = optional(list(object({
        test     = string
        variable = string
        values   = list(string)
      })), [])
      principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })), [])
      not_principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })), [])
    }))
  }))
  description = <<-EOT
    IAM policy as list of Terraform objects, compatible with Terraform `aws_iam_policy_document` data source
    except that `source_policy_documents` and `override_policy_documents` are not included.
    Use inputs `iam_source_policy_documents` and `iam_override_policy_documents` for that.
    EOT
  default     = []
  nullable    = false
}


variable "github_actions_allowed_repos" {
  type        = list(string)
  description = <<EOF
  A list of the GitHub repositories that are allowed to assume this role from GitHub Actions. For example,
  ["cloudposse/infra-live"]. Can contain "*" as wildcard.
  If org part of repo name is omitted, "cloudposse" will be assumed.
  EOF
  default     = []
}
