
# data "aws_caller_identity" "current" {}

# # Run the equivalent of
# # aws --no-cli-pager iam list-roles --path-prefix /aws-reserved/sso.amazonaws.com/ --query 'Roles[].RoleName'
# #module "cli" {
# #  source  = "digitickets/cli/aws"
# #  version = "3.0.0"
# #
# #  aws_cli_commands = ["iam", "list-roles", "--path-prefix", "/aws-reserved/sso.amazonaws.com/"]
# #  aws_cli_query = "Roles[].RoleName"
# #  assume_role_arn = data.aws_caller_identity.current.arn
# #}

# data "external" "awscli" {
#   program = ["${path.module}/scripts/list-sso-roles"]
#   query = {
#     assume_role_arn = data.aws_caller_identity.current.arn
#   }
# }

# locals {
#   # We are hard coding the mapping for now. This needs to be moved to YAML config.
#   sso_roles                 = jsondecode(data.external.awscli.result.output)
#   sso_authorized_role_names = [for name in local.sso_roles : name if length(regexall("^AWSReservedSSO_AdministratorAccess_", name)) > 0]
#   sso_authorized_roles      = { for name in local.sso_authorized_role_names : name => format("arn:aws:iam::%s:role/%s", data.aws_caller_identity.current.account_id, name) }
#   sso_auths = [for role, arn in local.sso_authorized_roles :
#     { rolearn  = arn
#       username = "${role}:{{SessionName}}"
#       groups   = ["system:masters", "idp:ops"]
#     }
#   ]
# }
