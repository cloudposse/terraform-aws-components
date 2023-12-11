variable "region" {
  type        = string
  description = "AWS Region"
}

variable "privileged" {
  type        = bool
  description = "True if the user running the Terraform command already has access to the Terraform backend"
  default     = false
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

variable "aws_teams_accessible" {
  type        = set(string)
  description = <<-EOT
    List of IAM roles (e.g. ["admin", "terraform"]) for which to create permission
    sets that allow the user to assume that role. Named like
    admin -> IdentityAdminTeamAccess
    EOT
  default     = []
}

variable "groups" {
  type        = list(string)
  description = <<-EOT
    List of AWS Identity Center Groups to be created with the AWS API.

    When provisioning the Google Workspace Integration with AWS, Groups need to be created with API in order for automatic provisioning to work as intended.
    EOT
  default     = []
}
