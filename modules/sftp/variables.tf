variable "region" {
  type        = string
  description = "VPN Endpoints are region-specific. This identifies the region. AWS Region"
}

variable "s3_bucket_context" {
  type        = any
  description = "The s3 bucket context map of inputs. The same null label inputs can be provided. Provide the `name` to find the s3 bucket using a data source."
}

variable "hosted_zone_suffix" {
  type        = string
  description = "The hosted zone name suffix. The stage name will be prefixed to this suffix."
}

variable "domain" {
  type        = string
  description = "Where your files are stored. S3 or EFS"
  default     = "S3"
}

variable "sftp_users" {
  type        = any
  default     = {}
  description = "List of SFTP usernames and public keys"
}

variable "restricted_home" {
  type        = bool
  description = "Restricts SFTP users so they only have access to their home directories."
  default     = true
}

variable "force_destroy" {
  type        = bool
  description = "Forces the AWS Transfer Server to be destroyed"
  default     = false
}

# Variables used when deploying to VPC
variable "address_allocation_ids" {
  type        = list(string)
  description = "A list of address allocation IDs that are required to attach an Elastic IP address to your SFTP server's endpoint. This property can only be used when endpoint_type is set to VPC."
  default     = []
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "A list of security groups IDs that are available to attach to your server's endpoint. If no security groups are specified, the VPC's default security groups are automatically assigned to your endpoint. This property can only be used when endpoint_type is set to VPC."
  default     = []
}

variable "vpc_endpoint_id" {
  type        = string
  description = "The ID of the VPC endpoint. This property can only be used when endpoint_type is set to VPC_ENDPOINT"
  default     = null
}

variable "security_policy_name" {
  type        = string
  description = "Specifies the name of the security policy that is attached to the server. Possible values are TransferSecurityPolicy-2018-11, TransferSecurityPolicy-2020-06, and TransferSecurityPolicy-FIPS-2020-06. Default value is: TransferSecurityPolicy-2018-11."
  default     = "TransferSecurityPolicy-2018-11"
}

variable "domain_name" {
  type        = string
  description = "Domain to use when connecting to the SFTP endpoint"
  default     = ""
}

variable "eip_enabled" {
  type        = bool
  description = "Whether to provision and attach an Elastic IP to be used as the SFTP endpoint. An EIP will be provisioned per subnet."
  default     = false
}

variable "security_group_rules" {
  type        = list(any)
  description = <<-EOT
    A list of Security Group rule objects to add to the created security group.
    EOT
  default = [
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
