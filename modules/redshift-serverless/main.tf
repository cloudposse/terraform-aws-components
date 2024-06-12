
locals {
  enabled        = module.this.enabled
  subnet_ids     = var.use_private_subnets ? module.vpc.outputs.private_subnet_ids : module.vpc.outputs.public_subnet_ids
  admin_user     = var.admin_user != null && var.admin_user != "" ? var.admin_user : join("", random_pet.admin_user.*.id)
  admin_password = var.admin_password != null && var.admin_password != "" ? var.admin_password : join("", random_password.admin_password.*.result)
}

resource "random_pet" "admin_user" {
  count = local.enabled && (var.admin_user == null || var.admin_user == "") ? 1 : 0

  length    = 2
  separator = "_"

  keepers = {
    db_name = var.database_name
  }
}

resource "random_password" "admin_password" {
  count = local.enabled && (var.admin_password == null || var.admin_password == "") ? 1 : 0

  length = 33
  # Leave special characters out to avoid quoting and other issues.
  # Special characters have no additional security compared to increasing length.
  special          = false
  override_special = "!#$%^&*()<>-_"

  keepers = {
    db_name = var.database_name
  }
}

module "redshift_sg" {
  count = local.enabled && var.custom_sg_enabled ? 1 : 0

  source  = "cloudposse/security-group/aws"
  version = "2.0.0-rc1"

  create_before_destroy      = true
  preserve_security_group_id = true

  attributes = ["redshift"]

  # Allow unlimited egress
  allow_all_egress = var.custom_sg_allow_all_egress

  rules = var.custom_sg_rules

  vpc_id = module.vpc.outputs.vpc_id

  context = module.this.context
}


resource "aws_redshiftserverless_workgroup" "default" {
  count = local.enabled ? 1 : 0

  namespace_name = aws_redshiftserverless_namespace.default[0].namespace_name

  depends_on = [
    aws_redshiftserverless_namespace.default[0]
  ]

  workgroup_name = module.this.id

  base_capacity        = var.base_capacity
  enhanced_vpc_routing = var.enhanced_vpc_routing
  publicly_accessible  = var.publicly_accessible
  security_group_ids   = coalesce(var.security_group_ids, module.redshift_sg[*].id, [])
  subnet_ids           = local.subnet_ids

  dynamic "config_parameter" {
    for_each = var.config_parameter
    content {
      parameter_key   = config_parameter.key
      parameter_value = config_parameter.value
    }
  }
  tags = module.this.tags

}

resource "aws_redshiftserverless_namespace" "default" {
  count = local.enabled ? 1 : 0

  namespace_name = module.this.id

  admin_user_password  = local.admin_password
  admin_username       = local.admin_user
  db_name              = var.database_name
  default_iam_role_arn = var.default_iam_role_arn
  iam_roles            = var.iam_roles
  kms_key_id           = var.kms_key_id
  log_exports          = var.log_exports

  tags = var.tags
}


resource "aws_redshiftserverless_endpoint_access" "default" {
  count = local.enabled ? 1 : 0

  workgroup_name = aws_redshiftserverless_workgroup.default[0].workgroup_name

  endpoint_name          = var.endpoint_name == null ? format("%s-%s", module.this.stage, module.this.name) : var.endpoint_name
  subnet_ids             = local.subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids != null ? var.vpc_security_group_ids : [module.vpc.outputs.vpc_default_security_group_id]
}
