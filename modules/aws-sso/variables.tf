variable "region" {
  type        = string
  description = "AWS Region"
}

variable "tfstate_environment_name" {
  type        = string
  description = "The name of the environment where `tfstate-backend` is provisioned"
}

variable "global_environment_name" {
  type        = string
  description = "Global environment name"
  default     = "gbl"
}

variable "global_stage_name" {
  type        = string
  description = "The name of the stage where `account_map` is provisioned"
  default     = "root"
}

variable "privileged" {
  type        = bool
  description = "True if the default provider already has access to the backend"
  default     = true
}

variable "account_assignments" {
  type = map(map(map(object({
    permission_sets = list(string)
    }
  ))))
  description = <<-EOT
    Enables access to permission sets for users and groups in accounts, in the following structure:

    ```yaml
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
  default     = {}
}

variable "aws_teams_stage_name" {
  type        = string
  description = "The name of the stage where the IAM primary roles are provisioned"
  default     = "identity"
}

variable "aws_teams_accessible" {
  type        = set(string)
  description = <<-EOT
    List of IAM roles (e.g. ["admin", "terraform"]) for which to create permission
    sets that allow the user to assume that role. Named like
    admin -> IdentityAdminTeamAccess
    EOT
  default     = []
}
