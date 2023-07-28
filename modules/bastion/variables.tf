variable "region" {
  type        = string
  description = "AWS region"
}

variable "availability_zones" {
  type        = list(string)
  description = <<-EOT
    AWS Availability Zones in which to deploy multi-AZ resources.
    If not provided, resources will be provisioned in every private subnet in the VPC.
    EOT
  default     = []
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Bastion instance type"
}

variable "root_block_device_volume_size" {
  type        = number
  default     = 8
  description = "The volume size (in GiB) to provision for the root block device. It cannot be smaller than the AMI it refers to."
}

variable "associate_public_ip_address" {
  type        = bool
  default     = false
  description = "Whether to associate public IP to the instance."
}

variable "ebs_block_device_volume_size" {
  type        = number
  default     = 0
  description = "The volume size (in GiB) to provision for the EBS block device. Creation skipped if size is 0"
}

variable "ebs_delete_on_termination" {
  type        = bool
  default     = false
  description = "Whether the EBS volume should be destroyed on instance termination"
}

variable "user_data" {
  type        = list(string)
  default     = []
  description = "User data content"
}

variable "security_group_rules" {
  type = list(any)
  default = [
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "ingress"
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  description = <<-EOT
    A list of maps of Security Group rules.
    The values of map is fully complated with `aws_security_group_rule` resource.
    To get more info see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule .
  EOT
}

variable "custom_bastion_hostname" {
  type        = string
  default     = null
  description = "Hostname to assign with bastion instance"
}

variable "vanity_domain" {
  type        = string
  default     = null
  description = "Vanity domain"
}

# AWS KMS alias used for encryption/decryption of SSM secure strings
variable "kms_alias_name_ssm" {
  default     = "alias/aws/ssm"
  description = "KMS alias name for SSM"
}

variable "container_command" {
  type        = string
  default     = "bash"
  description = "The container command passed in after `docker run --rm -it <image> bash -c`."
}

variable "image_repository" {
  type        = string
  default     = ""
  description = "The image repository to use in `container.sh`."
}

variable "image_container" {
  type        = string
  default     = ""
  description = "The image container to use in `container.sh`."
}
