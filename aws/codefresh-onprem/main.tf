terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `eg` or `cp`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "region" {
  type        = "string"
  description = "AWS region"
}

variable "zone_name" {
  type        = "string"
  description = "DNS zone name"
}

variable "acm_enabled" {
  description = "Set to false to prevent the acm module from creating any resources"
  default     = "true"
}

variable "acm_primary_domain" {
  description = "A domain name for which the certificate should be issued"
}

variable "acm_san_domains" {
  type        = "list"
  default     = []
  description = "A list of domains that should be SANs in the issued certificate"
}

variable "acm_zone_name" {
  type        = "string"
  default     = ""
  description = "The name of the desired Route53 Hosted Zone"
}

variable "redis_cluster_enabled" {
  type        = "string"
  default     = "false"
  description = "Set to false to prevent the module from creating any resources"
}

variable "postgres_cluster_enabled" {
  type        = "string"
  default     = "false"
  description = "Set to false to prevent the module from creating any resources"
}

variable "documentdb_cluster_enabled" {
  description = "Set to false to prevent the module from creating DocumentDB cluster"
  default     = "true"
}

variable "documentdb_instance_class" {
  type        = "string"
  default     = "db.r4.large"
  description = "The instance class to use. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html#db-instance-class-specs"
}

variable "documentdb_cluster_size" {
  type        = "string"
  default     = "3"
  description = "Number of DocumentDB instances to create in the cluster"
}

variable "documentdb_port" {
  type        = "string"
  default     = "27017"
  description = "DocumentDB port"
}

variable "documentdb_master_username" {
  type        = "string"
  default     = ""
  description = "Username for the master DocumentDB user. If left empty, will be generated automatically"
}

variable "documentdb_master_password" {
  type        = "string"
  default     = ""
  description = "Password for the master DocumentDB user. If left empty, will be generated automatically. Note that this may show up in logs, and it will be stored in the state file"
}

variable "documentdb_retention_period" {
  type        = "string"
  default     = "5"
  description = "Number of days to retain DocumentDB backups for"
}

variable "documentdb_preferred_backup_window" {
  type        = "string"
  default     = "07:00-09:00"
  description = "Daily time range during which the DocumentDB backups happen"
}

variable "documentdb_cluster_parameters" {
  type = "list"

  default = [
    {
      name  = "tls"
      value = "disabled"
    },
  ]

  description = "List of DocumentDB parameters to apply"
}

variable "documentdb_cluster_family" {
  type        = "string"
  default     = "docdb3.6"
  description = "The family of the DocumentDB cluster parameter group. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html"
}

variable "documentdb_engine" {
  type        = "string"
  default     = "docdb"
  description = "The name of the database engine to be used for DocumentDB cluster. Defaults to `docdb`. Valid values: `docdb`"
}

variable "documentdb_engine_version" {
  type        = "string"
  default     = ""
  description = "The version number of the DocumentDB database engine to use"
}

variable "documentdb_storage_encrypted" {
  description = "Specifies whether the DocumentDB cluster is encrypted"
  default     = "true"
}

variable "documentdb_skip_final_snapshot" {
  description = "Determines whether a final DocumentDB snapshot is created before the cluster is deleted"
  default     = "true"
}

variable "documentdb_apply_immediately" {
  description = "Specifies whether any DocumentDB cluster modifications are applied immediately, or during the next maintenance window"
  default     = "true"
}

variable "documentdb_enabled_cloudwatch_logs_exports" {
  type        = "list"
  description = "List of DocumentDB log types to export to CloudWatch. The following log types are supported: audit, error, general, slowquery"
  default     = []
}

variable "documentdb_chamber_parameters_mapping" {
  type = "map"

  default = {
    documentdb_connection_uri = "MONGODB_URI"
  }

  description = "Allow to specify keys names for chamber to store values"
}

data "terraform_remote_state" "backing_services" {
  backend = "s3"

  config {
    bucket = "${var.namespace}-${var.stage}-terraform-state"
    key    = "backing-services/terraform.tfstate"
  }
}

module "codefresh_enterprise_backing_services" {
  source          = "git::https://github.com/cloudposse/terraform-aws-codefresh-backing-services.git?ref=tags/0.8.0"
  namespace       = "${var.namespace}"
  stage           = "${var.stage}"
  vpc_id          = "${data.terraform_remote_state.backing_services.vpc_id}"
  subnet_ids      = ["${data.terraform_remote_state.backing_services.private_subnet_ids}"]
  security_groups = ["${module.kops_metadata.nodes_security_group_id}"]
  zone_name       = "${var.zone_name}"
  chamber_service = "codefresh"

  acm_enabled        = "${var.acm_enabled}"
  acm_primary_domain = "${var.acm_primary_domain}"
  acm_san_domains    = ["${var.acm_san_domains}"]

  redis_cluster_enabled = "${var.redis_cluster_enabled}"

  postgres_cluster_enabled = "${var.postgres_cluster_enabled}"

  # DocumentDB
  documentdb_cluster_enabled                 = "${var.documentdb_cluster_enabled}"
  documentdb_instance_class                  = "${var.documentdb_instance_class}"
  documentdb_cluster_size                    = "${var.documentdb_cluster_size}"
  documentdb_port                            = "${var.documentdb_port}"
  documentdb_master_username                 = "${var.documentdb_master_username}"
  documentdb_master_password                 = "${var.documentdb_master_password}"
  documentdb_retention_period                = "${var.documentdb_retention_period}"
  documentdb_preferred_backup_window         = "${var.documentdb_preferred_backup_window}"
  documentdb_cluster_parameters              = ["${var.documentdb_cluster_parameters}"]
  documentdb_cluster_family                  = "${var.documentdb_cluster_family}"
  documentdb_engine                          = "${var.documentdb_engine}"
  documentdb_engine_version                  = "${var.documentdb_engine_version}"
  documentdb_storage_encrypted               = "${var.documentdb_storage_encrypted}"
  documentdb_skip_final_snapshot             = "${var.documentdb_skip_final_snapshot}"
  documentdb_apply_immediately               = "${var.documentdb_apply_immediately}"
  documentdb_enabled_cloudwatch_logs_exports = ["${var.documentdb_enabled_cloudwatch_logs_exports}"]
  documentdb_chamber_parameters_mapping      = "${var.documentdb_chamber_parameters_mapping}"
}

output "elasticache_redis_id" {
  value       = "${module.codefresh_enterprise_backing_services.elasticache_redis_id}"
  description = "Elasticache Redis cluster ID"
}

output "elasticache_redis_security_group_id" {
  value       = "${module.codefresh_enterprise_backing_services.elasticache_redis_security_group_id}"
  description = "Elasticache Redis security group ID"
}

output "elasticache_redis_host" {
  value       = "${module.codefresh_enterprise_backing_services.elasticache_redis_host}"
  description = "Elasticache Redis host"
}

output "aurora_postgres_database_name" {
  value       = "${module.codefresh_enterprise_backing_services.aurora_postgres_database_name}"
  description = "Aurora Postgres Database name"
}

output "aurora_postgres_master_username" {
  value       = "${module.codefresh_enterprise_backing_services.aurora_postgres_master_username}"
  description = "Aurora Postgres Username for the master DB user"
}

output "aurora_postgres_master_hostname" {
  value       = "${module.codefresh_enterprise_backing_services.aurora_postgres_master_hostname}"
  description = "Aurora Postgres DB Master hostname"
}

output "aurora_postgres_replicas_hostname" {
  value       = "${module.codefresh_enterprise_backing_services.aurora_postgres_replicas_hostname}"
  description = "Aurora Postgres Replicas hostname"
}

output "aurora_postgres_cluster_name" {
  value       = "${module.codefresh_enterprise_backing_services.aurora_postgres_cluster_name}"
  description = "Aurora Postgres Cluster Identifier"
}

output "s3_user_name" {
  value       = "${module.codefresh_enterprise_backing_services.s3_user_name}"
  description = "Normalized IAM user name"
}

output "s3_user_arn" {
  value       = "${module.codefresh_enterprise_backing_services.s3_user_arn}"
  description = "The ARN assigned by AWS for the user"
}

output "s3_user_unique_id" {
  value       = "${module.codefresh_enterprise_backing_services.s3_user_unique_id}"
  description = "The user unique ID assigned by AWS"
}

output "s3_access_key_id" {
  sensitive   = true
  value       = "${module.codefresh_enterprise_backing_services.s3_access_key_id}"
  description = "The access key ID"
}

output "s3_secret_access_key" {
  sensitive   = true
  value       = "${module.codefresh_enterprise_backing_services.s3_secret_access_key}"
  description = "The secret access key. This will be written to the state file in plain-text"
}

output "s3_bucket_arn" {
  value       = "${module.codefresh_enterprise_backing_services.s3_bucket_arn}"
  description = "The s3 bucket ARN"
}

output "backup_s3_user_name" {
  value       = "${module.codefresh_enterprise_backing_services.backup_s3_user_name}"
  description = "Normalized IAM user name"
}

output "backup_s3_user_arn" {
  value       = "${module.codefresh_enterprise_backing_services.backup_s3_user_arn}"
  description = "The ARN assigned by AWS for the user"
}

output "backup_s3_user_unique_id" {
  value       = "${module.codefresh_enterprise_backing_services.backup_s3_user_unique_id}"
  description = "The user unique ID assigned by AWS"
}

output "backup_s3_access_key_id" {
  sensitive   = true
  value       = "${module.codefresh_enterprise_backing_services.backup_s3_access_key_id}"
  description = "The access key ID"
}

output "backup_s3_secret_access_key" {
  sensitive   = true
  value       = "${module.codefresh_enterprise_backing_services.backup_s3_secret_access_key}"
  description = "The secret access key. This will be written to the state file in plain-text"
}

output "backup_s3_bucket_arn" {
  value       = "${module.codefresh_enterprise_backing_services.backup_s3_bucket_arn}"
  description = "The backup_s3 bucket ARN"
}

output "acm_arn" {
  value       = "${module.codefresh_enterprise_backing_services.acm_arn}"
  description = "The ARN of the certificate"
}

output "acm_domain_validation_options" {
  value       = "${module.codefresh_enterprise_backing_services.acm_domain_validation_options}"
  description = "CNAME records that are added to the DNS zone to complete certificate validation"
}

output "documentdb_master_username" {
  value       = "${module.codefresh_enterprise_backing_services.documentdb_master_username}"
  description = "DocumentDB Username for the master DB user"
}

output "documentdb_cluster_name" {
  value       = "${module.codefresh_enterprise_backing_services.documentdb_cluster_name}"
  description = "DocumentDB Cluster Identifier"
}

output "documentdb_arn" {
  value       = "${module.codefresh_enterprise_backing_services.documentdb_arn}"
  description = "Amazon Resource Name (ARN) of the DocumentDB cluster"
}

output "documentdb_endpoint" {
  value       = "${module.codefresh_enterprise_backing_services.documentdb_endpoint}"
  description = "Endpoint of the DocumentDB cluster"
}

output "documentdb_reader_endpoint" {
  value       = "${module.codefresh_enterprise_backing_services.documentdb_reader_endpoint}"
  description = "Read-only endpoint of the DocumentDB cluster, automatically load-balanced across replicas"
}

output "documentdb_master_host" {
  value       = "${module.codefresh_enterprise_backing_services.documentdb_master_host}"
  description = "DocumentDB master hostname"
}

output "documentdb_replicas_host" {
  value       = "${module.codefresh_enterprise_backing_services.documentdb_replicas_host}"
  description = "DocumentDB replicas hostname"
}
