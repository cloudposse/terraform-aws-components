variable "region" {
  type        = string
  description = "AWS Region"
}

variable "sftp_users" {
  type = map(object({
    user_name  = string,
    public_key = string
  }))

  default     = {}
  description = "List of SFTP usernames and public keys"
}

variable "vpc_stack_name" {
  description = "Name of stack that has the VPC you want to deploy into. EG: uw2-corp"
  default     = null
}
