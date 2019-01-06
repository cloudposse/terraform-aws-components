
## Troubleshooting

### Problem

```
aws_security_group.default: Error authorizing security group ingress rules: InvalidGroup.NotFound: You have specified two resources that belong to different networks.
```

### Answer 

Ensure that the VPC peering with the Kops cluster has been setup.
