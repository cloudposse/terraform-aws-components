module "iam_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "0.4.0"
  context = module.this.context

  iam_policy_statements = {
    AmazonMWAAWebServerAccess = {
      effect    = "Allow"
      actions   = ["airflow:CreateWebLoginToken"]
      resources = ["*"]
    },
  }
}

resource "aws_iam_policy" "mwaa_web_server_access" {
  name        = "AmazonMWAAWebServerAccess"
  path        = "/"
  description = "A user may need access to this permissions policy if they need to access the Apache Airflow UI."
  policy      = module.iam_policy.json
}

resource "aws_iam_role_policy_attachment" "mwaa_web_server_access" {
  count      = length(var.allowed_web_access_role_names)
  role       = var.allowed_web_access_role_names[count.index]
  policy_arn = aws_iam_policy.mwaa_web_server_access.arn
}

resource "aws_iam_role_policy_attachment" "secrets_manager_read_write" {
  role       = split("/", module.mwaa_environment.execution_role_arn)[1]
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}
