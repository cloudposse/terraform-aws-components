variable "region" {
  type        = string
  description = "AWS Region."
}

variable "flow_logs_enabled" {
  description = "Enable or disable flow logs for the Global Accelerator."
  type        = bool
  default     = false
}

variable "flow_logs_s3_bucket" {
  description = <<-EOT
  The name of the S3 Bucket for the Accelerator Flow Logs.
  If not specified but `var.flow_logs_enabled` is set to `true`, then the bucket name will be computed dynamically via
  `format("%v-%v-%v-global-accelerator-flow-logs", var.namespace, var.environment, var.stage)`.
  EOT
  type        = string
  default     = null
}

variable "flow_logs_s3_prefix" {
  description = "The Object Prefix within the S3 Bucket for the Accelerator Flow Logs. Required if `var.flow_logs_enabled` is set to `true`."
  type        = string
  default     = null
}

variable "flow_logs_s3_bucket_environment" {
  description = "The environment where the S3 Bucket for the Accelerator Flow Logs exists. Required if `var.flow_logs_enabled` is set to `true`."
  type        = string
  default     = null
}

variable "listeners" {
  description = <<-EOT
  list of listeners to configure for the global accelerator.
  For more information, see: [aws_globalaccelerator_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/globalaccelerator_listener).
  EOT
  type = list(object({
    client_affinity = string
    port_ranges = list(object({
      from_port = number
      to_port   = number
    }))
    protocol = string
  }))
  default = []
}
