variable "region" {
  type        = string
  description = "AWS Region"
}

variable "account_email_format" {
  type        = string
  description = "Email address format for the accounts (e.g. `aws+%s@example.com`)"
}

variable "account_iam_user_access_to_billing" {
  type        = string
  description = "If set to `ALLOW`, the new account enables IAM users to access account billing information if they have the required permissions. If set to `DENY`, then only the root user of the new account can access account billing information"
  default     = "DENY"
}

variable "aws_service_access_principals" {
  type        = list(string)
  description = "List of AWS service principal names for which you want to enable integration with your organization. This is typically in the form of a URL, such as service-abbreviation.amazonaws.com. Organization must have `feature_set` set to ALL. For additional information, see the [AWS Organizations User Guide](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services.html)"
}

variable "enabled_policy_types" {
  type        = list(string)
  description = "List of Organizations policy types to enable in the Organization Root. Organization must have feature_set set to ALL. For additional information about valid policy types (e.g. SERVICE_CONTROL_POLICY and TAG_POLICY), see the [AWS Organizations API Reference](https://docs.aws.amazon.com/organizations/latest/APIReference/API_EnablePolicyType.html)"
}

variable "organization_config" {
  type        = any
  description = "Organization, Organizational Units and Accounts configuration"
}

variable "service_control_policies_config_paths" {
  type        = list(string)
  description = "List of paths to Service Control Policy configurations"
}

variable "organization_enabled" {
  type        = bool
  description = "A boolean flag indicating whether to create an Organization or use the existing one"
  default     = true
}
