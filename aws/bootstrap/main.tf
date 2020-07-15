terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

# User account that will be used for provisioning
module "user" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-system-user.git?ref=tags/0.3.2"

  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "bootstrap"
}

# Allow the user to assume role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["${module.user.user_arn}"]
    }
  }
}

# Fetch the OrganizationAccountAccessRole ARNs from SSM
module "organization_account_access_role_arns" {
  source         = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  parameter_read = "${formatlist("/${var.namespace}/%s/organization_account_access_role", var.accounts_enabled)}"
}

# IAM role for bootstrapping; allow user to assume it
resource "aws_iam_role" "bootstrap" {
  name               = "${module.user.user_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

# Grant Administrator Access to the current "root" account to the role
resource "aws_iam_role_policy_attachment" "administrator_access" {
  role       = "${aws_iam_role.bootstrap.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Generate a policy for assuming role into all child accounts
data "aws_iam_policy_document" "organization_account_access_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect    = "Allow"
    resources = ["${module.organization_account_access_role_arns.values}"]
  }
}

# Create an IAM policy from the generated document
resource "aws_iam_policy" "organization_account_access_role" {
  name   = "${aws_iam_role.bootstrap.name}"
  policy = "${data.aws_iam_policy_document.organization_account_access_role.json}"
}

# Assign the policy to the user
resource "aws_iam_user_policy_attachment" "organization_account_access_role" {
  user       = "${aws_iam_role.bootstrap.name}"
  policy_arn = "${aws_iam_policy.organization_account_access_role.arn}"
}

# Render the env file with IAM credentials
data "template_file" "env" {
  template = "${file("${path.module}/env.tpl")}"

  vars {
    aws_access_key_id     = "${module.user.access_key_id}"
    aws_secret_access_key = "${module.user.secret_access_key}"
    aws_assume_role_arn   = "${aws_iam_role.bootstrap.arn}"
    aws_data_path         = "${dirname(local_file.config_file.filename)}"
    aws_config_file       = "${local_file.config_file.filename}"
  }
}

# Write the env file to disk
resource "local_file" "env_file" {
  content  = "${data.template_file.env.rendered}"
  filename = "${var.output_path}/${var.env_file}"
}

# Render the credentials file with IAM credentials
data "template_file" "credentials" {
  template = "${file("${path.module}/credentials.tpl")}"

  vars {
    source_profile_name   = "${var.namespace}"
    aws_access_key_id     = "${module.user.access_key_id}"
    aws_secret_access_key = "${module.user.secret_access_key}"
    aws_assume_role_arn   = "${aws_iam_role.bootstrap.arn}"
  }
}

# Write the credentials file to disk
resource "local_file" "credentials_file" {
  content  = "${data.template_file.credentials.rendered}"
  filename = "${var.output_path}/${var.credentials_file}"
}

# Render the config file with IAM credentials
data "template_file" "config_root" {
  template = "${file("${path.module}/config.tpl")}"

  vars {
    profile_name   = "${var.namespace}-${var.stage}-admin"
    source_profile = "${var.namespace}"
    region         = "${var.aws_region}"
    role_arn       = "${aws_iam_role.bootstrap.arn}"
  }
}

# Render the config file with IAM credentials
data "template_file" "config" {
  count    = "${length(module.organization_account_access_role_arns.values)}"
  template = "${file("${path.module}/config.tpl")}"

  vars {
    profile_name   = "${var.namespace}-${var.accounts_enabled[count.index]}-admin"
    source_profile = "${var.namespace}"
    region         = "${var.aws_region}"
    role_arn       = "${module.organization_account_access_role_arns.values[count.index]}"
  }
}

# Write the config file to disk
resource "local_file" "config_file" {
  content = "${join("\n\n",
    concat(list("[profile ${var.namespace}]"),
  list(data.template_file.config_root.rendered), data.template_file.config.*.rendered))}"

  filename = "${var.output_path}/${var.config_file}"
}
