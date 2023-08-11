## Upgrading to `v1.250.0`

Components PR [#795](https://github.com/cloudposse/terraform-aws-components/pull/723)

### Removed `identity` roles from cluster RBAC (`aws-auth` ConfigMap)

Previously, this module added `identity` roles configured by the `aws_teams_rbac`
input to the `aws-auth` ConfigMap. This never worked, and so now `aws_teams_rbac`
is ignored. When upgrading, you may see these roles being removed from the `aws-auth`:
this is expected and harmless.

### Better support for Manged Node Group Block Device Specifications

Previously, this module only supported specifying the disk size and encryption state
for the root volume of Managed Node Groups. Now, the full set of block device
specifications is supported, including the ability to specify the device name.
This is particularly important when using BottleRocket, which uses a very small
root volume for storing the OS and configuration, and exposes a second volume
(`/dev/xvdb`) for storing data.

#### Block Device Migration

Almost all of the attributes of `node_groups` and `node_group_defaults` are now
optional. This means you can remove from your configuration any attributes that
previously you were setting to `null`.

The `disk_size` and `disk_encryption_enabled` attributes are deprecated. They
only apply to `/dev/xvda`, and only provision a `gp2` volume. In order to
provide backwards compatibility, they are still supported, and, when specified,
cause the new `block_device_map` attribute to be ignored.

The new `block_device_map` attribute is a map of objects. The keys are the names
of block devices, and the values are objects with the attributes from the Terraform
[launch_template.block-devices](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#block-devices) resource.

Note that the new default, when none of `block_device_map`, `disk_size`, or
`disk_encryption_enabled` are specified, is to provision a 20GB `gp3` volume
for `/dev/xvda`, with encryption enabled. This is a change from the previous
default, which provisioned a `gp2` volume instead.

### Support for EFS add-on

This module now supports the EFS CSI driver add-on, in very much the same way
as it supports the EBS CSI driver add-on. The only difference is that the
EFS CSI driver add-on requires that you first provision an EFS file system.

#### Migration from `eks/efs-controller` to EFS CSI Driver Add-On

If you are currently using the `eks/efs-controller` module, you can migrate
to the EFS CSI Driver Add-On by following these steps:

1. Remove or scale to zero Pods any Deployments using the EFS file system.
2. Remove (`terraform destroy`) the `eks/efs-controller` module from your
   cluster. This will also remove the `efs-sc` StorageClass.
3. Use the [eks/storage-class](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/eks/storage-class)
   module to create a replacement EFS StorageClass `efs-sc`. This component is new and you may need to add it to your cluster.
4. Deploy the EFS CSI Driver Add-On by adding `aws-efs-csi-driver` to the `addons` map (see [README](./README.md)).
5. Restore the Deployments you modified in step 1.

### More options for specifying Availability Zones

Previously, this module required you to specify the Availability Zones for the
cluster in one of two ways:

1. Explicitly, by providing the full AZ names via the `availability_zones` input
2. Implicitly, via private subnets in the VPC

Option 2 is still usually the best way, but now you have additional options:

- You can specify the Availability Zones via the `availability_zones` input
  without specifying the full AZ names. You can just specify the suffixes of
  the AZ names, and the module will find the full names for you, using the
  current region. This is useful for using the same configuration in multiple regions.
- You can specify Availability Zone IDs via the `availability_zone_ids` input.
  This is useful to ensure that clusters in different accounts are nevertheless
  deployed to the same Availability Zones. As with the `availability_zones` input,
  you can specify the suffixes of the AZ IDs, and the module will find the full
  IDs for you, using the current region.

### Support for Karpenter Instance Profile

Previously, this module created an IAM Role for instances launched by Karpenter,
but did not create the corresponding Instance Profile, which was instead created by
the `eks/karpenter` component. This can cause problems if you delete and recreate the cluster,
so for new clusters, this module can now create the Instance Profile as well.

Because this is disruptive to existing clusters, this is not enabled by default.
To enable it, set the `legacy_do_not_create_karpenter_instance_profile` input to `false`,
and also set the `eks/karpenter` input `legacy_create_karpenter_instance_profile` to `false`.

## Components PR [#723](https://github.com/cloudposse/terraform-aws-components/pull/723)


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
