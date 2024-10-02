---
tags:
  - component/eks/cluster
  - layer/eks
  - provider/aws
---

# Component: `eks/cluster`

This component is responsible for provisioning an end-to-end EKS Cluster, including managed node groups and Fargate
profiles.

> [!NOTE]
>
> #### Windows not supported
>
> This component has not been tested with Windows worker nodes of any launch type. Although upstream modules support
> Windows nodes, there are likely issues around incorrect or insufficient IAM permissions or other configuration that
> would need to be resolved for this component to properly configure the upstream modules for Windows nodes. If you need
> Windows nodes, please experiment and be on the lookout for issues, and then report any issues to Cloud Posse.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

This example expects the [Cloud Posse Reference Architecture](https://docs.cloudposse.com/) Identity and Network designs
deployed for mapping users to EKS service roles and granting access in a private network. In addition, this example has
the GitHub OIDC integration added and makes use of Karpenter to dynamically scale cluster nodes.

For more on these requirements, see [Identity Reference Architecture](https://docs.cloudposse.com/layers/identity/),
[Network Reference Architecture](https://docs.cloudposse.com/layers/network/), the
[GitHub OIDC component](https://docs.cloudposse.com/components/library/aws/github-oidc-provider/), and the
[Karpenter component](https://docs.cloudposse.com/components/library/aws/eks/karpenter/).

### Mixin pattern for Kubernetes version

We recommend separating out the Kubernetes and related addons versions into a separate mixin (one per Kubernetes minor
version), to make it easier to run different versions in different environments, for example while testing a new
version.

We also recommend leaving "resolve conflicts" settings unset and therefore using the default "OVERWRITE" setting because
any custom configuration that you would want to preserve should be managed by Terraform configuring the add-ons
directly.

For example, create `catalog/eks/cluster/mixins/k8s-1-29.yaml` with the following content:

```yaml
components:
  terraform:
    eks/cluster:
      vars:
        cluster_kubernetes_version: "1.29"

        # You can set all the add-on versions to `null` to use the latest version,
        # but that introduces drift as new versions are released. As usual, we recommend
        # pinning the versions to a specific version and upgrading when convenient.

        # Determine the latest version of the EKS add-ons for the specified Kubernetes version
        #  EKS_K8S_VERSION=1.29 # replace with your cluster version
        #  ADD_ON=vpc-cni # replace with the add-on name
        #  echo "${ADD_ON}:" && aws eks describe-addon-versions --kubernetes-version $EKS_K8S_VERSION --addon-name $ADD_ON \
        #  --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table

        # To see versions for all the add-ons, wrap the above command in a for loop:
        #   for ADD_ON in vpc-cni kube-proxy coredns aws-ebs-csi-driver aws-efs-csi-driver; do
        #     echo "${ADD_ON}:" && aws eks describe-addon-versions --kubernetes-version $EKS_K8S_VERSION --addon-name $ADD_ON \
        #     --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table
        #   done

        # To see the custom configuration schema for an add-on, run the following command:
        #   aws eks describe-addon-configuration --addon-name aws-ebs-csi-driver \
        #   --addon-version v1.20.0-eksbuild.1 | jq '.configurationSchema | fromjson'
        # See the `coredns` configuration below for an example of how to set a custom configuration.

        # https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html
        # https://docs.aws.amazon.com/eks/latest/userguide/managing-add-ons.html#creating-an-add-on
        addons:
          # https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html
          # https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
          # https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-role
          # https://aws.github.io/aws-eks-best-practices/networking/vpc-cni/#deploy-vpc-cni-managed-add-on
          vpc-cni:
            addon_version: "v1.16.0-eksbuild.1" # set `addon_version` to `null` to use the latest version
          # https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
          kube-proxy:
            addon_version: "v1.29.0-eksbuild.1" # set `addon_version` to `null` to use the latest version
          # https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
          coredns:
            addon_version: "v1.11.1-eksbuild.4" # set `addon_version` to `null` to use the latest version
            ## override default replica count of 2. In very large clusters, you may want to increase this.
            configuration_values: '{"replicaCount": 3}'

          # https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
          # https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons
          # https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html#csi-iam-role
          # https://github.com/kubernetes-sigs/aws-ebs-csi-driver
          aws-ebs-csi-driver:
            addon_version: "v1.27.0-eksbuild.1" # set `addon_version` to `null` to use the latest version
            # If you are not using [volume snapshots](https://kubernetes.io/blog/2020/12/10/kubernetes-1.20-volume-snapshot-moves-to-ga/#how-to-use-volume-snapshots)
            # (and you probably are not), disable the EBS Snapshotter
            # See https://github.com/aws/containers-roadmap/issues/1919
            configuration_values: '{"sidecars":{"snapshotter":{"forceEnable":false}}}'

          aws-efs-csi-driver:
            addon_version: "v1.7.7-eksbuild.1" # set `addon_version` to `null` to use the latest version
            # Set a short timeout in case of conflict with an existing efs-controller deployment
            create_timeout: "7m"
```

### Common settings for all Kubernetes versions

In your main stack configuration, you can then set the Kubernetes version by importing the appropriate mixin:

```yaml
#
import:
  - catalog/eks/cluster/mixins/k8s-1-29

components:
  terraform:
    eks/cluster:
      vars:
        enabled: true
        name: eks
        vpc_component_name: "vpc"
        eks_component_name: "eks/cluster"

        # Your choice of availability zones or availability zone ids
        # availability_zones: ["us-east-1a", "us-east-1b", "us-east-1c"]
        aws_ssm_agent_enabled: true
        allow_ingress_from_vpc_accounts:
          - tenant: core
            stage: auto
          - tenant: core
            stage: corp
          - tenant: core
            stage: network

        public_access_cidrs: []
        allowed_cidr_blocks: []
        allowed_security_groups: []

        enabled_cluster_log_types:
          # Caution: enabling `api` log events may lead to a substantial increase in Cloudwatch Logs expenses.
          - api
          - audit
          - authenticator
          - controllerManager
          - scheduler

        oidc_provider_enabled: true

        # Allows GitHub OIDC role
        github_actions_iam_role_enabled: true
        github_actions_iam_role_attributes: ["eks"]
        github_actions_allowed_repos:
          - acme/infra

        # We recommend, at a minimum, deploying 1 managed node group,
        # with the same number of instances as availability zones (typically 3).
        managed_node_groups_enabled: true
        node_groups: # for most attributes, setting null here means use setting from node_group_defaults
          main:
            # availability_zones = null will create one autoscaling group
            # in every private subnet in the VPC
            availability_zones: null

            # Tune the desired and minimum group size according to your baseload requirements.
            # We recommend no autoscaling for the main node group, so it will
            # stay at the specified desired group size, with additional
            # capacity provided by Karpenter. Nevertheless, we recommend
            # deploying enough capacity in the node group to handle your
            # baseload requirements, and in production, we recommend you
            # have a large enough node group to handle 3/2 (1.5) times your
            # baseload requirements, to handle the loss of a single AZ.
            desired_group_size: 3 # number of instances to start with, should be >= number of AZs
            min_group_size: 3 # must be  >= number of AZs
            max_group_size: 3

            # Can only set one of ami_release_version or kubernetes_version
            # Leave both null to use latest AMI for Cluster Kubernetes version
            kubernetes_version: null # use cluster Kubernetes version
            ami_release_version: null # use latest AMI for Kubernetes version

            attributes: []
            create_before_destroy: true
            cluster_autoscaler_enabled: true
            instance_types:
              # Tune the instance type according to your baseload requirements.
              - c7a.medium
            ami_type: AL2_x86_64 # use "AL2_x86_64" for standard instances, "AL2_x86_64_GPU" for GPU instances
            node_userdata:
              # WARNING: node_userdata is alpha status and will likely change in the future.
              #          Also, it is only supported for AL2 and some Windows AMIs, not BottleRocket or AL2023.
              # Kubernetes docs: https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/
              kubelet_extra_args: >-
                --kube-reserved cpu=100m,memory=0.6Gi,ephemeral-storage=1Gi --system-reserved
                cpu=100m,memory=0.2Gi,ephemeral-storage=1Gi --eviction-hard
                memory.available<200Mi,nodefs.available<10%,imagefs.available<15%
            block_device_map:
              # EBS volume for local ephemeral storage
              # IGNORED if legacy `disk_encryption_enabled` or `disk_size` are set!
              # Use "/dev/xvda" for most of the instances (without local NVMe)
              # using most of the Linuxes, "/dev/xvdb" for BottleRocket
              "/dev/xvda":
                ebs:
                  volume_size: 100 # number of GB
                  volume_type: gp3

            kubernetes_labels: {}
            kubernetes_taints: {}
            resources_to_tag:
              - instance
              - volume
            tags: null

        # The abbreviation method used for Availability Zones in your project.
        # Used for naming resources in managed node groups.
        # Either "short" or "fixed".
        availability_zone_abbreviation_type: fixed

        cluster_private_subnets_only: true
        cluster_encryption_config_enabled: true
        cluster_endpoint_private_access: true
        cluster_endpoint_public_access: false
        cluster_log_retention_period: 90

        # List of `aws-team-roles` (in the account where the EKS cluster is deployed) to map to Kubernetes RBAC groups
        # You cannot set `system:*` groups here, except for `system:masters`.
        # The `idp:*` roles referenced here are created by the `eks/idp-roles` component.
        # While set here, the `idp:*` roles will have no effect until after
        # the `eks/idp-roles` component is applied, which must be after the
        # `eks/cluster` component is deployed.
        aws_team_roles_rbac:
          - aws_team_role: admin
            groups:
              - system:masters
          - aws_team_role: poweruser
            groups:
              - idp:poweruser
          - aws_team_role: observer
            groups:
              - idp:observer
          - aws_team_role: planner
            groups:
              - idp:observer
          - aws_team: terraform
            groups:
              - system:masters

        # Permission sets from AWS SSO allowing cluster access
        # See `aws-sso` component.
        aws_sso_permission_sets_rbac:
          - aws_sso_permission_set: PowerUserAccess
            groups:
              - idp:poweruser

        # Set to false if you are not using Karpenter
        karpenter_iam_role_enabled: true

        # All Fargate Profiles will use the same IAM Role when `legacy_fargate_1_role_per_profile_enabled` is set to false.
        # Recommended for all new clusters, but will damage existing clusters provisioned with the legacy component.
        legacy_fargate_1_role_per_profile_enabled: false
        # While it is possible to deploy add-ons to Fargate Profiles, it is not recommended. Use a managed node group instead.
        deploy_addons_to_fargate: false
```

### Amazon EKS End-of-Life Dates

When picking a Kubernetes version, be sure to review the
[end-of-life dates for Amazon EKS](https://endoflife.date/amazon-eks). Refer to the chart below:

| cycle |  release   | latest      | latest release |    eol     | extended support |
| :---- | :--------: | :---------- | :------------: | :--------: | :--------------: |
| 1.29  | 2024-01-23 | 1.29-eks-6  |   2024-04-18   | 2025-03-23 |    2026-03-23    |
| 1.28  | 2023-09-26 | 1.28-eks-12 |   2024-04-18   | 2024-11-26 |    2025-11-26    |
| 1.27  | 2023-05-24 | 1.27-eks-16 |   2024-04-18   | 2024-07-24 |    2025-07-24    |
| 1.26  | 2023-04-11 | 1.26-eks-17 |   2024-04-18   | 2024-06-11 |    2025-06-11    |
| 1.25  | 2023-02-21 | 1.25-eks-18 |   2024-04-18   | 2024-05-01 |    2025-05-01    |
| 1.24  | 2022-11-15 | 1.24-eks-21 |   2024-04-18   | 2024-01-31 |    2025-01-31    |
| 1.23  | 2022-08-11 | 1.23-eks-23 |   2024-04-18   | 2023-10-11 |    2024-10-11    |
| 1.22  | 2022-04-04 | 1.22-eks-14 |   2023-06-30   | 2023-06-04 |    2024-09-01    |
| 1.21  | 2021-07-19 | 1.21-eks-18 |   2023-06-09   | 2023-02-16 |    2024-07-15    |
| 1.20  | 2021-05-18 | 1.20-eks-14 |   2023-05-05   | 2022-11-01 |      False       |
| 1.19  | 2021-02-16 | 1.19-eks-11 |   2022-08-15   | 2022-08-01 |      False       |
| 1.18  | 2020-10-13 | 1.18-eks-13 |   2022-08-15   | 2022-08-15 |      False       |

\* This Chart was generated 2024-05-12 with [the `eol` tool](https://github.com/hugovk/norwegianblue). Install it with
`python3 -m pip install --upgrade norwegianblue` and create a new table by running `eol --md amazon-eks` locally, or
view the information by visiting [the endoflife website](https://endoflife.date/amazon-eks).

You can also view the release and support timeline for
[the Kubernetes project itself](https://endoflife.date/kubernetes).

### Using Addons

EKS clusters support “Addons” that can be automatically installed on a cluster. Install these addons with the
[`var.addons` input](https://docs.cloudposse.com/components/library/aws/eks/cluster/#input_addons).

> [!TIP]
>
> Run the following command to see all available addons, their type, and their publisher. You can also see the URL for
> addons that are available through the AWS Marketplace. Replace 1.27 with the version of your cluster. See
> [Creating an addon](https://docs.aws.amazon.com/eks/latest/userguide/managing-add-ons.html#creating-an-add-on) for
> more details.

```shell
EKS_K8S_VERSION=1.29 # replace with your cluster version
aws eks describe-addon-versions --kubernetes-version $EKS_K8S_VERSION \
  --query 'addons[].{MarketplaceProductUrl: marketplaceInformation.productUrl, Name: addonName, Owner: owner Publisher: publisher, Type: type}' --output table
```

> [!TIP]
>
> You can see which versions are available for each addon by executing the following commands. Replace 1.29 with the
> version of your cluster.

```shell
EKS_K8S_VERSION=1.29 # replace with your cluster version
echo "vpc-cni:" && aws eks describe-addon-versions --kubernetes-version $EKS_K8S_VERSION --addon-name vpc-cni \
  --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table

echo "kube-proxy:" && aws eks describe-addon-versions --kubernetes-version $EKS_K8S_VERSION --addon-name kube-proxy \
  --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table

echo "coredns:" && aws eks describe-addon-versions --kubernetes-version $EKS_K8S_VERSION --addon-name coredns \
  --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table

echo "aws-ebs-csi-driver:" && aws eks describe-addon-versions --kubernetes-version $EKS_K8S_VERSION --addon-name aws-ebs-csi-driver \
  --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table

echo "aws-efs-csi-driver:" && aws eks describe-addon-versions --kubernetes-version $EKS_K8S_VERSION --addon-name aws-efs-csi-driver \
  --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table
```

Some add-ons accept additional configuration. For example, the `vpc-cni` addon accepts a `disableNetworking` parameter.
View the available configuration options (as JSON Schema) via the `aws eks describe-addon-configuration` command. For
example:

```shell
aws eks describe-addon-configuration \
  --addon-name aws-ebs-csi-driver \
  --addon-version v1.20.0-eksbuild.1 | jq '.configurationSchema | fromjson'
```

You can then configure the add-on via the `configuration_values` input. For example:

```yaml
aws-ebs-csi-driver:
  configuration_values: '{"node": {"loggingFormat": "json"}}'
```

Configure the addons like the following example:

```yaml
# https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html
# https://docs.aws.amazon.com/eks/latest/userguide/managing-add-ons.html#creating-an-add-on
# https://aws.amazon.com/blogs/containers/amazon-eks-add-ons-advanced-configuration/
addons:
  # https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html
  # https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
  # https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-role
  # https://aws.github.io/aws-eks-best-practices/networking/vpc-cni/#deploy-vpc-cni-managed-add-on
  vpc-cni:
    addon_version: "v1.12.2-eksbuild.1" # set `addon_version` to `null` to use the latest version
  # https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
  kube-proxy:
    addon_version: "v1.25.6-eksbuild.1" # set `addon_version` to `null` to use the latest version
  # https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
  coredns:
    addon_version: "v1.9.3-eksbuild.2" # set `addon_version` to `null` to use the latest version
    # Override default replica count of 2, to have one in each AZ
    configuration_values: '{"replicaCount": 3}'
  # https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
  # https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons
  # https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html#csi-iam-role
  # https://github.com/kubernetes-sigs/aws-ebs-csi-driver
  aws-ebs-csi-driver:
    addon_version: "v1.19.0-eksbuild.2" # set `addon_version` to `null` to use the latest version
    # If you are not using [volume snapshots](https://kubernetes.io/blog/2020/12/10/kubernetes-1.20-volume-snapshot-moves-to-ga/#how-to-use-volume-snapshots)
    # (and you probably are not), disable the EBS Snapshotter with:
    configuration_values: '{"sidecars":{"snapshotter":{"forceEnable":false}}}'
```

Some addons, such as CoreDNS, require at least one node to be fully provisioned first. See
[issue #170](https://github.com/cloudposse/terraform-aws-eks-cluster/issues/170) for more details. Set
`var.addons_depends_on` to `true` to require the Node Groups to be provisioned before addons.

```yaml
addons_depends_on: true
addons:
  coredns:
    addon_version: "v1.8.7-eksbuild.1"
```

> [!WARNING]
>
> Addons may not be suitable for all use-cases! For example, if you are deploying Karpenter to Fargate and using
> Karpenter to provision all nodes, these nodes will never be available before the cluster component is deployed if you
> are using the CoreDNS addon (for example).
>
> This is one of the reasons we recommend deploying a managed node group: to ensure that the addons will become fully
> functional during deployment of the cluster.

For more information on upgrading EKS Addons, see
["How to Upgrade EKS Cluster Addons"](https://docs.cloudposse.com/learn/maintenance/upgrades/how-to-upgrade-eks-cluster-addons/)

### Adding and Configuring a new EKS Addon

The component already supports all the EKS addons shown in the configurations above. To add a new EKS addon, not
supported by the cluster, add it to the `addons` map (`addons` variable):

```yaml
addons:
  my-addon:
    addon_version: "..."
```

If the new addon requires an EKS IAM Role for Kubernetes Service Account, perform the following steps:

- Add a file `addons-custom.tf` to the `eks/cluster` folder if not already present

- In the file, add an IAM policy document with the permissions required for the addon, and use the `eks-iam-role` module
  to provision an IAM Role for Kubernetes Service Account for the addon:

  ```hcl
    data "aws_iam_policy_document" "my_addon" {
      statement {
        sid       = "..."
        effect    = "Allow"
        resources = ["..."]

        actions = [
          "...",
          "..."
        ]
      }
    }

    module "my_addon_eks_iam_role" {
      source  = "cloudposse/eks-iam-role/aws"
      version = "2.1.0"

      eks_cluster_oidc_issuer_url = local.eks_cluster_oidc_issuer_url

      service_account_name      = "..."
      service_account_namespace = "..."

      aws_iam_policy_document = [one(data.aws_iam_policy_document.my_addon[*].json)]

      context = module.this.context
    }
  ```

  For examples of how to configure the IAM role and IAM permissions for EKS addons, see [addons.tf](addons.tf).

- Add a file `additional-addon-support_override.tf` to the `eks/cluster` folder if not already present

- In the file, add the IAM Role for Kubernetes Service Account for the addon to the
  `overridable_additional_addon_service_account_role_arn_map` map:

  ```hcl
    locals {
      overridable_additional_addon_service_account_role_arn_map = {
        my-addon = module.my_addon_eks_iam_role.service_account_role_arn
      }
    }
  ```

- This map will override the default map in the [additional-addon-support.tf](additional-addon-support.tf) file, and
  will be merged into the final map together with the default EKS addons `vpc-cni` and `aws-ebs-csi-driver` (which this
  component configures and creates IAM Roles for Kubernetes Service Accounts)

- Follow the instructions in the [additional-addon-support.tf](additional-addon-support.tf) file if the addon may need
  to be deployed to Fargate, or has dependencies that Terraform cannot detect automatically.

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_ebs_csi_driver_eks_iam_role"></a> [aws\_ebs\_csi\_driver\_eks\_iam\_role](#module\_aws\_ebs\_csi\_driver\_eks\_iam\_role) | cloudposse/eks-iam-role/aws | 2.1.1 |
| <a name="module_aws_ebs_csi_driver_fargate_profile"></a> [aws\_ebs\_csi\_driver\_fargate\_profile](#module\_aws\_ebs\_csi\_driver\_fargate\_profile) | cloudposse/eks-fargate-profile/aws | 1.3.0 |
| <a name="module_aws_efs_csi_driver_eks_iam_role"></a> [aws\_efs\_csi\_driver\_eks\_iam\_role](#module\_aws\_efs\_csi\_driver\_eks\_iam\_role) | cloudposse/eks-iam-role/aws | 2.1.1 |
| <a name="module_coredns_fargate_profile"></a> [coredns\_fargate\_profile](#module\_coredns\_fargate\_profile) | cloudposse/eks-fargate-profile/aws | 1.3.0 |
| <a name="module_eks_cluster"></a> [eks\_cluster](#module\_eks\_cluster) | cloudposse/eks-cluster/aws | 4.1.0 |
| <a name="module_fargate_pod_execution_role"></a> [fargate\_pod\_execution\_role](#module\_fargate\_pod\_execution\_role) | cloudposse/eks-fargate-profile/aws | 1.3.0 |
| <a name="module_fargate_profile"></a> [fargate\_profile](#module\_fargate\_profile) | cloudposse/eks-fargate-profile/aws | 1.3.0 |
| <a name="module_iam_arns"></a> [iam\_arns](#module\_iam\_arns) | ../../account-map/modules/roles-to-principals | n/a |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_karpenter_label"></a> [karpenter\_label](#module\_karpenter\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_region_node_group"></a> [region\_node\_group](#module\_region\_node\_group) | ./modules/node_group_by_region | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_utils"></a> [utils](#module\_utils) | cloudposse/utils/aws | 1.3.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_vpc_cni_eks_iam_role"></a> [vpc\_cni\_eks\_iam\_role](#module\_vpc\_cni\_eks\_iam\_role) | cloudposse/eks-iam-role/aws | 2.1.1 |
| <a name="module_vpc_ingress"></a> [vpc\_ingress](#module\_vpc\_ingress) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.ipv6_eks_cni_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.karpenter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.amazon_ec2_container_registry_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.amazon_eks_worker_node_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.amazon_ssm_managed_instance_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.aws_ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.aws_efs_csi_driver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ipv6_eks_cni_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [random_pet.camel_case_warning](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_availability_zones.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ipv6_eks_cni_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_cni_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_roles.sso_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_config"></a> [access\_config](#input\_access\_config) | Access configuration for the EKS cluster | <pre>object({<br>    authentication_mode                         = optional(string, "API")<br>    bootstrap_cluster_creator_admin_permissions = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_addons"></a> [addons](#input\_addons) | Manages [EKS addons](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) resources | <pre>map(object({<br>    enabled       = optional(bool, true)<br>    addon_version = optional(string, null)<br>    # configuration_values is a JSON string, such as '{"computeType": "Fargate"}'.<br>    configuration_values = optional(string, null)<br>    # Set default resolve_conflicts to OVERWRITE because it is required on initial installation of<br>    # add-ons that have self-managed versions installed by default (e.g. vpc-cni, coredns), and<br>    # because any custom configuration that you would want to preserve should be managed by Terraform.<br>    resolve_conflicts_on_create = optional(string, "OVERWRITE")<br>    resolve_conflicts_on_update = optional(string, "OVERWRITE")<br>    service_account_role_arn    = optional(string, null)<br>    create_timeout              = optional(string, null)<br>    update_timeout              = optional(string, null)<br>    delete_timeout              = optional(string, null)<br>  }))</pre> | `{}` | no |
| <a name="input_addons_depends_on"></a> [addons\_depends\_on](#input\_addons\_depends\_on) | If set `true` (recommended), all addons will depend on managed node groups provisioned by this component and therefore not be installed until nodes are provisioned.<br>See [issue #170](https://github.com/cloudposse/terraform-aws-eks-cluster/issues/170) for more details. | `bool` | `true` | no |
| <a name="input_allow_ingress_from_vpc_accounts"></a> [allow\_ingress\_from\_vpc\_accounts](#input\_allow\_ingress\_from\_vpc\_accounts) | List of account contexts to pull VPC ingress CIDR and add to cluster security group.<br><br>e.g.<br><br>{<br>  environment = "ue2",<br>  stage       = "auto",<br>  tenant      = "core"<br>} | `any` | `[]` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks to be allowed to connect to the EKS cluster | `list(string)` | `[]` | no |
| <a name="input_allowed_security_groups"></a> [allowed\_security\_groups](#input\_allowed\_security\_groups) | List of Security Group IDs to be allowed to connect to the EKS cluster | `list(string)` | `[]` | no |
| <a name="input_apply_config_map_aws_auth"></a> [apply\_config\_map\_aws\_auth](#input\_apply\_config\_map\_aws\_auth) | (Obsolete) Whether to execute `kubectl apply` to apply the ConfigMap to allow worker nodes to join the EKS cluster.<br>This input is included to avoid breaking existing configurations that set it to `true`;<br>a value of `false` is no longer allowed.<br>This input is obsolete and will be removed in a future release. | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_availability_zone_abbreviation_type"></a> [availability\_zone\_abbreviation\_type](#input\_availability\_zone\_abbreviation\_type) | Type of Availability Zone abbreviation (either `fixed` or `short`) to use in names. See https://github.com/cloudposse/terraform-aws-utils for details. | `string` | `"fixed"` | no |
| <a name="input_availability_zone_ids"></a> [availability\_zone\_ids](#input\_availability\_zone\_ids) | List of Availability Zones IDs where subnets will be created. Overrides `availability_zones`.<br>Can be the full name, e.g. `use1-az1`, or just the part after the AZ ID region code, e.g. `-az1`,<br>to allow reusable values across regions. Consider contention for resources and spot pricing in each AZ when selecting.<br>Useful in some regions when using only some AZs and you want to use the same ones across multiple accounts. | `list(string)` | `[]` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | AWS Availability Zones in which to deploy multi-AZ resources.<br>Ignored if `availability_zone_ids` is set.<br>Can be the full name, e.g. `us-east-1a`, or just the part after the region, e.g. `a` to allow reusable values across regions.<br>If not provided, resources will be provisioned in every zone with a private subnet in the VPC. | `list(string)` | `[]` | no |
| <a name="input_aws_ssm_agent_enabled"></a> [aws\_ssm\_agent\_enabled](#input\_aws\_ssm\_agent\_enabled) | Set true to attach the required IAM policy for AWS SSM agent to each EC2 instance's IAM Role | `bool` | `false` | no |
| <a name="input_aws_sso_permission_sets_rbac"></a> [aws\_sso\_permission\_sets\_rbac](#input\_aws\_sso\_permission\_sets\_rbac) | (Not Recommended): AWS SSO (IAM Identity Center) permission sets in the EKS deployment account to add to `aws-auth` ConfigMap.<br>Unfortunately, `aws-auth` ConfigMap does not support SSO permission sets, so we map the generated<br>IAM Role ARN corresponding to the permission set at the time Terraform runs. This is subject to change<br>when any changes are made to the AWS SSO configuration, invalidating the mapping, and requiring a<br>`terraform apply` in this project to update the `aws-auth` ConfigMap and restore access. | <pre>list(object({<br>    aws_sso_permission_set = string<br>    groups                 = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_aws_team_roles_rbac"></a> [aws\_team\_roles\_rbac](#input\_aws\_team\_roles\_rbac) | List of `aws-team-roles` (in the target AWS account) to map to Kubernetes RBAC groups. | <pre>list(object({<br>    aws_team_role = string<br>    groups        = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_cluster_encryption_config_enabled"></a> [cluster\_encryption\_config\_enabled](#input\_cluster\_encryption\_config\_enabled) | Set to `true` to enable Cluster Encryption Configuration | `bool` | `true` | no |
| <a name="input_cluster_encryption_config_kms_key_deletion_window_in_days"></a> [cluster\_encryption\_config\_kms\_key\_deletion\_window\_in\_days](#input\_cluster\_encryption\_config\_kms\_key\_deletion\_window\_in\_days) | Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction | `number` | `10` | no |
| <a name="input_cluster_encryption_config_kms_key_enable_key_rotation"></a> [cluster\_encryption\_config\_kms\_key\_enable\_key\_rotation](#input\_cluster\_encryption\_config\_kms\_key\_enable\_key\_rotation) | Cluster Encryption Config KMS Key Resource argument - enable kms key rotation | `bool` | `true` | no |
| <a name="input_cluster_encryption_config_kms_key_id"></a> [cluster\_encryption\_config\_kms\_key\_id](#input\_cluster\_encryption\_config\_kms\_key\_id) | KMS Key ID to use for cluster encryption config | `string` | `""` | no |
| <a name="input_cluster_encryption_config_kms_key_policy"></a> [cluster\_encryption\_config\_kms\_key\_policy](#input\_cluster\_encryption\_config\_kms\_key\_policy) | Cluster Encryption Config KMS Key Resource argument - key policy | `string` | `null` | no |
| <a name="input_cluster_encryption_config_resources"></a> [cluster\_encryption\_config\_resources](#input\_cluster\_encryption\_config\_resources) | Cluster Encryption Config Resources to encrypt, e.g. `["secrets"]` | `list(string)` | <pre>[<br>  "secrets"<br>]</pre> | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is `false` | `bool` | `false` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is `true` | `bool` | `true` | no |
| <a name="input_cluster_kubernetes_version"></a> [cluster\_kubernetes\_version](#input\_cluster\_kubernetes\_version) | Desired Kubernetes master version. If you do not specify a value, the latest available version is used | `string` | `null` | no |
| <a name="input_cluster_log_retention_period"></a> [cluster\_log\_retention\_period](#input\_cluster\_log\_retention\_period) | Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. | `number` | `0` | no |
| <a name="input_cluster_private_subnets_only"></a> [cluster\_private\_subnets\_only](#input\_cluster\_private\_subnets\_only) | Whether or not to enable private subnets or both public and private subnets | `bool` | `false` | no |
| <a name="input_color"></a> [color](#input\_color) | The cluster stage represented by a color; e.g. blue, green | `string` | `""` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_deploy_addons_to_fargate"></a> [deploy\_addons\_to\_fargate](#input\_deploy\_addons\_to\_fargate) | Set to `true` (not recommended) to deploy addons to Fargate instead of initial node pool | `bool` | `false` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_enabled_cluster_log_types"></a> [enabled\_cluster\_log\_types](#input\_enabled\_cluster\_log\_types) | A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`] | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_fargate_profile_iam_role_kubernetes_namespace_delimiter"></a> [fargate\_profile\_iam\_role\_kubernetes\_namespace\_delimiter](#input\_fargate\_profile\_iam\_role\_kubernetes\_namespace\_delimiter) | Delimiter for the Kubernetes namespace in the IAM Role name for Fargate Profiles | `string` | `"-"` | no |
| <a name="input_fargate_profile_iam_role_permissions_boundary"></a> [fargate\_profile\_iam\_role\_permissions\_boundary](#input\_fargate\_profile\_iam\_role\_permissions\_boundary) | If provided, all Fargate Profiles IAM roles will be created with this permissions boundary attached | `string` | `null` | no |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Fargate Profiles config | <pre>map(object({<br>    kubernetes_namespace = string<br>    kubernetes_labels    = map(string)<br>  }))</pre> | `{}` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_karpenter_iam_role_enabled"></a> [karpenter\_iam\_role\_enabled](#input\_karpenter\_iam\_role\_enabled) | Flag to enable/disable creation of IAM role for EC2 Instance Profile that is attached to the nodes launched by Karpenter | `bool` | `false` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_legacy_do_not_create_karpenter_instance_profile"></a> [legacy\_do\_not\_create\_karpenter\_instance\_profile](#input\_legacy\_do\_not\_create\_karpenter\_instance\_profile) | **Obsolete:** The issues this was meant to mitigate were fixed in AWS Terraform Provider v5.43.0<br>and Karpenter v0.33.0. This variable will be removed in a future release.<br>Remove this input from your configuration and leave it at default.<br>**Old description:** When `true` (the default), suppresses creation of the IAM Instance Profile<br>for nodes launched by Karpenter, to preserve the legacy behavior of<br>the `eks/karpenter` component creating it.<br>Set to `false` to enable creation of the IAM Instance Profile, which<br>ensures that both the role and the instance profile have the same lifecycle,<br>and avoids AWS Provider issue [#32671](https://github.com/hashicorp/terraform-provider-aws/issues/32671).<br>Use in conjunction with `eks/karpenter` component `legacy_create_karpenter_instance_profile`. | `bool` | `true` | no |
| <a name="input_legacy_fargate_1_role_per_profile_enabled"></a> [legacy\_fargate\_1\_role\_per\_profile\_enabled](#input\_legacy\_fargate\_1\_role\_per\_profile\_enabled) | Set to `false` for new clusters to create a single Fargate Pod Execution role for the cluster.<br>Set to `true` for existing clusters to preserve the old behavior of creating<br>a Fargate Pod Execution role for each Fargate Profile. | `bool` | `true` | no |
| <a name="input_managed_node_groups_enabled"></a> [managed\_node\_groups\_enabled](#input\_managed\_node\_groups\_enabled) | Set false to prevent the creation of EKS managed node groups. | `bool` | `true` | no |
| <a name="input_map_additional_aws_accounts"></a> [map\_additional\_aws\_accounts](#input\_map\_additional\_aws\_accounts) | (Obsolete) Additional AWS accounts to grant access to the EKS cluster.<br>This input is included to avoid breaking existing configurations that<br>supplied an empty list, but the list is no longer allowed to have entries.<br>(It is not clear that it worked properly in earlier versions in any case.)<br>This component now only supports EKS access entries, which require full principal ARNs.<br>This input is deprecated and will be removed in a future release. | `list(string)` | `[]` | no |
| <a name="input_map_additional_iam_roles"></a> [map\_additional\_iam\_roles](#input\_map\_additional\_iam\_roles) | Additional IAM roles to grant access to the cluster.<br>*WARNING*: Full Role ARN, including path, is required for `rolearn`.<br>In earlier versions (with `aws-auth` ConfigMap), only the path<br>had to be removed from the Role ARN. The path is now required.<br>`username` is now ignored. This input is planned to be replaced<br>in a future release with a more flexible input structure that consolidates<br>`map_additional_iam_roles` and `map_additional_iam_users`. | <pre>list(object({<br>    rolearn  = string<br>    username = optional(string)<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_additional_iam_users"></a> [map\_additional\_iam\_users](#input\_map\_additional\_iam\_users) | Additional IAM roles to grant access to the cluster.<br>`username` is now ignored. This input is planned to be replaced<br>in a future release with a more flexible input structure that consolidates<br>`map_additional_iam_roles` and `map_additional_iam_users`. | <pre>list(object({<br>    userarn  = string<br>    username = optional(string)<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_additional_worker_roles"></a> [map\_additional\_worker\_roles](#input\_map\_additional\_worker\_roles) | (Deprecated) AWS IAM Role ARNs of unmanaged Linux worker nodes to grant access to the EKS cluster.<br>In earlier versions, this could be used to grant access to worker nodes of any type<br>that were not managed by the EKS cluster. Now EKS requires that unmanaged worker nodes<br>be classified as Linux or Windows servers, in this input is temporarily retained<br>with the assumption that all worker nodes are Linux servers. (It is likely that<br>earlier versions did not work properly with Windows worker nodes anyway.)<br>This input is deprecated and will be removed in a future release.<br>In the future, this component will either have a way to separate Linux and Windows worker nodes,<br>or drop support for unmanaged worker nodes entirely. | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_node_group_defaults"></a> [node\_group\_defaults](#input\_node\_group\_defaults) | Defaults for node groups in the cluster | <pre>object({<br>    ami_release_version        = optional(string, null)<br>    ami_type                   = optional(string, null)<br>    attributes                 = optional(list(string), null)<br>    availability_zones         = optional(list(string)) # set to null to use var.availability_zones<br>    cluster_autoscaler_enabled = optional(bool, null)<br>    create_before_destroy      = optional(bool, null)<br>    desired_group_size         = optional(number, null)<br>    instance_types             = optional(list(string), null)<br>    kubernetes_labels          = optional(map(string), {})<br>    kubernetes_taints = optional(list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    })), [])<br>    node_userdata = optional(object({<br>      before_cluster_joining_userdata = optional(string)<br>      bootstrap_extra_args            = optional(string)<br>      kubelet_extra_args              = optional(string)<br>      after_cluster_joining_userdata  = optional(string)<br>    }), {})<br>    kubernetes_version = optional(string, null) # set to null to use cluster_kubernetes_version<br>    max_group_size     = optional(number, null)<br>    min_group_size     = optional(number, null)<br>    resources_to_tag   = optional(list(string), null)<br>    tags               = optional(map(string), null)<br><br>    # block_device_map copied from cloudposse/terraform-aws-eks-node-group<br>    # Keep in sync via copy and paste, but make optional<br>    # Most of the time you want "/dev/xvda". For BottleRocket, use "/dev/xvdb".<br>    block_device_map = optional(map(object({<br>      no_device    = optional(bool, null)<br>      virtual_name = optional(string, null)<br>      ebs = optional(object({<br>        delete_on_termination = optional(bool, true)<br>        encrypted             = optional(bool, true)<br>        iops                  = optional(number, null)<br>        kms_key_id            = optional(string, null)<br>        snapshot_id           = optional(string, null)<br>        throughput            = optional(number, null) # for gp3, MiB/s, up to 1000<br>        volume_size           = optional(number, 50)   # disk  size in GB<br>        volume_type           = optional(string, "gp3")<br><br>        # Catch common camel case typos. These have no effect, they just generate better errors.<br>        # It would be nice to actually use these, but volumeSize in particular is a number here<br>        # and in most places it is a string with a unit suffix (e.g. 20Gi)<br>        # Without these defined, they would be silently ignored and the default values would be used instead,<br>        # which is difficult to debug.<br>        deleteOnTermination = optional(any, null)<br>        kmsKeyId            = optional(any, null)<br>        snapshotId          = optional(any, null)<br>        volumeSize          = optional(any, null)<br>        volumeType          = optional(any, null)<br>      }))<br>    })), null)<br><br>    # DEPRECATED: disk_encryption_enabled is DEPRECATED, use `block_device_map` instead.<br>    disk_encryption_enabled = optional(bool, null)<br>    # DEPRECATED: disk_size is DEPRECATED, use `block_device_map` instead.<br>    disk_size = optional(number, null)<br>  })</pre> | <pre>{<br>  "block_device_map": {<br>    "/dev/xvda": {<br>      "ebs": {<br>        "encrypted": true,<br>        "volume_size": 20,<br>        "volume_type": "gp2"<br>      }<br>    }<br>  },<br>  "desired_group_size": 1,<br>  "instance_types": [<br>    "t3.medium"<br>  ],<br>  "kubernetes_version": null,<br>  "max_group_size": 100<br>}</pre> | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | List of objects defining a node group for the cluster | <pre>map(object({<br>    # EKS AMI version to use, e.g. "1.16.13-20200821" (no "v").<br>    ami_release_version = optional(string, null)<br>    # Type of Amazon Machine Image (AMI) associated with the EKS Node Group<br>    ami_type = optional(string, null)<br>    # Additional attributes (e.g. `1`) for the node group<br>    attributes = optional(list(string), null)<br>    # will create 1 auto scaling group in each specified availability zone<br>    # or all AZs with subnets if none are specified anywhere<br>    availability_zones = optional(list(string), null)<br>    # Whether to enable Node Group to scale its AutoScaling Group<br>    cluster_autoscaler_enabled = optional(bool, null)<br>    # True to create new node_groups before deleting old ones, avoiding a temporary outage<br>    create_before_destroy = optional(bool, null)<br>    # Desired number of worker nodes when initially provisioned<br>    desired_group_size = optional(number, null)<br>    # Set of instance types associated with the EKS Node Group. Terraform will only perform drift detection if a configuration value is provided.<br>    instance_types = optional(list(string), null)<br>    # Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed<br>    kubernetes_labels = optional(map(string), null)<br>    # List of objects describing Kubernetes taints.<br>    kubernetes_taints = optional(list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    })), null)<br>    node_userdata = optional(object({<br>      before_cluster_joining_userdata = optional(string)<br>      bootstrap_extra_args            = optional(string)<br>      kubelet_extra_args              = optional(string)<br>      after_cluster_joining_userdata  = optional(string)<br>    }), {})<br>    # Desired Kubernetes master version. If you do not specify a value, the latest available version is used<br>    kubernetes_version = optional(string, null)<br>    # The maximum size of the AutoScaling Group<br>    max_group_size = optional(number, null)<br>    # The minimum size of the AutoScaling Group<br>    min_group_size = optional(number, null)<br>    # List of auto-launched resource types to tag<br>    resources_to_tag = optional(list(string), null)<br>    tags             = optional(map(string), null)<br><br>    # block_device_map copied from cloudposse/terraform-aws-eks-node-group<br>    # Keep in sync via copy and paste, but make optional.<br>    # Most of the time you want "/dev/xvda". For BottleRocket, use "/dev/xvdb".<br>    block_device_map = optional(map(object({<br>      no_device    = optional(bool, null)<br>      virtual_name = optional(string, null)<br>      ebs = optional(object({<br>        delete_on_termination = optional(bool, true)<br>        encrypted             = optional(bool, true)<br>        iops                  = optional(number, null)<br>        kms_key_id            = optional(string, null)<br>        snapshot_id           = optional(string, null)<br>        throughput            = optional(number, null) # for gp3, MiB/s, up to 1000<br>        volume_size           = optional(number, 20)   # Disk size in GB<br>        volume_type           = optional(string, "gp3")<br><br>        # Catch common camel case typos. These have no effect, they just generate better errors.<br>        # It would be nice to actually use these, but volumeSize in particular is a number here<br>        # and in most places it is a string with a unit suffix (e.g. 20Gi)<br>        # Without these defined, they would be silently ignored and the default values would be used instead,<br>        # which is difficult to debug.<br>        deleteOnTermination = optional(any, null)<br>        kmsKeyId            = optional(any, null)<br>        snapshotId          = optional(any, null)<br>        volumeSize          = optional(any, null)<br>        volumeType          = optional(any, null)<br>      }))<br>    })), null)<br><br>    # DEPRECATED:<br>    # Enable disk encryption for the created launch template (if we aren't provided with an existing launch template)<br>    # DEPRECATED: disk_encryption_enabled is DEPRECATED, use `block_device_map` instead.<br>    disk_encryption_enabled = optional(bool, null)<br>    # Disk size in GiB for worker nodes. Terraform will only perform drift detection if a configuration value is provided.<br>    # DEPRECATED: disk_size is DEPRECATED, use `block_device_map` instead.<br>    disk_size = optional(number, null)<br><br>  }))</pre> | `{}` | no |
| <a name="input_oidc_provider_enabled"></a> [oidc\_provider\_enabled](#input\_oidc\_provider\_enabled) | Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using kiam or kube2iam. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html | `bool` | `true` | no |
| <a name="input_public_access_cidrs"></a> [public\_access\_cidrs](#input\_public\_access\_cidrs) | Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_subnet_type_tag_key"></a> [subnet\_type\_tag\_key](#input\_subnet\_type\_tag\_key) | The tag used to find the private subnets to find by availability zone. If null, will be looked up in vpc outputs. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_vpc_component_name"></a> [vpc\_component\_name](#input\_vpc\_component\_name) | The name of the vpc component | `string` | `"vpc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | Availability Zones in which the cluster is provisioned |
| <a name="output_eks_addons_versions"></a> [eks\_addons\_versions](#output\_eks\_addons\_versions) | Map of enabled EKS Addons names and versions |
| <a name="output_eks_auth_worker_roles"></a> [eks\_auth\_worker\_roles](#output\_eks\_auth\_worker\_roles) | List of worker IAM roles that were included in the `auth-map` ConfigMap. |
| <a name="output_eks_cluster_arn"></a> [eks\_cluster\_arn](#output\_eks\_cluster\_arn) | The Amazon Resource Name (ARN) of the cluster |
| <a name="output_eks_cluster_certificate_authority_data"></a> [eks\_cluster\_certificate\_authority\_data](#output\_eks\_cluster\_certificate\_authority\_data) | The Kubernetes cluster certificate authority data |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | The endpoint for the Kubernetes API server |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | The name of the cluster |
| <a name="output_eks_cluster_identity_oidc_issuer"></a> [eks\_cluster\_identity\_oidc\_issuer](#output\_eks\_cluster\_identity\_oidc\_issuer) | The OIDC Identity issuer for the cluster |
| <a name="output_eks_cluster_managed_security_group_id"></a> [eks\_cluster\_managed\_security\_group\_id](#output\_eks\_cluster\_managed\_security\_group\_id) | Security Group ID that was created by EKS for the cluster. EKS creates a Security Group and applies it to ENI that is attached to EKS Control Plane master nodes and to any managed workloads |
| <a name="output_eks_cluster_version"></a> [eks\_cluster\_version](#output\_eks\_cluster\_version) | The Kubernetes server version of the cluster |
| <a name="output_eks_managed_node_workers_role_arns"></a> [eks\_managed\_node\_workers\_role\_arns](#output\_eks\_managed\_node\_workers\_role\_arns) | List of ARNs for workers in managed node groups |
| <a name="output_eks_node_group_arns"></a> [eks\_node\_group\_arns](#output\_eks\_node\_group\_arns) | List of all the node group ARNs in the cluster |
| <a name="output_eks_node_group_count"></a> [eks\_node\_group\_count](#output\_eks\_node\_group\_count) | Count of the worker nodes |
| <a name="output_eks_node_group_ids"></a> [eks\_node\_group\_ids](#output\_eks\_node\_group\_ids) | EKS Cluster name and EKS Node Group name separated by a colon |
| <a name="output_eks_node_group_role_names"></a> [eks\_node\_group\_role\_names](#output\_eks\_node\_group\_role\_names) | List of worker nodes IAM role names |
| <a name="output_eks_node_group_statuses"></a> [eks\_node\_group\_statuses](#output\_eks\_node\_group\_statuses) | Status of the EKS Node Group |
| <a name="output_fargate_profile_role_arns"></a> [fargate\_profile\_role\_arns](#output\_fargate\_profile\_role\_arns) | Fargate Profile Role ARNs |
| <a name="output_fargate_profile_role_names"></a> [fargate\_profile\_role\_names](#output\_fargate\_profile\_role\_names) | Fargate Profile Role names |
| <a name="output_fargate_profiles"></a> [fargate\_profiles](#output\_fargate\_profiles) | Fargate Profiles |
| <a name="output_karpenter_iam_role_arn"></a> [karpenter\_iam\_role\_arn](#output\_karpenter\_iam\_role\_arn) | Karpenter IAM Role ARN |
| <a name="output_karpenter_iam_role_name"></a> [karpenter\_iam\_role\_name](#output\_karpenter\_iam\_role\_name) | Karpenter IAM Role name |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | The CIDR of the VPC where this cluster is deployed. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## Related How-to Guides

- [EKS Foundational Platform](https://docs.cloudposse.com/layers/eks/)

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/eks/cluster) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
