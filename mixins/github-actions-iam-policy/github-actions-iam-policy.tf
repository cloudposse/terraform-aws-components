## Custom IAM Policy for GitHub Actions
## Requires GitHub OIDC Component be deployed
## Usage:
## in your stack configuration:
# components:
#   terraform:
#     foo:
#       vars:
#         github_actions_iam_role_enabled: true
#         github_actions_allowed_repos:
#         - MyOrg/MyRepo
#         github_actions_iam_policy_statements:
#         - Sid: "AllowAll"
#           Action: [
#             "lambda:*",
#           ]
#           Effect: "Allow"
#           Resource: ["*"]
#


variable "github_actions_iam_policy_statements" {
  type    = list(any)
  default = []
}

locals {
  enabled = module.this.enabled
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = var.github_actions_iam_policy_statements
  })
  github_actions_iam_policy = local.policy
}
