locals {
  enabled = module.this.enabled

  dns_zone_id                   = module.dns_delegated.outputs.default_dns_zone_id
  vpc_id                        = module.vpc.outputs.vpc_id
  vpc_default_security_group    = module.vpc.outputs.vpc_default_security_group_id
  vpc_private_subnet_ids        = module.vpc.outputs.private_subnet_ids
  elasticsearch_endpoint_format = "/elasticsearch/${module.this.name}/%s"
  elasticsearch_domain_endpoint = format(local.elasticsearch_endpoint_format, "elasticsearch_domain_endpoint")
  elasticsearch_kibana_endpoint = format(local.elasticsearch_endpoint_format, "elasticsearch_kibana_endpoint")
  elasticsearch_admin_password  = format(local.elasticsearch_endpoint_format, "password")
}

locals {
  create_password        = local.enabled && length(var.elasticsearch_password) == 0
  elasticsearch_password = local.create_password ? join("", random_password.elasticsearch_password.*.result) : var.elasticsearch_password
}

module "elasticsearch" {
  source  = "cloudposse/elasticsearch/aws"
  version = "0.33.0"

  security_groups                = [local.vpc_default_security_group]
  vpc_id                         = local.vpc_id
  subnet_ids                     = local.vpc_private_subnet_ids
  zone_awareness_enabled         = length(local.vpc_private_subnet_ids) > 1 ? true : false
  elasticsearch_version          = var.elasticsearch_version
  instance_type                  = var.instance_type
  instance_count                 = length(local.vpc_private_subnet_ids)
  availability_zone_count        = length(local.vpc_private_subnet_ids)
  encrypt_at_rest_enabled        = var.encrypt_at_rest_enabled
  dedicated_master_enabled       = var.dedicated_master_enabled
  create_iam_service_linked_role = var.create_iam_service_linked_role
  kibana_subdomain_name          = module.this.environment
  ebs_volume_size                = var.ebs_volume_size
  dns_zone_id                    = local.dns_zone_id
  kibana_hostname_enabled        = var.kibana_hostname_enabled
  domain_hostname_enabled        = var.domain_hostname_enabled
  iam_role_arns                  = var.elasticsearch_iam_role_arns
  iam_actions                    = var.elasticsearch_iam_actions

  node_to_node_encryption_enabled                          = true
  advanced_security_options_enabled                        = true
  advanced_security_options_internal_user_database_enabled = true
  advanced_security_options_master_user_name               = "admin"
  advanced_security_options_master_user_password           = local.elasticsearch_password

  allowed_cidr_blocks = [module.vpc.outputs.vpc_cidr]

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  context = module.this.context
}

resource "random_password" "elasticsearch_password" {
  # character length
  length = 33

  special = true
  upper   = true
  lower   = true
  number  = true

  min_special = 1
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "aws_ssm_parameter" "admin_password" {
  count       = local.enabled ? 1 : 0
  name        = local.elasticsearch_admin_password
  value       = local.elasticsearch_password
  description = "Primary Aurora Postgres Password for the master DB user"
  type        = "SecureString"
  overwrite   = true
}


resource "aws_ssm_parameter" "elasticsearch_domain_endpoint" {
  count       = local.enabled ? 1 : 0
  name        = local.elasticsearch_domain_endpoint
  value       = module.elasticsearch.domain_endpoint
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  type        = "String"
  overwrite   = true
}

resource "aws_ssm_parameter" "elasticsearch_kibana_endpoint" {
  count       = local.enabled ? 1 : 0
  name        = local.elasticsearch_kibana_endpoint
  value       = module.elasticsearch.kibana_endpoint
  description = "Domain-specific endpoint for Kibana without https scheme"
  type        = "String"
  overwrite   = true
}

module "elasticsearch_log_cleanup" {
  source  = "cloudposse/lambda-elasticsearch-cleanup/aws"
  version = "0.12.3"

  es_endpoint          = module.elasticsearch.domain_endpoint
  es_domain_arn        = module.elasticsearch.domain_arn
  es_security_group_id = module.elasticsearch.security_group_id
  vpc_id               = local.vpc_id
  subnet_ids           = local.vpc_private_subnet_ids

  context = module.this.context
}
