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

variable "zone_name" {
  type        = "string"
  default     = ""
  description = "Domain name of DNS zone in which to add subdomain records, optional, defaults to cluster_name"
}

variable "kops_cluster_name" {
  type        = "string"
  description = "Kops cluster name (e.g. `us-east-1.prod.cloudposse.co` or `cluster-1.cloudposse.co`)"
}

variable "vpc_id" {
  type        = "string"
  default     = ""
  description = "VPC ID of the Kubernetes cluster (optional, will try to auto-detect by using `cluster_name` tag)"
}

variable "chamber_service" {
  default     = ""
  description = "`chamber` service name. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details"
}

variable "chamber_parameter_name" {
  default     = "/%s/%s"
  description = "`chamber` parameter name template"
}

variable "kms_key_id" {
  type        = "string"
  default     = ""
  description = "KMS key ID used to encrypt SSM SecureString parameters"
}

variable "overwrite_ssm_parameter" {
  type        = "string"
  default     = "true"
  description = "Whether to overwrite an existing SSM parameter"
}

variable "postgres_name" {
  type        = "string"
  description = "Name of the application, e.g. `app` or `analytics`"
  default     = "postgres"
}

# Don't use `admin`
# Read more: <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html>
# ("MasterUsername admin cannot be used as it is a reserved word used by the engine")
variable "postgres_admin_user" {
  type        = "string"
  description = "Postgres admin user name"
  default     = ""
}

# Must be longer than 8 chars
# Read more: <https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html>
# ("The parameter MasterUserPassword is not a valid password because it is shorter than 8 characters")
variable "postgres_admin_password" {
  type        = "string"
  description = "Postgres password for the admin user"
  default     = ""
}

variable "postgres_db_name" {
  type        = "string"
  description = "Postgres database name"
  default     = ""
}

# https://aws.amazon.com/rds/aurora/pricing
variable "postgres_instance_type" {
  type        = "string"
  default     = "db.r4.large"
  description = "EC2 instance type for Postgres cluster"
}

variable "postgres_cluster_size" {
  type        = "string"
  default     = "2"
  description = "Postgres cluster size"
}

variable "postgres_cluster_enabled" {
  type        = "string"
  default     = "true"
  description = "Set to false to prevent the module from creating any resources"
}

variable "postgres_iam_database_authentication_enabled" {
  type        = "string"
  default     = "false"
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
}

variable "postgres_cluster_dns_name" {
  type        = "string"
  description = "Name of the cluster CNAME record to create in the parent DNS zone specified by `zone_name`. If left empty, the name will be auto-asigned using the format `master.var.postgres_name`"
  default     = ""
}

variable "postgres_reader_dns_name" {
  type        = "string"
  description = "Name of the reader endpoint CNAME record to create in the parent DNS zone specified by `zone_name`. If left empty, the name will be auto-asigned using the format `replicas.var.postgres_name`"
  default     = ""
}
