## PR [#821](https://github.com/cloudposse/terraform-aws-components/pull/821)

### Update IAM Policy and Change How it is Managed

The ALB controller needs a lot of permissions and has a complex IAM policy. For this reason, the project releases a
complete JSON policy document that is updated as needed.

In this release:

1. We have updated the policy to the one distributed with version 2.6.0 of the ALB controller. This fixes an issue where
   the controller was not able to create the service-linked role for the Elastic Load Balancing service.
2. To ease maintenance, we have moved the policy document to a separate file, `distributed-iam-policy.tf` and made it
   easy to update or override.

#### Gov Cloud and China Regions

Actually, the project releases 3 policy documents, one for each of the three AWS partitions: `aws`, `aws-cn`, and
`aws-us-gov`. For simplicity, this module only uses the `aws` partition policy. If you are in another partition, you can
create a `distributed-iam-policy_override.tf` file in your directory and override the
`overridable_distributed_iam_policy` local variable with the policy document for your partition.
