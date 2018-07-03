variable "gateway_email" {}

variable "emails" {
  type = "map"

  default = {
    "source" = ["destination"]
  }

  description = "Emails forward map"
}
