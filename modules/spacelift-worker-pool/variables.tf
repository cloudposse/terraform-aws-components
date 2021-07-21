variable "region" {
  type        = string
  description = "AWS Region"
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type to use for workers"
  default     = "t3.micro"
}

variable "account_map_environment_name" {
  type        = string
  description = "The name of the environment where `account_map` is provisioned"
  default     = "gbl"
}

variable "account_map_stage_name" {
  type        = string
  description = "The name of the stage where `account_map` is provisioned"
  default     = "root"
}

variable "ecr_account_name" {
  type        = string
  description = "Name of the AWS account that contains the ECR infrastructure repo"
}

variable "ecr_repo_name" {
  type        = string
  description = "Name of the ECR repo containing the infrastructure image"
}

variable "spacelift_api_endpoint" {
  type        = string
  description = "The Spacelift API endpoint URL (e.g. https://example.app.spacelift.io)"
}

variable "spacelift_ami_id" {
  type        = string
  description = "AMI id of Spacelift worker pool image"
}

variable "spacelift_runner_image" {
  type        = string
  description = "Location of ECR image to use for Spacelift"
}
