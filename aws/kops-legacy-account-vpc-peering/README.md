# kops-legacy-account-vpc-peering

Terraform module to provision VPC peering between a `kops` VPC and a VPC from a legacy AWS account.

From the legacy AWS account, which will be the accepter of the VPC peering connection, the following values are required:

- `legacy_account_assume_role_arn` - Legacy account assume role ARN
- `legacy_account_region` -  Legacy account AWS region (e.g. `us-west-2`)
- `legacy_account_vpc_id` - Legacy account VPC ID (the VPC which will accept peering connection from the `kops` VPC). __NOTE:__ the CIDR blocks of the `kops` VPC and the legacy account VPC must not overlap

The `legacy_account_assume_role_arn` IAM Role should have the following Trust Policy:

```js
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<KOPS AWS Account ID>:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
```

and the following IAM Policy attached to it:

__NOTE:__ the policy specifies the minimum permission set required to create (with `terraform plan/apply`) and delete (with `terraform destroy`) all the VPC peering connection resources in the accepter (legacy) AWS account

```js
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateRoute",
        "ec2:DeleteRoute"
      ],
      "Resource": "arn:aws:ec2:*:<Legacy AWS Account ID>:route-table/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeVpcPeeringConnections",
        "ec2:DescribeVpcs",
        "ec2:ModifyVpcPeeringConnectionOptions",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcAttribute",
        "ec2:DescribeRouteTables"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AcceptVpcPeeringConnection",
        "ec2:DeleteVpcPeeringConnection",
        "ec2:CreateVpcPeeringConnection",
        "ec2:RejectVpcPeeringConnection"
      ],
      "Resource": [
        "arn:aws:ec2:*:<Legacy AWS Account ID>:vpc-peering-connection/*",
        "arn:aws:ec2:*:<Legacy AWS Account ID>:vpc/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteTags",
        "ec2:CreateTags"
      ],
      "Resource": "arn:aws:ec2:*:<Legacy AWS Account ID>:vpc-peering-connection/*"
    }
  ]
}
```

For more information on IAM policies and permissions for VPC peering, see [Creating and managing VPC peering connections](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_IAM.html#vpcpeeringiam).
