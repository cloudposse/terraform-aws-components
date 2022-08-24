variable "region" {
  type        = string
  description = "AWS Region"
}

variable "root_account_aws_name" {
  type        = string
  description = "The name of the root account as reported by AWS"
}

variable "root_account_account_name" {
  type        = string
  default     = "root"
  description = "The stage name for the root account"
}

variable "identity_account_account_name" {
  type        = string
  default     = "identity"
  description = "The stage name for the account holding primary IAM roles"
}

variable "dns_account_account_name" {
  type        = string
  default     = "dns"
  description = "The stage name for the primary DNS account"
}

variable "artifacts_account_account_name" {
  type        = string
  default     = "artifacts"
  description = "The stage name for the artifacts account"
}

variable "audit_account_account_name" {
  type        = string
  default     = "audit"
  description = "The stage name for the audit account"
}

variable "iam_role_arn_template_template" {
  type        = string
  default     = "arn:%s:iam::%s:role/%s-%s-%s-%s-%%s"
  description = <<-EOT
  The template for the template used to render Role ARNs.
  The template is first used to render a template for the account that takes only the role name.
  Then that rendered template is used to create the final Role ARN for the account.
  Default is appropriate when using `tenant` and default label order with `null-label`.
  Use `"arn:%s:iam::%s:role/%s-%s-%s-%%s"` when not using `tenant`.


  Note that if the `null-label` variable `label_order` is truncated or extended with additional labels, this template will
  need to be updated to reflect the new number of labels.
  EOT
}

variable "profile_template" {
  type        = string
  default     = "%s-%s-%s-%s-%s"
  description = <<-EOT
  The template used to render AWS Profile names.
  Default is appropriate when using `tenant` and default label order with `null-label`.
  Use `"%s-%s-%s-%s"` when not using `tenant`.

  Note that if the `null-label` variable `label_order` is truncated or extended with additional labels, this template will
  need to be updated to reflect the new number of labels.
  EOT
}

variable "global_environment_name" {
  type        = string
  default     = "gbl"
  description = "Global environment name"
}

variable "profiles_enabled" {
  type        = bool
  default     = false
  description = "Whether or not to enable profiles instead of roles for the backend. If true, profile must be set. If false, role_arn must be set."
}
