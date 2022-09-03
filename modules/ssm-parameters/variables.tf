variable "region" {
  type        = string
  description = "AWS Region"
}

variable "sops_source_file" {
  type        = string
  description = "The relative path to the SOPS file which is consumed as the source for creating parameter resources."
}

variable "sops_source_key" {
  type        = string
  description = "The SOPS key to pull from the source file."
}

variable "kms_arn" {
  type        = string
  default     = ""
  description = "The ARN of a KMS key used to encrypt and decrypt SecretString values"
}

variable "params" {
  type = map(object({
    value       = string
    description = string
    overwrite   = bool
    type        = string
  }))
}
