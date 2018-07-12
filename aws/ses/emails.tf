variable "relay_email" {
  description = "Email that used to relay from"
}

variable "forward_emails" {
  type = "map"

  default = {
    "ops@example.com" = ["example@gmail.com"]
  }

  description = "Emails forward map"
}
