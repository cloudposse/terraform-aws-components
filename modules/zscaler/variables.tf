variable "region" {
  type        = string
  description = "AWS region"
}

variable "ami_owner" {
  type        = string
  description = "The owner of the AMI used for the ZScaler EC2 instances."
  default     = "amazon"
}

variable "ami_regex" {
  type        = string
  description = "The regex used to match the latest AMI to be used for the ZScaler EC2 instances."
  default     = "^amzn2-ami-hvm.*"
}

variable "aws_ssm_enabled" {
  type        = bool
  description = "Set true to install the AWS SSM agent on each EC2 instances."
  default     = true
}

variable "instance_type" {
  type        = string
  default     = "r5n.medium"
  description = "The instance family to use for the ZScaler EC2 instances."
}
variable "secrets_store_type" {
  type        = string
  description = "Secret store type for Zscaler provisioning keys. Valid values: `SSM`, `ASM` (but `ASM` not currently supported)"
  default     = "SSM"

  validation {
    condition     = var.secrets_store_type == "SSM"
    error_message = "Only SSM is currently supported as the Secrets Store type."
  }
}

variable "zscaler_key" {
  type        = string
  description = "SSM key (without leading `/`) for the Zscaler provisioning key secret."
  default     = "zscaler/key"
}

variable "zscaler_count" {
  type        = number
  description = "The number of Zscaler instances."
  default     = 1
}

variable "security_group_rules" {
  type = list(any)
  default = [
    {
      type        = "egress"
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  description = <<-EOT
    A list of maps of Security Group rules.
    The values of map is fully complated with `aws_security_group_rule` resource.
    To get more info see [security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule).
  EOT
}
