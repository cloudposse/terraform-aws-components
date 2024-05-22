## Component PR [#]()

Components PR [#x](https://github.com/cloudposse/terraform-aws-components/pull/x)

### Affected components

- `elasticache-redis`

### Summary

We've introduce a new variable called `var.allow_ingress_from_this_vpc`. If set to `true`, all traffic from the VPC for
this account will be allowed. If set to `false`, it will not be included.

This changes the default behavior. Previously all traffic from the VPC for this account was allowed by default. If you
wish to maintain that behavior, set `var.allow_ingress_from_this_vpc` to `true`.

We have made this opinionated changed so that least access required is provisioned by default.
