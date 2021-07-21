enabled = false

name = "zscaler"

# Cheapest instance that satisfies DenyInstancesWithoutEncryptionInTransit SCP (see: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/data-protection.html#encryption-transit)
instance_type = "m5n.large"
