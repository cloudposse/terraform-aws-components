variable "region" {
  type        = string
  description = "AWS Region"
}

variable "private_location_description" {
  type        = string
  description = "The description of the private location."
  default     = null
}

variable "containers" {
  type        = any
  description = "Feed inputs into container definition module"
  default     = {}
}

variable "task" {
  type        = any
  description = "Feed inputs into ecs_alb_service_task module"
  default     = {}
}

variable "alb_configuration" {
  type        = string
  description = "The configuration to use for the ALB, specifying which cluster alb configuration to use"
  default     = "default"
}
