variable "organization_management_arn" {
  type        = string
  description = "The ARN of the role you want to assume for applying these changes - must be a root account for setting up Firewall Manager Admin Account."
  default     = null
}

variable "firewall_manager_administrator_arn" {
  type        = string
  description = "The ARN of the role you want to assume for destroying these changes - must be the AWS Firewall Manager administrator account. (contains admin_account_ids) "
  default     = null
}

variable "is_destroy" {
  type        = bool
  description = "Which command are we running through terraform"
  default = false
}

variable "admin_account_ids" {
  type        = list(string)
  description = "A list of AWS account IDs to associate with AWS Firewall Manager as the AWS Firewall Manager administrator account. This can be an AWS Organizations master account or a member account. Defaults to the current account."
  default     = []
}

variable "security_groups_common_policies" {
  type    = list(any)
  default = []
}

variable "security_groups_content_audit_policies" {
  type    = list(any)
  default = []
}

variable "security_groups_usage_audit_policies" {
  type    = list(any)
  default = []
}

variable "shiled_advanced_policies" {
  type    = list(any)
  default = []
}

variable "waf_policies" {
  type    = list(any)
  default = []
}

variable "waf_v2_policies" {
  type    = list(any)
  default = []
}

variable "dns_firewall_policies" {
  type    = list(any)
  default = []
}

variable "network_firewall_policies" {
  type    = list(any)
  default = []
}
