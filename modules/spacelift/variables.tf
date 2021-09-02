variable "runner_image" {
  type        = string
  description = "Full address & tag of the Spacelift runner image (e.g. on ecr)"
}

variable "worker_pool_id" {
  type        = string
  description = "Alpha-numberic worker poold ID of the Spacelift worker pool to use"
}

variable "terraform_version" {
  type        = string
  description = "Default Terraform version for all stacks created by this project"
}

variable "autodeploy" {
  type        = bool
  description = "Default autodeploy value for all stacks created by this project"
}

variable "git_repository" {
  type        = string
  description = "The Git repository name"
  default     = "infrastructure"
}

variable "git_branch" {
  type        = string
  description = "The Git branch name"
  default     = "main"
}

variable "spacelift_component_path" {
  type        = string
  description = "The Spacelift Component Path"
  default     = "components/terraform"
}

variable "terraform_version_map" {
  type        = map(string)
  description = "A map to determine which Terraform patch version to use for each minor version"
  default     = {}
}
