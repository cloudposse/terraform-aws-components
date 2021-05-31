variable "tfstate_assume_role" {
  type        = bool
  description = "Set to false to use the caller's role to access the Terraform remote state"
  default     = true
}

variable "tfstate_existing_role_arn" {
  type        = string
  description = "The ARN of the existing IAM Role to access the Terraform remote state. If not provided and `remote_state_assume_role` is `true`, a role will be constructed from `remote_state_role_arn_template`"
  default     = ""
}

variable "tfstate_account_id" {
  type        = string
  default     = ""
  description = "The ID of the account where the Terraform remote state backend is provisioned"
}

variable "tfstate_role_arn_template" {
  type        = string
  default     = "arn:aws:iam::%s:role/%s-%s-%s-%s"
  description = "IAM Role ARN template for accessing the Terraform remote state"
}

variable "tfstate_role_environment_name" {
  type        = string
  default     = "gbl"
  description = "The name of the environment for Terraform state IAM role"
}

variable "tfstate_role_stage_name" {
  type        = string
  default     = "root"
  description = "The name of the stage for Terraform state IAM role"
}

variable "tfstate_bucket_environment_name" {
  type        = string
  default     = ""
  description = "The name of the environment for Terraform state bucket"
}

variable "tfstate_bucket_stage_name" {
  type        = string
  default     = "root"
  description = "The name of the stage for Terraform state bucket"
}

variable "tfstate_role_name" {
  type        = string
  default     = "terraform"
  description = "IAM Role name for accessing the Terraform remote state"
}

locals {
  tfstate_access_role_arn = var.tfstate_assume_role ? (
    (var.tfstate_existing_role_arn != null && var.tfstate_existing_role_arn != "") ? var.tfstate_existing_role_arn : (
      format(var.tfstate_role_arn_template,
        var.tfstate_account_id,
        module.this.namespace,
        var.tfstate_role_environment_name,
        var.tfstate_role_stage_name,
        var.tfstate_role_name
      )
    )
  ) : null

  tfstate_bucket         = "${module.this.namespace}-${var.tfstate_bucket_environment_name}-${var.tfstate_bucket_stage_name}-tfstate"
  tfstate_dynamodb_table = "${module.this.namespace}-${var.tfstate_bucket_environment_name}-${var.tfstate_bucket_stage_name}-tfstate-lock"
}
