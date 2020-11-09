variable "region" {
  type        = string
  description = "AWS Region"
}

variable "images" {
  type        = list(string)
  description = "List of image names (ECR repo names) to create repos for"
}

variable "max_image_count" {
  type        = number
  description = "Max number of images to store. Old ones will be deleted to make room for new ones"
  default     = 500
}

variable "read_write_account_role_map" {
  type        = map(list(string))
  description = "Map of account:[role, role...] for write access. Use `*` for role to grant access to entire account"
}

variable "read_only_account_role_map" {
  type        = map(list(string))
  description = "Map of account:[role, role...] for read-only access. Use `*` for role to grant access to entire account"
  default     = {}
}

variable "cicd_accounts" {
  type        = set(string)
  description = "List of accounts that have EKS service roles that can write to this ECR"
  default     = []
}
