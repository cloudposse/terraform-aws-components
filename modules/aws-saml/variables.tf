variable "region" {
  type        = string
  description = "AWS Region"
}

variable "saml_providers" {
  type        = map(string)
  description = "Map of provider names to XML data filenames"
}
