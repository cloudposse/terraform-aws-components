variable "region" {
  type        = string
  description = "AWS Region"
}

variable "endpoint_type" {
  type        = string
  description = "Type of endpoint. Valid values are `source`, `target`"
}

variable "engine_name" {
  type        = string
  description = "Type of engine for the endpoint. Valid values are `aurora`, `aurora-postgresql`, `azuredb`, `db2`, `docdb`, `dynamodb`, `elasticsearch`, `kafka`, `kinesis`, `mariadb`, `mongodb`, `mysql`, `opensearch`, `oracle`, `postgres`, `redshift`, `s3`, `sqlserver`, `sybase`"
}

variable "kms_key_arn" {
  type        = string
  description = "(Required when engine_name is `mongodb`, optional otherwise). ARN for the KMS key that will be used to encrypt the connection parameters. If you do not specify a value for `kms_key_arn`, then AWS DMS will use your default encryption key"
  default     = null
}

variable "certificate_arn" {
  type        = string
  description = "Certificate ARN"
  default     = null
}

variable "database_name" {
  type        = string
  description = "Name of the endpoint database"
  default     = null
}

variable "password" {
  type        = string
  description = "Password to be used to login to the endpoint database"
  default     = ""
}

variable "port" {
  type        = number
  description = "Port used by the endpoint database"
  default     = null
}

variable "extra_connection_attributes" {
  type        = string
  description = "Additional attributes associated with the connection to the source database"
  default     = ""
}

variable "secrets_manager_access_role_arn" {
  type        = string
  description = "ARN of the IAM role that specifies AWS DMS as the trusted entity and has the required permissions to access the value in SecretsManagerSecret"
  default     = null
}

variable "secrets_manager_arn" {
  type        = string
  description = "Full ARN, partial ARN, or friendly name of the SecretsManagerSecret that contains the endpoint connection details. Supported only for engine_name as aurora, aurora-postgresql, mariadb, mongodb, mysql, oracle, postgres, redshift or sqlserver"
  default     = null
}

variable "server_name" {
  type        = string
  description = "Host name of the database server"
  default     = null
}

variable "service_access_role" {
  type        = string
  description = "ARN used by the service access IAM role for DynamoDB endpoints"
  default     = null
}

variable "ssl_mode" {
  type        = string
  description = "The SSL mode to use for the connection. Can be one of `none`, `require`, `verify-ca`, `verify-full`"
  default     = "none"
}

variable "username" {
  type        = string
  description = "User name to be used to login to the endpoint database"
  default     = ""
}

variable "elasticsearch_settings" {
  type        = map(any)
  description = "Configuration block for OpenSearch settings"
  default     = null
}

variable "kafka_settings" {
  type        = map(any)
  description = "Configuration block for Kafka settings"
  default     = null
}

variable "kinesis_settings" {
  type        = map(any)
  description = "Configuration block for Kinesis settings"
  default     = null
}

variable "mongodb_settings" {
  type        = map(any)
  description = "Configuration block for MongoDB settings"
  default     = null
}

variable "redshift_settings" {
  type        = map(any)
  description = "Configuration block for Redshift settings"
  default     = null
}

variable "s3_settings" {
  type        = map(any)
  description = "Configuration block for S3 settings"
  default     = null
}

variable "username_path" {
  type        = string
  description = "If set, the path in AWS SSM Parameter Store to fetch the username for the DMS admin user"
  default     = ""
}

variable "password_path" {
  type        = string
  description = "If set, the path in AWS SSM Parameter Store to fetch the password for the DMS admin user"
  default     = ""
}
