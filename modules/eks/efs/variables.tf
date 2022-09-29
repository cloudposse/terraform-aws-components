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
