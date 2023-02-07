variable "relay_email" {
  description = "Sender email address"
}

variable "forward_emails" {
  type = map(string)

  default = {
    "ops@example.com" = ["example@gmail.com"]
  }

  description = "Map of lists containing forwarding emails"
}
