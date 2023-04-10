variable "region" {
  type        = string
  description = "AWS Region."
}

variable "msk_cluster_component" {
  type        = string
  description = "Name of the cluster component to create topics"
}

variable "kafka_topics" {
  type        = map(any)
  description = ""
  default     = {}
}
