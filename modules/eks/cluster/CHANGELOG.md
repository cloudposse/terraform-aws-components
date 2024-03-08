## Components PR [#910](https://github.com/cloudposse/terraform-aws-components/pull/910)

Bug fix and updates to Changelog, no action required.

Fixed: Error about managed node group ARNs list being null, which could happen when adding a managed node group to an
existing cluster that never had one.

## Upgrading to `v1.303.0`

Components PR [#852](https://github.com/cloudposse/terraform-aws-components/pull/852)

This is a bug fix and feature enhancement update. No action is necessary to upgrade. However, with the new features and
new recommendations, you may want to change your configuration.

## Recommended (optional) changes

Previously, we recommended deploying Karpenter to Fargate and not provisioning any nodes. However, this causes issues
with add-ons that require compute power to fully initialize, such as `coredns`, and it can reduce the cluster to a
single node, removing the high availability that comes from having a node per Availability Zone and replicas of pods
spread across those nodes.

As a result, we now recommend deploying a minimal node group with a single instance (currently recommended to be a
`c6a.large`) in each of 3 Availability Zones. This will provide the compute power needed to initialize add-ons, and will
provide high availability for the cluster. As a bonus, it will also remove the need to deploy Karpenter to Fargate.

**NOTE about instance type**: The `c6a.large` instance type is relatively new. If you have deployed an old version of
our ServiceControlPolicy `DenyEC2NonNitroInstances`, `DenyNonNitroInstances` (obsolete, replaced by
`DenyEC2NonNitroInstances`), and/or `DenyEC2InstancesWithoutEncryptionInTransit`, you will want to update them to
v0.12.0 or choose a difference instance type.

### Migration procedure

To perform the recommended migration, follow these steps:

#### 1. Deploy a minimal node group, move addons to it

Change your `eks/cluster` configuration to set `deploy_addons_to_fargate: false`.

Add the following to your `eks/cluster` configuration, but copy the block device name, volume size, and volume type from
your existing Karpenter provisioner configuration. Also select the correct `ami_type` according to the `ami_family` in
your Karpenter provisioner configuration.

```yaml
node_groups:
  # will create 1 node group for each item in map
  # Provision a minimal static node group for add-ons and redundant replicas
  main:
    # EKS AMI version to use, e.g. "1.16.13-20200821" (no "v").
    ami_release_version: null
    # Type of Amazon Machine Image (AMI) associated with the EKS Node Group
    # Typically AL2_x86_64 or BOTTLEROCKET_x86_64
    ami_type: BOTTLEROCKET_x86_64
    # Additional name attributes (e.g. `1`) for the node group
    attributes: []
    # will create 1 auto scaling group in each specified availability zone
    # or all AZs with subnets if none are specified anywhere
    availability_zones: null
    # Whether to enable Node Group to scale its AutoScaling Group
    cluster_autoscaler_enabled: false
    # True (recommended) to create new node_groups before deleting old ones, avoiding a temporary outage
    create_before_destroy: true
    # Configure storage for the root block device for instances in the Auto Scaling Group
    # For Bottlerocket, use /dev/xvdb. For all others, use /dev/xvda.
    block_device_map:
      "/dev/xvdb":
        ebs:
          volume_size: 125 # in GiB
          volume_type: gp3
          encrypted: true
          delete_on_termination: true
    # Set of instance types associated with the EKS Node Group. Terraform will only perform drift detection if a configuration value is provided.
    instance_types:
      - c6a.large
    # Desired number of worker nodes when initially provisioned
    desired_group_size: 3
    max_group_size: 3
    min_group_size: 3
    resources_to_tag:
      - instance
      - volume
    tags: null
```

You do not need to apply the above changes yet, although you can if you want to. To reduce overhead, you can apply the
changes in the next step.

#### 2. Move Karpenter to the node group, remove legacy support

Delete the `fargate_profiles` section from your `eks/cluster` configuration, or at least remove the `karpenter` profile
from it. Disable legacy support by adding:

```yaml
legacy_fargate_1_role_per_profile_enabled: false
```

#### 2.a Optional: Move Karpenter instance profile to `eks/cluster` component

If you have the patience to manually import and remove a Terraform resource, you should move the Karpenter instance
profile to the `eks/cluster` component. This fixes an issue where the Karpenter instance profile could be broken by
certain sequences of Terraform operations. However, if you have multiple clusters to migrate, this can be tedious, and
the issue is not a serious one, so you may want to skip this step.

To do this, add the following to your `eks/cluster` configuration:

```yaml
legacy_do_not_create_karpenter_instance_profile: false
```

**BEFORE APPLYING CHANGES**: Run `atmos terraform plan` (with the appropriate arguments) to see the changes that will be
made. Among the resources to be created will be `aws_iam_instance_profile.default[0]`. Using the same arguments as
before, run `atmos`, but replace `plan` with `import 'aws_iam_instance_profile.default[0]' <profile-name>`, where
`<profile-name>` is the name of the profile the plan indicated it would create. It will be something like
`<cluster-name>-karpenter`.

**NOTE**: If you perform this step, you must also perform 3.a below.

#### 2.b Apply the changes

Apply the changes with `atmos terraform apply`.

#### 3. Upgrade Karpenter

Upgrade the `eks/karpenter` component to the latest version. Follow the upgrade instructions to enable the new
`karpenter-crd` chart by setting `crd_chart_enabled: true`.

Upgrade to at least Karpenter v0.30.0, which is the first version to support factoring in the existing node group when
determining the number of nodes to provision. This will prevent Karpenter from provisioning nodes when they are not
needed because the existing node group already has enough capacity. Be careful about upgrading to v0.32.0 or later, as
that version introduces significant breaking changes. We recommend updating to v0.31.2 or later versions of v0.31.x, but
not v0.32.0 or later, as a first step. This provides a safe (revertible) upgrade path to v0.32.0 or later.

#### 3.a Finish Move of Karpenter instance profile to `eks/cluster` component

If you performed step 2.a above, you must also perform this step. If you did not perform step 2.a, you must NOT perform
this step.

In the `eks/karpenter` stack, set `legacy_create_karpenter_instance_profile: false`.

**BEFORE APPLYING CHANGES**: Remove the Karpenter instance profile from the Terraform state, since it is now managed by
the `eks/cluster` component, or else Terraform will delete it.

```shell
atmos terraform state eks/karpenter rm 'aws_iam_instance_profile.default[0]' -s=<stack-name>
```

#### 3.b Apply the changes

Apply the changes with `atmos terraform apply`.

## Changes included in `v1.303.0`

This is a bug fix and feature enhancement update. No action is necessary to upgrade.

### Bug Fixes

- Timeouts for Add-Ons are now honored (they were being ignored)
- If you supply a service account role ARN for an Add-On, it will be used, and no new role will be created. Previously
  it was used, but the component created a new role anyway.
- The EKS EFS controller add-on cannot be deployed to Fargate, and enabling it along with `deploy_addons_to_fargate`
  will no longer attempt to deploy EFS to Fargate. Note that this means to use the EFS Add-On, you must create a managed
  node group. Track the status of this feature with
  [this issue](https://github.com/kubernetes-sigs/aws-efs-csi-driver/issues/1100).
- If you are using an old VPC component that does not supply `az_private_subnets_map`, this module will now use the
  older the `private_subnet_ids` output.

### Add-Ons have `enabled` option

The EKS Add-Ons now have an optional "enabled" flag (defaults to `true`) so that you can selectively disable them in a
stack where the inherited configuration has them enabled.

## Upgrading to `v1.270.0`

Components PR [#795](https://github.com/cloudposse/terraform-aws-components/pull/795)

### Removed `identity` roles from cluster RBAC (`aws-auth` ConfigMap)

Previously, this module added `identity` roles configured by the `aws_teams_rbac` input to the `aws-auth` ConfigMap.
This never worked, and so now `aws_teams_rbac` is ignored. When upgrading, you may see these roles being removed from
the `aws-auth`: this is expected and harmless.

### Better support for Manged Node Group Block Device Specifications

Previously, this module only supported specifying the disk size and encryption state for the root volume of Managed Node
Groups. Now, the full set of block device specifications is supported, including the ability to specify the device name.
This is particularly important when using BottleRocket, which uses a very small root volume for storing the OS and
configuration, and exposes a second volume (`/dev/xvdb`) for storing data.

#### Block Device Migration

Almost all of the attributes of `node_groups` and `node_group_defaults` are now optional. This means you can remove from
your configuration any attributes that previously you were setting to `null`.

The `disk_size` and `disk_encryption_enabled` attributes are deprecated. They only apply to `/dev/xvda`, and only
provision a `gp2` volume. In order to provide backwards compatibility, they are still supported, and, when specified,
cause the new `block_device_map` attribute to be ignored.

The new `block_device_map` attribute is a map of objects. The keys are the names of block devices, and the values are
objects with the attributes from the Terraform
[launch_template.block-devices](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#block-devices)
resource.

Note that the new default, when none of `block_device_map`, `disk_size`, or `disk_encryption_enabled` are specified, is
to provision a 20GB `gp3` volume for `/dev/xvda`, with encryption enabled. This is a change from the previous default,
which provisioned a `gp2` volume instead.

### Support for EFS add-on

This module now supports the EFS CSI driver add-on, in very much the same way as it supports the EBS CSI driver add-on.
The only difference is that the EFS CSI driver add-on requires that you first provision an EFS file system.

#### Migration from `eks/efs-controller` to EFS CSI Driver Add-On

If you are currently using the `eks/efs-controller` module, you can migrate to the EFS CSI Driver Add-On by following
these steps:

1. Remove or scale to zero Pods any Deployments using the EFS file system.
2. Remove (`terraform destroy`) the `eks/efs-controller` module from your cluster. This will also remove the `efs-sc`
   StorageClass.
3. Use the
   [eks/storage-class](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/eks/storage-class)
   module to create a replacement EFS StorageClass `efs-sc`. This component is new and you may need to add it to your
   cluster.
4. Deploy the EFS CSI Driver Add-On by adding `aws-efs-csi-driver` to the `addons` map (see [README](./README.md)).
5. Restore the Deployments you modified in step 1.

### More options for specifying Availability Zones

Previously, this module required you to specify the Availability Zones for the cluster in one of two ways:

1. Explicitly, by providing the full AZ names via the `availability_zones` input
2. Implicitly, via private subnets in the VPC

Option 2 is still usually the best way, but now you have additional options:

- You can specify the Availability Zones via the `availability_zones` input without specifying the full AZ names. You
  can just specify the suffixes of the AZ names, and the module will find the full names for you, using the current
  region. This is useful for using the same configuration in multiple regions.
- You can specify Availability Zone IDs via the `availability_zone_ids` input. This is useful to ensure that clusters in
  different accounts are nevertheless deployed to the same Availability Zones. As with the `availability_zones` input,
  you can specify the suffixes of the AZ IDs, and the module will find the full IDs for you, using the current region.

### Support for Karpenter Instance Profile

Previously, this module created an IAM Role for instances launched by Karpenter, but did not create the corresponding
Instance Profile, which was instead created by the `eks/karpenter` component. This can cause problems if you delete and
recreate the cluster, so for new clusters, this module can now create the Instance Profile as well.

Because this is disruptive to existing clusters, this is not enabled by default. To enable it, set the
`legacy_do_not_create_karpenter_instance_profile` input to `false`, and also set the `eks/karpenter` input
`legacy_create_karpenter_instance_profile` to `false`.

## Upgrading to `v1.250.0`

Components PR [#723](https://github.com/cloudposse/terraform-aws-components/pull/723)

### Improved support for EKS Add-Ons

This has improved support for EKS Add-Ons.

##### Configuration and Timeouts

The `addons` input now accepts a `configuration_values` input to allow you to configure the add-ons, and various timeout
inputs to allow you to fine-tune the timeouts for the add-ons.

##### Automatic IAM Role Creation

If you enable `aws-ebs-csi-driver` or `vpc-cni` add-ons, the module will automatically create the required Service
Account IAM Role and attach it to the add-on.

##### Add-Ons can be deployed to Fargate

If you are using Karpenter and not provisioning any nodes with this module, the `coredns` and `aws-ebs-csi-driver`
add-ons can be deployed to Fargate. (They must be able to run somewhere in the cluster or else the deployment will
fail.)

To cause the add-ons to be deployed to Fargate, set the `deploy_addons_to_fargate` input to `true`.

**Note about CoreDNS**: If you want to deploy CoreDNS to Fargate, as of this writing you must set the
`configuration_values` input for CoreDNS to `'{"computeType": "Fargate"}'`. If you want to deploy CoreDNS to EC2
instances, you must NOT include the `computeType` configuration value.

### Availability Zones implied by Private Subnets

You can now avoid specifying Availability Zones for the cluster anywhere. If all of the possible Availability Zones
inputs are empty, the module will use the Availability Zones implied by the private subnets. That is, it will deploy the
cluster to all of the Availability Zones in which the VPC has private subnets.

### Optional support for 1 Fargate Pod Execution Role per Cluster

Previously, this module created a separate Fargate Pod Execution Role for each Fargate Profile it created. This is
unnecessary, excessive, and can cause problems due to name collisions, but is otherwise merely inefficient, so it is not
important to fix this on existiong, working clusters. This update brings a feature that causes the module to create at
most 1 Fargate Pod Execution Role per cluster.

**This change is recommended for all NEW clusters, but only NEW clusters**. Because it is a breaking change, it is not
enabled by default. To enable it, set the `legacy_fargate_1_role_per_profile_enabled` variable to `false`.

**WARNING**: If you enable this feature on an existing cluster, and that cluster is using Karpenter, the update could
destroy all of your existing Karpenter-provisioned nodes. Depending on your Karpenter version, this could leave you with
stranded EC2 instances (still running, but not managed by Karpenter or visible to the cluster) and an interruption of
service, and possibly other problems. If you are using Karpenter and want to enable this feature, the safest way is to
destroy the existing cluster and create a new one with this feature enabled.
