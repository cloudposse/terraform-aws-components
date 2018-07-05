variable "relay_email" {
  description = "Email that used to relay from"
}

variable "forward_emails" {
  type = "map"

  default = {
    "source" = ["destination"]
  }

  description = "Emails forward map"
}
