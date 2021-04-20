# This file is included by default in terraform plans

family = "redis6.x"

ingress_cidr_blocks = []

egress_cidr_blocks = ["0.0.0.0/0"]

port = 6379

at_rest_encryption_enabled = true

transit_encryption_enabled = false

apply_immediately = true

automatic_failover_enabled = true

cloudwatch_metric_alarms_enabled = false
