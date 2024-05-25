#####
# The primary and current (v1beta API) controller policy is in the controller-policy.tf file.
#
# However, if you have workloads that were deployed under the v1alpha API, you need to also
# apply this controller-policy-v1alpha.tf policy to the Karpenter controller to give it permission
# to manage (an in particular, delete) those workloads, and give it permission to manage the
# EC2 Instance Profile possibly created by the EKS cluster component.
#
# This policy is not needed for workloads deployed under the v1beta API with the
# EC2 Instance Profile created by the Karpenter controller.
#
# This allows it to terminate instances and delete launch templates that are tagged with the
# v1alpha API tag "karpenter.sh/provisioner-name" and to manage the EC2 Instance Profile
# created by the EKS cluster component.
#
# WARNING: it is important that the SID values do not conflict with the SID values in the
# controller-policy.tf file, otherwise they will be overwritten.
#

locals {
  controller_policy_v1alpha_json = <<-EndOfPolicy
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Sid": "AllowScopedDeletionV1alpha",
              "Effect": "Allow",
              "Resource": [
                "arn:${local.aws_partition}:ec2:${var.region}:*:instance/*",
                "arn:${local.aws_partition}:ec2:${var.region}:*:launch-template/*"
              ],
              "Action": [
                "ec2:TerminateInstances",
                "ec2:DeleteLaunchTemplate"
              ],
              "Condition": {
                "StringEquals": {
                  "aws:ResourceTag/kubernetes.io/cluster/${local.eks_cluster_id}": "owned"
                },
                "StringLike": {
                  "aws:ResourceTag/karpenter.sh/provisioner-name": "*"
                }
              }
            },
            {
              "Sid": "AllowScopedInstanceProfileActionsV1alpha",
              "Effect": "Allow",
              "Resource": "*",
              "Action": [
                "iam:AddRoleToInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:DeleteInstanceProfile"
              ],
              "Condition": {
                "StringEquals": {
                  "aws:ResourceTag/kubernetes.io/cluster/${local.eks_cluster_id}": "owned",
                  "aws:ResourceTag/topology.kubernetes.io/region": "${var.region}"
                },
                "ArnEquals": {
                   "ec2:InstanceProfile": "${replace(local.karpenter_node_role_arn, "role", "instance-profile")}"
                }
              }
            }
          ]
        }
  EndOfPolicy
}
