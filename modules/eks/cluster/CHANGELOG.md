## Components PR [#723](https://github.com/cloudposse/terraform-aws-components/pull/723/files)


### Improved support for EKS Add-Ons

This has improved support for EKS Add-Ons.

##### Configuration and Timeouts

The `addons` input now accepts a `configuration_values` input to allow you
to configure the add-ons, and various timeout inputs to allow you to fine-tune
the timeouts for the add-ons.

##### Automatic IAM Role Creation

If you enable `aws-ebs-csi-driver` or `vpc-cni` add-ons, the module will
automatically create the required Service Account IAM Role and attach it to
the add-on.

##### Add-Ons can be deployed to Fargate

If you are using Karpenter and not provisioning any nodes with this module,
the `coredns` and `aws-ebs-csi-driver` add-ons can be deployed to Fargate.
(They must be able to run somewhere in the cluster or else the deployment
will fail.)

To cause the add-ons to be deployed to Fargate, set the `deploy_addons_to_fargate`
input to `true`.

**Note about CoreDNS**: If you want to deploy CoreDNS to Fargate, as of this
writing you must set the `configuration_values` input for CoreDNS to
`'{"computeType": "Fargate"}'`. If you want to deploy CoreDNS to EC2 instances,
you must NOT include the `computeType` configuration value.

### Availability Zones implied by Private Subnets

You can now avoid specifying Availability Zones for the cluster anywhere.
If all of the possible Availability Zones inputs are empty, the module will
use the Availability Zones implied by the private subnets. That is, it will
deploy the cluster to all of the Availability Zones in which the VPC has
private subnets.

### Optional support for 1 Fargate Pod Execution Role per Cluster

Previously, this module created a separate Fargate Pod Execution Role for each
Fargate Profile it created. This is unnecessary, excessive, and can cause
problems due to name collisions, but is otherwise merely inefficient, so it is
not important to fix this on existiong, working clusters.
This update brings a feature that causes the module to create at
most 1 Fargate Pod Execution Role per cluster.

**This change is recommended for all NEW clusters, but only NEW clusters**.
Because it is a breaking change, it is not enabled by default. To enable it, set the
`legacy_fargate_1_role_per_profile_enabled` variable to `false`.

**WARNING**: If you enable this feature on an existing cluster, and that
cluster is using Karpenter, the update could destroy all of your existing
Karpenter-provisioned nodes. Depending on your Karpenter version, this
could leave you with stranded EC2 instances (still running, but not managed by
Karpenter or visible to the cluster) and an interruption of service, and
possibly other problems. If you are using Karpenter and want to enable this
feature, the safest way is to destroy the existing cluster and create a new
one with this feature enabled.
