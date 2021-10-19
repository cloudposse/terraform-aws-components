variable "autoscaling_group_name" {
  description = "The name of the Auto Scaling Group to create the lifecycle hook for."
  type        = string
}

variable "command" {
  description = "Command to run on EC2 instance shutdown."
  type        = string
}