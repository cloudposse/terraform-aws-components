variable "region" {
  type        = string
  description = "AWS Region"
}

variable "create_s3_bucket" {
  type        = bool
  description = "Enabling or disabling the creation of an S3 bucket for AWS MWAA"
  default     = true
}

variable "create_iam_role" {
  type        = bool
  description = "Enabling or disabling the creation of a default IAM Role for AWS MWAA"
  default     = true
}

variable "dag_s3_path" {
  type        = string
  description = "Path to dags in s3"
  default     = "dags"
}

variable "webserver_access_mode" {
  type        = string
  description = "Specifies whether the webserver is accessible over the internet, PUBLIC_ONLY or PRIVATE_ONLY"
  default     = "PRIVATE_ONLY"
}

variable "environment_class" {
  type        = string
  description = "Environment class for the cluster. Possible options are mw1.small, mw1.medium, mw1.large."
  default     = "mw1.small"
}

variable "max_workers" {
  type        = number
  description = "The maximum number of workers that can be automatically scaled up. Value need to be between 1 and 25."
  default     = 10
}

variable "min_workers" {
  type        = number
  description = "The minimum number of workers that you want to run in your environment."
  default     = 1
}

variable "airflow_version" {
  type        = string
  description = "Airflow version of the MWAA environment, will be set by default to the latest version that MWAA supports."
  default     = ""
}

variable "plugins_s3_object_version" {
  type        = string
  description = "The plugins.zip file version you want to use."
  default     = null
}

variable "plugins_s3_path" {
  type        = string
  description = "The relative path to the plugins.zip file on your Amazon S3 storage bucket. For example, plugins.zip. If a relative path is provided in the request, then plugins_s3_object_version is required"
  default     = null
}

variable "requirements_s3_object_version" {
  type        = string
  description = "The requirements.txt file version you"
  default     = null
}

variable "requirements_s3_path" {
  type        = string
  description = "The relative path to the requirements.txt file on your Amazon S3 storage bucket. For example, requirements.txt. If a relative path is provided in the request, then requirements_s3_object_version is required"
  default     = null
}

variable "weekly_maintenance_window_start" {
  type        = string
  description = "Specifies the start date for the weekly maintenance window."
  default     = null
}

variable "dag_processing_logs_enabled" {
  type        = bool
  description = "Enabling or disabling the collection of logs for processing DAGs"
  default     = false
}

variable "dag_processing_logs_level" {
  type        = string
  description = "DAG processing logging level. Valid values: CRITICAL, ERROR, WARNING, INFO, DEBUG"
  default     = "INFO"
}

variable "scheduler_logs_enabled" {
  type        = bool
  description = "Enabling or disabling the collection of logs for the schedulers"
  default     = false
}

variable "scheduler_logs_level" {
  type        = string
  description = "Schedulers logging level. Valid values: CRITICAL, ERROR, WARNING, INFO, DEBUG"
  default     = "INFO"
}

variable "task_logs_enabled" {
  type        = bool
  description = "Enabling or disabling the collection of logs for DAG tasks"
  default     = false
}

variable "task_logs_level" {
  type        = string
  description = "DAG tasks logging level. Valid values: CRITICAL, ERROR, WARNING, INFO, DEBUG"
  default     = "INFO"
}

variable "webserver_logs_enabled" {
  type        = bool
  description = "Enabling or disabling the collection of logs for the webservers"
  default     = false
}

variable "webserver_logs_level" {
  type        = string
  description = "Webserver logging level. Valid values: CRITICAL, ERROR, WARNING, INFO, DEBUG"
  default     = "INFO"
}

variable "worker_logs_enabled" {
  type        = bool
  description = "Enabling or disabling the collection of logs for the workers"
  default     = false
}

variable "worker_logs_level" {
  type        = string
  description = "Workers logging level. Valid values: CRITICAL, ERROR, WARNING, INFO, DEBUG"
  default     = "INFO"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the MWAA cluster"
}

variable "allow_ingress_from_vpc_stages" {
  type        = list(string)
  default     = ["auto", "corp"]
  description = "List of stages to pull VPC ingress cidr and add to security group"
}

variable "airflow_configuration_options" {
  description = "The Airflow override options"
  type        = map(string)
  default     = {}
}

variable "allowed_web_access_role_arns" {
  type        = list(string)
  default     = []
  description = "List of role ARNs to allow airflow web access"
}

variable "allowed_web_access_role_names" {
  type        = list(string)
  default     = []
  description = "List of role names to allow airflow web access"
}

variable "source_bucket_arn" {
  type        = string
  description = "Set this to the Amazon Resource Name (ARN) of your Amazon S3 storage bucket."
  default     = null
}

variable "allowed_security_groups" {
  type        = list(string)
  description = "A list of IDs of Security Groups to allow access to the security group created by this module."
  default     = []
}

variable "execution_role_arn" {
  type        = string
  default     = ""
  description = "If `create_iam_role` is `false` then set this to the target MWAA execution role"
}
