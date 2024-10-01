variable "postgres_rds_instance_name" {
  type        = string
  description = "Name of the application, e.g. `app` or `analytics`"
  default     = "postgres"
}

# Don't use `admin`
# Read more: <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html>
# ("MasterUsername admin cannot be used as it is a reserved word used by the engine")
variable "postgres_rds_instance_user" {
  type        = string
  description = "Postgres admin user name"
}

# Must be longer than 8 chars
# Read more: <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html>
# ("The parameter MasterUserPassword is not a valid password because it is shorter than 8 characters")
variable "postgres_rds_instance_password" {
  type        = string
  description = "Postgres password for the admin user"
  default     = ""
}

variable "postgres_rds_instance_db_name" {
  type        = string
  description = "Postgres database name"
}

# https://aws.amazon.com/rds/pricing/
variable "postgres_rds_instance_type" {
  type        = string
  default     = "db.t3.medium"
  description = "EC2 instance type for Postgres cluster"
}

variable "postgres_rds_instance_enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}

variable "postgres_rds_instance_iam_database_authentication_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
}

variable "postgres_rds_instance_cluster_dns_name" {
  type        = string
  description = "Name of the cluster CNAME record to create in the parent DNS zone specified by `zone_name`. If left empty, the name will be auto-assigned using the format `master.var.postgres_rds_instance_name`"
  default     = ""
}

variable "postgres_rds_instance_replicas_dns_name" {
  type        = string
  description = "Name of the reader endpoint CNAME record to create in the parent DNS zone specified by `zone_name`. If left empty, the name will be auto-assigned using the format `replicas.var.postgres_rds_instance_name`"
  default     = ""
}

variable "postgres_rds_instance_allocated_storage" {
  type        = number
  default     = 10
  description = "The allocated storage in GBs"
}

variable "postgres_rds_instance_kms_key_id" {
  type        = string
  default     = ""
  description = "KMS key ID used to encrypt SSM `SecureString` parameters"
}

variable "postgres_rds_instance_hostname" {
  type        = string
  default     = "db"
  description = "The DB host name created in Route53"
}

locals {
  postgres_rds_instance_admin_password = length(var.postgres_rds_instance_password) > 0 ? var.postgres_rds_instance_password : join("", random_string.postgres_rds_instance_password.*.result)
  kms_key_id                           = length(var.postgres_rds_instance_kms_key_id) > 0 ? var.postgres_rds_instance_kms_key_id : format("alias/%s-%s-chamber", var.namespace, var.stage)
}

resource "random_string" "postgres_rds_instance_password" {
  count            = var.postgres_rds_instance_enabled && length(var.postgres_rds_instance_password) == 0 ? 1 : 0
  length           = 26
  special          = true
  override_special = "!#%^&*()_<>?{}[]~=+"
}

module "rds_instance_postgres" {
  source               = "git::https://github.com/cloudposse/terraform-aws-rds.git?ref=tags/0.19.0"
  enabled              = var.postgres_rds_instance_enabled
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.postgres_rds_instance_name
  engine               = "postgres"
  instance_class       = var.postgres_rds_instance_type
  database_user        = var.postgres_rds_instance_user
  database_password    = local.postgres_rds_instance_admin_password
  database_name        = var.postgres_rds_instance_db_name
  database_port        = "5432"
  dns_zone_id          = local.zone_id
  vpc_id               = module.kops_metadata.vpc_id
  subnet_ids           = module.kops_metadata.private_subnet_ids
  multi_az             = true
  storage_type         = "gp2"
  allocated_storage    = var.postgres_rds_instance_allocated_storage
  storage_encrypted    = "true"
  engine_version       = "9.6"
  major_engine_version = "9.6"
  db_parameter_group   = "postgres9.6"
  publicly_accessible  = false
  host_name            = var.postgres_rds_instance_hostname
}

data "aws_kms_key" "chamber_kms_key" {
  count  = var.postgres_rds_instance_enabled ? 1 : 0
  key_id = local.kms_key_id
}

resource "aws_ssm_parameter" "postgres_rds_instance_master_password" {
  count       = var.postgres_rds_instance_enabled ? 1 : 0
  name        = format(local.chamber_parameter_format, local.chamber_service, "sentry_postgres_password")
  value       = local.postgres_rds_instance_admin_password
  description = "Postgres Password for the Sentry DB user"
  type        = "SecureString"
  key_id      = join("", data.aws_kms_key.chamber_kms_key.*.id)
  overwrite   = true
}
