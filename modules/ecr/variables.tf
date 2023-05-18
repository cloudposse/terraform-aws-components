variable "region" {
  type        = string
  description = "AWS Region"
}

variable "images" {
  type        = list(string)
  description = "List of image names (ECR repo names) to create repos for"
}

variable "image_tag_mutability" {
  type        = string
  description = "The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`"
  default     = "MUTABLE"
}

variable "max_image_count" {
  type        = number
  description = "Max number of images to store. Old ones will be deleted to make room for new ones."
}

variable "read_write_account_role_map" {
  type        = map(list(string))
  description = "Map of `account:[role, role...]` for write access. Use `*` for role to grant access to entire account"
}

variable "read_only_account_role_map" {
  type        = map(list(string))
  description = "Map of `account:[role, role...]` for read-only access. Use `*` for role to grant access to entire account"
  default     = {}
}

variable "ecr_user_enabled" {
  type        = bool
  description = "Enable/disable the provisioning of the ECR user (for CI/CD systems that don't support assuming IAM roles to access ECR, e.g. Codefresh)"
  default     = false
}

variable "scan_images_on_push" {
  type        = bool
  description = "Indicates whether images are scanned after being pushed to the repository"
  default     = false
}

variable "protected_tags" {
  type        = list(string)
  description = "Tags to refrain from deleting"
  default     = []
}

variable "enable_lifecycle_policy" {
  type        = bool
  description = "Enable/disable image lifecycle policy"
}

variable "principals_lambda" {
  type        = list(string)
  description = "Principal account IDs of Lambdas allowed to consume ECR"
  default     = []
}
