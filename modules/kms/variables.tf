variable "region" {
  type        = string
  description = "AWS Region"
}

variable "alias" {
  type        = string
  description = "The display name of the alias. The name must start with the word alias followed by a forward slash. If not specified, the alias name will be auto-generated."
  default     = null
}

variable "description" {
  type        = string
  description = "The description for the KMS Key."
  default     = null
}

variable "deletion_window_in_days" {
  type        = number
  default     = 10
  description = "Duration in days after which the key is deleted after destruction of the resource"
}

variable "enable_key_rotation" {
  type        = bool
  default     = true
  description = "Specifies whether key rotation is enabled"
}

variable "key_usage" {
  type        = string
  default     = "ENCRYPT_DECRYPT"
  description = "Specifies the intended use of the key. Valid values: `ENCRYPT_DECRYPT` or `SIGN_VERIFY`."
}

variable "multi_region" {
  type        = bool
  default     = false
  description = "Indicates whether the KMS key is a multi-Region (true) or regional (false) key."
}

variable "customer_master_key_spec" {
  type        = string
  default     = "SYMMETRIC_DEFAULT"
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `ECC_NIST_P256`, `ECC_NIST_P384`, `ECC_NIST_P521`, or `ECC_SECG_P256K1`."
}

variable "allowed_roles" {
  type        = map(list(string))
  description = <<-EOT
    Map of account:[role, role...] specifying roles allowed to assume the role.
    Roles are symbolic names like `ops` or `terraform`. Use `*` as role for entire account.
    EOT
  default     = {}
}

variable "allowed_principal_arns" {
  type        = list(string)
  description = "List of AWS principal ARNs allowed to assume the role."
  default     = []
}
