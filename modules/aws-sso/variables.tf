variable "region" {
  description = "AWS Region"
  type        = string
}

variable "global_environment_name" {
  description = "Global environment name"
  type        = string
  default     = "gbl"
}
variable "root_account_stage_name" {
  description = "The name of the stage where `account_map` is provisioned"
  type        = string
  default     = "root"
}

variable "privileged" {
  description = "True if the default provider already has access to the backend"
  type        = bool
  default     = true
}

variable "account_assignments" {

  description = <<-EOT
  Enables access to permission sets for users and groups in accounts, in the following structure:
=======
  description = <<-DOC
  Enables access to permission sets for users and groups in accounts, in the following structure:


  ```
  <account-name>:
    groups:
      <group-name>:
        permission_sets:
          - <permission-set-name>
    users:
      <user-name>:
        permission_sets:
          - <permission-set-name>
  ```

  EOT
=======
  DOC


  type = map(map(map(object({
    permission_sets = list(string)
    }
  ))))
  default = {}
}

variable "iam_primary_roles_stage_name" {
  description = "The name of the stage where the IAM primary roles are provisioned"
  type        = string
  default     = "identity"
}


variable "identity_roles_accessible" {
  description = <<-EOT
    List of IAM roles (e.g. ["admin", "terraform"]) for which to create permission
    sets that allow the user to assume that role. Named like
    admin -> IdentityAdminRoleAccess
    EOT
  type        = set(string)
  default     = []
}
