variable "region" {
  type        = string
  description = "AWS Region"
}

variable "profile" {
  type        = string
  description = <<EOT
  The profile to use to apply the component.
  This is typically a role / user in the imported account and is segregated from the backend profile because this profile likely doesn't have permissions to access the
  newer tfstate backend that is hosted in the imported account hierarchy.
  EOT
}

variable "org_admin_arn" {
  type        = string
  description = <<EOT
  The ARN of the OrgAdmin IAM user or role that is provisioned in the root account.
  This Role or User will be allowed to assume the `OrganizationAccountAccessRole` role created by this component in the imported account.
  EOT
}
