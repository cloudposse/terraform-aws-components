variable "region" {
  type        = string
  description = "AWS region"
}

variable "ami_owner" {
  type        = string
  description = "The owner of the AMI used for the ZScaler EC2 instances."
  default     = "amazon"
}

variable "ami_name_regex" {
  type        = string
  description = "The regex used to match the latest AMI to be used for the EC2 instance."
  default     = "^amzn2-ami-hvm.*"
}

variable "ami_filters" {
  type = list(object({
    name   = string
    values = list(string)
  }))
  default = [
    {
      name   = "architecture"
      values = ["x86_64"]
    },
    {
      name   = "virtualization-type"
      values = ["hvm"]
    }
  ]
  description = "A list of AMI filters for finding the latest AMI"
}

variable "instance_type" {
  type        = string
  default     = "t3a.micro"
  description = "The instance family to use for the EC2 instance"
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
    The values of map is fully completed with `aws_security_group_rule` resource.
    To get more info see [security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule).
  EOT
}

variable "user_data" {
  type        = string
  default     = "echo \"hello user data\""
  description = "User data to be included with this EC2 instance"
}
