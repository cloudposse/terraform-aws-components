variable "region" {
  type        = string
  description = "AWS Region"
}

variable "performance_mode" {
  type        = string
  default     = "generalPurpose"
  description = "The file system performance mode. Can be either `generalPurpose` or `maxIO`"
}

variable "throughput_mode" {
  type        = string
  default     = "bursting"
  description = "Throughput mode for the file system. Defaults to bursting. Valid values: `bursting`, `provisioned`. When using `provisioned`, also set `provisioned_throughput_in_mibps`"
}

variable "provisioned_throughput_in_mibps" {
  type        = number
  default     = 0
  description = "The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable with `throughput_mode` set to provisioned"
}

variable "hostname_template" {
  type        = string
  description = <<-EOT
    The `format()` string to use to generate the hostname via `format(var.hostname_template, var.tenant, var.stage, var.environment)`"
    Typically something like `"echo.%[3]v.%[2]v.example.com"`.
  EOT
}

variable "efs_backup_policy_enabled" {
  type        = bool
  description = "If `true`, automatic backups will be enabled."
  default     = false
}

variable "eks_security_group_enabled" {
  type        = bool
  description = "Use the eks default security group"
  default     = false
}

variable "eks_component_names" {
  type        = set(string)
  description = "The names of the eks components"
  default     = ["eks/cluster"]
}

variable "additional_security_group_rules" {
  type        = list(any)
  default     = []
  description = <<-EOT
    A list of Security Group rule objects to add to the created security group, in addition to the ones
    this module normally creates. (To suppress the module's rules, set `create_security_group` to false
    and supply your own security group via `associated_security_group_ids`.)
    The keys and values of the objects are fully compatible with the `aws_security_group_rule` resource, except
    for `security_group_id` which will be ignored, and the optional "key" which, if provided, must be unique and known at "plan" time.
    To get more info see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule .
    EOT
}
