variable "region" {
  type        = string
  description = "AWS Region"
}

variable "service_linked_roles" {
  type = map(object({
    aws_service_name = string
    description      = string
  }))
  description = "Service-Linked roles config"
}
