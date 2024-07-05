# Component: `eks/cluster`

This component is responsible for provisioning an end-to-end EKS Cluster, including managed node groups and Fargate
profiles.

:::note Windows not supported

This component has not been tested with Windows worker nodes of any launch type. Although upstream modules support
Windows nodes, there are likely issues around incorrect or insufficient IAM permissions or other configuration that
would need to be resolved for this component to properly configure the upstream modules for Windows nodes. If you need
Windows nodes, please experiment and be on the lookout for issues, and then report any issues to Cloud Posse.

:::

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

This example expects the [Cloud Posse Reference Architecture](https://docs.cloudposse.com/reference-architecture/)
Identity and Network designs deployed for mapping users to EKS service roles and granting access in a private network.
In addition, this example has the GitHub OIDC integration added and makes use of Karpenter to dynamically scale cluster
nodes.

For more on these requirements, see
[Identity Reference Architecture](https://docs.cloudposse.com/reference-architecture/quickstart/iam-identity/),
[Network Reference Architecture](https://docs.cloudposse.com/reference-architecture/scaffolding/setup/network/), the
[GitHub OIDC component](https://docs.cloudposse.com/components/catalog/aws/github-oidc-provider/), and the
[Karpenter component](https://docs.cloudposse.com/components/catalog/aws/eks/karpenter/).

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
                --kube-reserved cpu=100m,memory=0.6Gi,ephemeral-storage=1Gi
                --system-reserved cpu=100m,memory=0.2Gi,ephemeral-storage=1Gi
                --eviction-hard memory.available<200Mi,nodefs.available<10%,imagefs.available<15%
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

:::info

Run the following command to see all available addons, their type, and their publisher. You can also see the URL for
addons that are available through the AWS Marketplace. Replace 1.27 with the version of your cluster. See
[Creating an addon](https://docs.aws.amazon.com/eks/latest/userguide/managing-add-ons.html#creating-an-add-on) for more
details.

:::

```shell
EKS_K8S_VERSION=1.29 # replace with your cluster version
aws eks describe-addon-versions --kubernetes-version $EKS_K8S_VERSION \
  --query 'addons[].{MarketplaceProductUrl: marketplaceInformation.productUrl, Name: addonName, Owner: owner Publisher: publisher, Type: type}' --output table
```

:::info

You can see which versions are available for each addon by executing the following commands. Replace 1.29 with the
version of your cluster.

:::

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

:::warning

Addons may not be suitable for all use-cases! For example, if you are deploying Karpenter to Fargate and using Karpenter
to provision all nodes, these nodes will never be available before the cluster component is deployed if you are using
the CoreDNS addon (for example).

This is one of the reasons we recommend deploying a managed node group: to ensure that the addons will become fully
functional during deployment of the cluster.

:::

For more information on upgrading EKS Addons, see
["How to Upgrade EKS Cluster Addons"](https://docs.cloudposse.com/reference-architecture/how-to-guides/upgrades/how-to-upgrade-eks-cluster-addons/)

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



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.3.0 |
| `aws` | >= 4.9.0 |
| `random` | >= 3.0 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.9.0 |
| `random` | >= 3.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`aws_ebs_csi_driver_eks_iam_role` | 2.1.1 | [`cloudposse/eks-iam-role/aws`](https://registry.terraform.io/modules/cloudposse/eks-iam-role/aws/2.1.1) | n/a
`aws_ebs_csi_driver_fargate_profile` | 1.3.0 | [`cloudposse/eks-fargate-profile/aws`](https://registry.terraform.io/modules/cloudposse/eks-fargate-profile/aws/1.3.0) | n/a
`aws_efs_csi_driver_eks_iam_role` | 2.1.1 | [`cloudposse/eks-iam-role/aws`](https://registry.terraform.io/modules/cloudposse/eks-iam-role/aws/2.1.1) | n/a
`coredns_fargate_profile` | 1.3.0 | [`cloudposse/eks-fargate-profile/aws`](https://registry.terraform.io/modules/cloudposse/eks-fargate-profile/aws/1.3.0) | n/a
`eks_cluster` | 4.1.0 | [`cloudposse/eks-cluster/aws`](https://registry.terraform.io/modules/cloudposse/eks-cluster/aws/4.1.0) | n/a
`fargate_pod_execution_role` | 1.3.0 | [`cloudposse/eks-fargate-profile/aws`](https://registry.terraform.io/modules/cloudposse/eks-fargate-profile/aws/1.3.0) | n/a
`fargate_profile` | 1.3.0 | [`cloudposse/eks-fargate-profile/aws`](https://registry.terraform.io/modules/cloudposse/eks-fargate-profile/aws/1.3.0) | ############################################################################## ## Both New and Legacy behavior, use caution when modifying ##############################################################################
`iam_arns` | latest | [`../../account-map/modules/roles-to-principals`](https://registry.terraform.io/modules/../../account-map/modules/roles-to-principals/) | n/a
`iam_roles` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`karpenter_label` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`region_node_group` | latest | [`./modules/node_group_by_region`](https://registry.terraform.io/modules/./modules/node_group_by_region/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`utils` | 1.3.0 | [`cloudposse/utils/aws`](https://registry.terraform.io/modules/cloudposse/utils/aws/1.3.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/1.5.0/submodules/remote-state) | n/a
`vpc_cni_eks_iam_role` | 2.1.1 | [`cloudposse/eks-iam-role/aws`](https://registry.terraform.io/modules/cloudposse/eks-iam-role/aws/2.1.1) | n/a
`vpc_ingress` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/1.5.0/submodules/remote-state) | n/a


## Resources

The following resources are used by this module:

  - [`aws_iam_instance_profile.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) (resource)(karpenter.tf#60)
  - [`aws_iam_policy.ipv6_eks_cni_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)(karpenter.tf#126)
  - [`aws_iam_role.karpenter`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)(karpenter.tf#51)
  - [`aws_iam_role_policy_attachment.amazon_ec2_container_registry_readonly`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)(karpenter.tf#83)
  - [`aws_iam_role_policy_attachment.amazon_eks_worker_node_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)(karpenter.tf#76)
  - [`aws_iam_role_policy_attachment.amazon_ssm_managed_instance_core`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)(karpenter.tf#69)
  - [`aws_iam_role_policy_attachment.aws_ebs_csi_driver`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)(addons.tf#154)
  - [`aws_iam_role_policy_attachment.aws_efs_csi_driver`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)(addons.tf#200)
  - [`aws_iam_role_policy_attachment.ipv6_eks_cni_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)(karpenter.tf#135)
  - [`aws_iam_role_policy_attachment.vpc_cni`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)(addons.tf#105)
  - [`random_pet.camel_case_warning`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) (resource)(eks-node-groups.tf#70)

## Data Sources

The following data sources are used by this module:

  - [`aws_availability_zones.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) (data source)
  - [`aws_iam_policy_document.assume_role`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.ipv6_eks_cni_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.vpc_cni_ipv6`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_roles.sso_roles`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) (data source)
  - [`aws_partition.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)

## Outputs

<dl>
  <dt><code>availability_zones</code></dt>
  <dd>

  
  Availability Zones in which the cluster is provisioned<br/>

  </dd>
  <dt><code>eks_addons_versions</code></dt>
  <dd>

  
  Map of enabled EKS Addons names and versions<br/>

  </dd>
  <dt><code>eks_auth_worker_roles</code></dt>
  <dd>

  
  List of worker IAM roles that were included in the `auth-map` ConfigMap.<br/>

  </dd>
  <dt><code>eks_cluster_arn</code></dt>
  <dd>

  
  The Amazon Resource Name (ARN) of the cluster<br/>

  </dd>
  <dt><code>eks_cluster_certificate_authority_data</code></dt>
  <dd>

  
  The Kubernetes cluster certificate authority data<br/>

  </dd>
  <dt><code>eks_cluster_endpoint</code></dt>
  <dd>

  
  The endpoint for the Kubernetes API server<br/>

  </dd>
  <dt><code>eks_cluster_id</code></dt>
  <dd>

  
  The name of the cluster<br/>

  </dd>
  <dt><code>eks_cluster_identity_oidc_issuer</code></dt>
  <dd>

  
  The OIDC Identity issuer for the cluster<br/>

  </dd>
  <dt><code>eks_cluster_managed_security_group_id</code></dt>
  <dd>

  
  Security Group ID that was created by EKS for the cluster. EKS creates a Security Group and applies it to ENI that is attached to EKS Control Plane master nodes and to any managed workloads<br/>

  </dd>
  <dt><code>eks_cluster_version</code></dt>
  <dd>

  
  The Kubernetes server version of the cluster<br/>

  </dd>
  <dt><code>eks_managed_node_workers_role_arns</code></dt>
  <dd>

  
  List of ARNs for workers in managed node groups<br/>

  </dd>
  <dt><code>eks_node_group_arns</code></dt>
  <dd>

  
  List of all the node group ARNs in the cluster<br/>

  </dd>
  <dt><code>eks_node_group_count</code></dt>
  <dd>

  
  Count of the worker nodes<br/>

  </dd>
  <dt><code>eks_node_group_ids</code></dt>
  <dd>

  
  EKS Cluster name and EKS Node Group name separated by a colon<br/>

  </dd>
  <dt><code>eks_node_group_role_names</code></dt>
  <dd>

  
  List of worker nodes IAM role names<br/>

  </dd>
  <dt><code>eks_node_group_statuses</code></dt>
  <dd>

  
  Status of the EKS Node Group<br/>

  </dd>
  <dt><code>fargate_profile_role_arns</code></dt>
  <dd>

  
  Fargate Profile Role ARNs<br/>

  </dd>
  <dt><code>fargate_profile_role_names</code></dt>
  <dd>

  
  Fargate Profile Role names<br/>

  </dd>
  <dt><code>fargate_profiles</code></dt>
  <dd>

  
  Fargate Profiles<br/>

  </dd>
  <dt><code>karpenter_iam_role_arn</code></dt>
  <dd>

  
  Karpenter IAM Role ARN<br/>

  </dd>
  <dt><code>karpenter_iam_role_name</code></dt>
  <dd>

  
  Karpenter IAM Role name<br/>

  </dd>
  <dt><code>vpc_cidr</code></dt>
  <dd>

  
  The CIDR of the VPC where this cluster is deployed.<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `region` (`string`) <i>required</i>


AWS Region<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>



## Optional Variables
### `access_config` <i>optional</i>


Access configuration for the EKS cluster<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   object({
    authentication_mode                         = optional(string, "API")
    bootstrap_cluster_creator_admin_permissions = optional(bool, false)
  })
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `addons` <i>optional</i>


Manages [EKS addons](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) resources<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   map(object({
    enabled       = optional(bool, true)
    addon_version = optional(string, null)
    # configuration_values is a JSON string, such as '{"computeType": "Fargate"}'.
    configuration_values = optional(string, null)
    # Set default resolve_conflicts to OVERWRITE because it is required on initial installation of
    # add-ons that have self-managed versions installed by default (e.g. vpc-cni, coredns), and
    # because any custom configuration that you would want to preserve should be managed by Terraform.
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    service_account_role_arn    = optional(string, null)
    create_timeout              = optional(string, null)
    update_timeout              = optional(string, null)
    delete_timeout              = optional(string, null)
  }))
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `addons_depends_on` (`bool`) <i>optional</i>


If set `true` (recommended), all addons will depend on managed node groups provisioned by this component and therefore not be installed until nodes are provisioned.<br/>
See [issue #170](https://github.com/cloudposse/terraform-aws-eks-cluster/issues/170) for more details.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `allow_ingress_from_vpc_accounts` (`any`) <i>optional</i>


List of account contexts to pull VPC ingress CIDR and add to cluster security group.<br/>
<br/>
e.g.<br/>
<br/>
{<br/>
  environment = "ue2",<br/>
  stage       = "auto",<br/>
  tenant      = "core"<br/>
}<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `allowed_cidr_blocks` (`list(string)`) <i>optional</i>


List of CIDR blocks to be allowed to connect to the EKS cluster<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `allowed_security_groups` (`list(string)`) <i>optional</i>


List of Security Group IDs to be allowed to connect to the EKS cluster<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `apply_config_map_aws_auth` (`bool`) <i>optional</i>


(Obsolete) Whether to execute `kubectl apply` to apply the ConfigMap to allow worker nodes to join the EKS cluster.<br/>
This input is included to avoid breaking existing configurations that set it to `true`;<br/>
a value of `false` is no longer allowed.<br/>
This input is obsolete and will be removed in a future release.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `availability_zone_abbreviation_type` (`string`) <i>optional</i>


Type of Availability Zone abbreviation (either `fixed` or `short`) to use in names. See https://github.com/cloudposse/terraform-aws-utils for details.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"fixed"</code>
>   </dd>
> </dl>
>


### `availability_zone_ids` (`list(string)`) <i>optional</i>


List of Availability Zones IDs where subnets will be created. Overrides `availability_zones`.<br/>
Can be the full name, e.g. `use1-az1`, or just the part after the AZ ID region code, e.g. `-az1`,<br/>
to allow reusable values across regions. Consider contention for resources and spot pricing in each AZ when selecting.<br/>
Useful in some regions when using only some AZs and you want to use the same ones across multiple accounts.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `availability_zones` (`list(string)`) <i>optional</i>


AWS Availability Zones in which to deploy multi-AZ resources.<br/>
Ignored if `availability_zone_ids` is set.<br/>
Can be the full name, e.g. `us-east-1a`, or just the part after the region, e.g. `a` to allow reusable values across regions.<br/>
If not provided, resources will be provisioned in every zone with a private subnet in the VPC.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `aws_ssm_agent_enabled` (`bool`) <i>optional</i>


Set true to attach the required IAM policy for AWS SSM agent to each EC2 instance's IAM Role<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `aws_sso_permission_sets_rbac` <i>optional</i>


(Not Recommended): AWS SSO (IAM Identity Center) permission sets in the EKS deployment account to add to `aws-auth` ConfigMap.<br/>
Unfortunately, `aws-auth` ConfigMap does not support SSO permission sets, so we map the generated<br/>
IAM Role ARN corresponding to the permission set at the time Terraform runs. This is subject to change<br/>
when any changes are made to the AWS SSO configuration, invalidating the mapping, and requiring a<br/>
`terraform apply` in this project to update the `aws-auth` ConfigMap and restore access.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
    aws_sso_permission_set = string
    groups                 = list(string)
  }))
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `aws_team_roles_rbac` <i>optional</i>


List of `aws-team-roles` (in the target AWS account) to map to Kubernetes RBAC groups.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
    aws_team_role = string
    groups        = list(string)
  }))
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `cluster_encryption_config_enabled` (`bool`) <i>optional</i>


Set to `true` to enable Cluster Encryption Configuration<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `cluster_encryption_config_kms_key_deletion_window_in_days` (`number`) <i>optional</i>


Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>10</code>
>   </dd>
> </dl>
>


### `cluster_encryption_config_kms_key_enable_key_rotation` (`bool`) <i>optional</i>


Cluster Encryption Config KMS Key Resource argument - enable kms key rotation<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `cluster_encryption_config_kms_key_id` (`string`) <i>optional</i>


KMS Key ID to use for cluster encryption config<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `cluster_encryption_config_kms_key_policy` (`string`) <i>optional</i>


Cluster Encryption Config KMS Key Resource argument - key policy<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `cluster_encryption_config_resources` (`list(string)`) <i>optional</i>


Cluster Encryption Config Resources to encrypt, e.g. `["secrets"]`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   [
>     "secrets"
>   ]
>   ```
>
>   </dd>
> </dl>
>


### `cluster_endpoint_private_access` (`bool`) <i>optional</i>


Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is `false`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `cluster_endpoint_public_access` (`bool`) <i>optional</i>


Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is `true`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `cluster_kubernetes_version` (`string`) <i>optional</i>


Desired Kubernetes master version. If you do not specify a value, the latest available version is used<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `cluster_log_retention_period` (`number`) <i>optional</i>


Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>0</code>
>   </dd>
> </dl>
>


### `cluster_private_subnets_only` (`bool`) <i>optional</i>


Whether or not to enable private subnets or both public and private subnets<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `color` (`string`) <i>optional</i>


The cluster stage represented by a color; e.g. blue, green<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `deploy_addons_to_fargate` (`bool`) <i>optional</i>


Set to `true` (not recommended) to deploy addons to Fargate instead of initial node pool<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `enabled_cluster_log_types` (`list(string)`) <i>optional</i>


A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `fargate_profile_iam_role_kubernetes_namespace_delimiter` (`string`) <i>optional</i>


Delimiter for the Kubernetes namespace in the IAM Role name for Fargate Profiles<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"-"</code>
>   </dd>
> </dl>
>


### `fargate_profile_iam_role_permissions_boundary` (`string`) <i>optional</i>


If provided, all Fargate Profiles IAM roles will be created with this permissions boundary attached<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `fargate_profiles` <i>optional</i>


Fargate Profiles config<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   map(object({
    kubernetes_namespace = string
    kubernetes_labels    = map(string)
  }))
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `karpenter_iam_role_enabled` (`bool`) <i>optional</i>


Flag to enable/disable creation of IAM role for EC2 Instance Profile that is attached to the nodes launched by Karpenter<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `legacy_do_not_create_karpenter_instance_profile` (`bool`) <i>optional</i>


**Obsolete:** The issues this was meant to mitigate were fixed in AWS Terraform Provider v5.43.0<br/>
and Karpenter v0.33.0. This variable will be removed in a future release.<br/>
Remove this input from your configuration and leave it at default.<br/>
**Old description:** When `true` (the default), suppresses creation of the IAM Instance Profile<br/>
for nodes launched by Karpenter, to preserve the legacy behavior of<br/>
the `eks/karpenter` component creating it.<br/>
Set to `false` to enable creation of the IAM Instance Profile, which<br/>
ensures that both the role and the instance profile have the same lifecycle,<br/>
and avoids AWS Provider issue [#32671](https://github.com/hashicorp/terraform-provider-aws/issues/32671).<br/>
Use in conjunction with `eks/karpenter` component `legacy_create_karpenter_instance_profile`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `legacy_fargate_1_role_per_profile_enabled` (`bool`) <i>optional</i>


Set to `false` for new clusters to create a single Fargate Pod Execution role for the cluster.<br/>
Set to `true` for existing clusters to preserve the old behavior of creating<br/>
a Fargate Pod Execution role for each Fargate Profile.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `managed_node_groups_enabled` (`bool`) <i>optional</i>


Set false to prevent the creation of EKS managed node groups.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `map_additional_aws_accounts` (`list(string)`) <i>optional</i>


(Obsolete) Additional AWS accounts to grant access to the EKS cluster.<br/>
This input is included to avoid breaking existing configurations that<br/>
supplied an empty list, but the list is no longer allowed to have entries.<br/>
(It is not clear that it worked properly in earlier versions in any case.)<br/>
This component now only supports EKS access entries, which require full principal ARNs.<br/>
This input is deprecated and will be removed in a future release.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `map_additional_iam_roles` <i>optional</i>


Additional IAM roles to grant access to the cluster.<br/>
*WARNING*: Full Role ARN, including path, is required for `rolearn`.<br/>
In earlier versions (with `aws-auth` ConfigMap), only the path<br/>
had to be removed from the Role ARN. The path is now required.<br/>
`username` is now ignored. This input is planned to be replaced<br/>
in a future release with a more flexible input structure that consolidates<br/>
`map_additional_iam_roles` and `map_additional_iam_users`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
    rolearn  = string
    username = optional(string)
    groups   = list(string)
  }))
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `map_additional_iam_users` <i>optional</i>


Additional IAM roles to grant access to the cluster.<br/>
`username` is now ignored. This input is planned to be replaced<br/>
in a future release with a more flexible input structure that consolidates<br/>
`map_additional_iam_roles` and `map_additional_iam_users`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
    userarn  = string
    username = optional(string)
    groups   = list(string)
  }))
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `map_additional_worker_roles` (`list(string)`) <i>optional</i>


(Deprecated) AWS IAM Role ARNs of unmanaged Linux worker nodes to grant access to the EKS cluster.<br/>
In earlier versions, this could be used to grant access to worker nodes of any type<br/>
that were not managed by the EKS cluster. Now EKS requires that unmanaged worker nodes<br/>
be classified as Linux or Windows servers, in this input is temporarily retained<br/>
with the assumption that all worker nodes are Linux servers. (It is likely that<br/>
earlier versions did not work properly with Windows worker nodes anyway.)<br/>
This input is deprecated and will be removed in a future release.<br/>
In the future, this component will either have a way to separate Linux and Windows worker nodes,<br/>
or drop support for unmanaged worker nodes entirely.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `node_group_defaults` <i>optional</i>


Defaults for node groups in the cluster<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   object({
    ami_release_version        = optional(string, null)
    ami_type                   = optional(string, null)
    attributes                 = optional(list(string), null)
    availability_zones         = optional(list(string)) # set to null to use var.availability_zones
    cluster_autoscaler_enabled = optional(bool, null)
    create_before_destroy      = optional(bool, null)
    desired_group_size         = optional(number, null)
    instance_types             = optional(list(string), null)
    kubernetes_labels          = optional(map(string), {})
    kubernetes_taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    node_userdata = optional(object({
      before_cluster_joining_userdata = optional(string)
      bootstrap_extra_args            = optional(string)
      kubelet_extra_args              = optional(string)
      after_cluster_joining_userdata  = optional(string)
    }), {})
    kubernetes_version = optional(string, null) # set to null to use cluster_kubernetes_version
    max_group_size     = optional(number, null)
    min_group_size     = optional(number, null)
    resources_to_tag   = optional(list(string), null)
    tags               = optional(map(string), null)

    # block_device_map copied from cloudposse/terraform-aws-eks-node-group
    # Keep in sync via copy and paste, but make optional
    # Most of the time you want "/dev/xvda". For BottleRocket, use "/dev/xvdb".
    block_device_map = optional(map(object({
      no_device    = optional(bool, null)
      virtual_name = optional(string, null)
      ebs = optional(object({
        delete_on_termination = optional(bool, true)
        encrypted             = optional(bool, true)
        iops                  = optional(number, null)
        kms_key_id            = optional(string, null)
        snapshot_id           = optional(string, null)
        throughput            = optional(number, null) # for gp3, MiB/s, up to 1000
        volume_size           = optional(number, 50)   # disk  size in GB
        volume_type           = optional(string, "gp3")

        # Catch common camel case typos. These have no effect, they just generate better errors.
        # It would be nice to actually use these, but volumeSize in particular is a number here
        # and in most places it is a string with a unit suffix (e.g. 20Gi)
        # Without these defined, they would be silently ignored and the default values would be used instead,
        # which is difficult to debug.
        deleteOnTermination = optional(any, null)
        kmsKeyId            = optional(any, null)
        snapshotId          = optional(any, null)
        volumeSize          = optional(any, null)
        volumeType          = optional(any, null)
      }))
    })), null)

    # DEPRECATED: disk_encryption_enabled is DEPRECATED, use `block_device_map` instead.
    disk_encryption_enabled = optional(bool, null)
    # DEPRECATED: disk_size is DEPRECATED, use `block_device_map` instead.
    disk_size = optional(number, null)
  })
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   {
>     "block_device_map": {
>       "/dev/xvda": {
>         "ebs": {
>           "encrypted": true,
>           "volume_size": 20,
>           "volume_type": "gp2"
>         }
>       }
>     },
>     "desired_group_size": 1,
>     "instance_types": [
>       "t3.medium"
>     ],
>     "kubernetes_version": null,
>     "max_group_size": 100
>   }
>   ```
>
>   </dd>
> </dl>
>


### `node_groups` <i>optional</i>


List of objects defining a node group for the cluster<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   map(object({
    # EKS AMI version to use, e.g. "1.16.13-20200821" (no "v").
    ami_release_version = optional(string, null)
    # Type of Amazon Machine Image (AMI) associated with the EKS Node Group
    ami_type = optional(string, null)
    # Additional attributes (e.g. `1`) for the node group
    attributes = optional(list(string), null)
    # will create 1 auto scaling group in each specified availability zone
    # or all AZs with subnets if none are specified anywhere
    availability_zones = optional(list(string), null)
    # Whether to enable Node Group to scale its AutoScaling Group
    cluster_autoscaler_enabled = optional(bool, null)
    # True to create new node_groups before deleting old ones, avoiding a temporary outage
    create_before_destroy = optional(bool, null)
    # Desired number of worker nodes when initially provisioned
    desired_group_size = optional(number, null)
    # Set of instance types associated with the EKS Node Group. Terraform will only perform drift detection if a configuration value is provided.
    instance_types = optional(list(string), null)
    # Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed
    kubernetes_labels = optional(map(string), null)
    # List of objects describing Kubernetes taints.
    kubernetes_taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), null)
    node_userdata = optional(object({
      before_cluster_joining_userdata = optional(string)
      bootstrap_extra_args            = optional(string)
      kubelet_extra_args              = optional(string)
      after_cluster_joining_userdata  = optional(string)
    }), {})
    # Desired Kubernetes master version. If you do not specify a value, the latest available version is used
    kubernetes_version = optional(string, null)
    # The maximum size of the AutoScaling Group
    max_group_size = optional(number, null)
    # The minimum size of the AutoScaling Group
    min_group_size = optional(number, null)
    # List of auto-launched resource types to tag
    resources_to_tag = optional(list(string), null)
    tags             = optional(map(string), null)

    # block_device_map copied from cloudposse/terraform-aws-eks-node-group
    # Keep in sync via copy and paste, but make optional.
    # Most of the time you want "/dev/xvda". For BottleRocket, use "/dev/xvdb".
    block_device_map = optional(map(object({
      no_device    = optional(bool, null)
      virtual_name = optional(string, null)
      ebs = optional(object({
        delete_on_termination = optional(bool, true)
        encrypted             = optional(bool, true)
        iops                  = optional(number, null)
        kms_key_id            = optional(string, null)
        snapshot_id           = optional(string, null)
        throughput            = optional(number, null) # for gp3, MiB/s, up to 1000
        volume_size           = optional(number, 20)   # Disk size in GB
        volume_type           = optional(string, "gp3")

        # Catch common camel case typos. These have no effect, they just generate better errors.
        # It would be nice to actually use these, but volumeSize in particular is a number here
        # and in most places it is a string with a unit suffix (e.g. 20Gi)
        # Without these defined, they would be silently ignored and the default values would be used instead,
        # which is difficult to debug.
        deleteOnTermination = optional(any, null)
        kmsKeyId            = optional(any, null)
        snapshotId          = optional(any, null)
        volumeSize          = optional(any, null)
        volumeType          = optional(any, null)
      }))
    })), null)

    # DEPRECATED:
    # Enable disk encryption for the created launch template (if we aren't provided with an existing launch template)
    # DEPRECATED: disk_encryption_enabled is DEPRECATED, use `block_device_map` instead.
    disk_encryption_enabled = optional(bool, null)
    # Disk size in GiB for worker nodes. Terraform will only perform drift detection if a configuration value is provided.
    # DEPRECATED: disk_size is DEPRECATED, use `block_device_map` instead.
    disk_size = optional(number, null)

  }))
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `oidc_provider_enabled` (`bool`) <i>optional</i>


Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using kiam or kube2iam. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `public_access_cidrs` (`list(string)`) <i>optional</i>


Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   [
>     "0.0.0.0/0"
>   ]
>   ```
>
>   </dd>
> </dl>
>


### `subnet_type_tag_key` (`string`) <i>optional</i>


The tag used to find the private subnets to find by availability zone. If null, will be looked up in vpc outputs.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `vpc_component_name` (`string`) <i>optional</i>


The name of the vpc component<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"vpc"</code>
>   </dd>
> </dl>
>



## Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>


### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `attributes` (`list(string)`) <i>optional</i>


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `context` (`any`) <i>optional</i>


Single object for setting entire context at once.<br/>
See description of individual variables for details.<br/>
Leave string and numeric variables as `null` to use default value.<br/>
Individual variable settings (non-null) override settings in context object,<br/>
except for attributes, tags, and additional_tag_map, which are merged.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   {
>     "additional_tag_map": {},
>     "attributes": [],
>     "delimiter": null,
>     "descriptor_formats": {},
>     "enabled": true,
>     "environment": null,
>     "id_length_limit": null,
>     "label_key_case": null,
>     "label_order": [],
>     "label_value_case": null,
>     "labels_as_tags": [
>       "unset"
>     ],
>     "name": null,
>     "namespace": null,
>     "regex_replace_chars": null,
>     "stage": null,
>     "tags": {},
>     "tenant": null
>   }
>   ```
>
>   </dd>
> </dl>
>


### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `descriptor_formats` (`any`) <i>optional</i>


Describe additional descriptors to be output in the `descriptors` output map.<br/>
Map of maps. Keys are names of descriptors. Values are maps of the form<br/>
`{<br/>
   format = string<br/>
   labels = list(string)<br/>
}`<br/>
(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>
`format` is a Terraform format string to be passed to the `format()` function.<br/>
`labels` is a list of labels, in order, to pass to `format()` function.<br/>
Label values will be normalized before being passed to `format()` so they will be<br/>
identical to how they appear in `id`.<br/>
Default is `{}` (`descriptors` output will be empty).<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `enabled` (`bool`) <i>optional</i>


Set to false to prevent the module from creating any resources<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `environment` (`string`) <i>optional</i>


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
Does not affect `id_full`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_key_case` (`string`) <i>optional</i>


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper`.<br/>
Default value: `title`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_order` (`list(string)`) <i>optional</i>


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_value_case` (`string`) <i>optional</i>


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
Default value: `lower`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `labels_as_tags` (`set(string)`) <i>optional</i>


Set of labels (ID elements) to include as tags in the `tags` output.<br/>
Default is to include all labels.<br/>
Tags with empty values will not be included in the `tags` output.<br/>
Set to `[]` to suppress all generated tags.<br/>
**Notes:**<br/>
  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
  changed in later chained modules. Attempts to change it will be silently ignored.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>set(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   [
>     "default"
>   ]
>   ```
>
>   </dd>
> </dl>
>


### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `regex_replace_chars` (`string`) <i>optional</i>


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `stage` (`string`) <i>optional</i>


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## Related How-to Guides

- [How to Load Test in AWS](https://docs.cloudposse.com/reference-architecture/how-to-guides/tutorials/how-to-load-test-in-aws)
- [How to Tune EKS with AWS Managed Node Groups](https://docs.cloudposse.com/reference-architecture/how-to-guides/tutorials/how-to-tune-eks-with-aws-managed-node-groups)
- [How to Keep Everything Up to Date](https://docs.cloudposse.com/reference-architecture/how-to-guides/upgrades/how-to-keep-everything-up-to-date)
- [How to Tune SpotInst Parameters for EKS](https://docs.cloudposse.com/reference-architecture/how-to-guides/tutorials/how-to-tune-spotinst-parameters-for-eks)
- [How to Upgrade EKS Cluster Addons](https://docs.cloudposse.com/reference-architecture/how-to-guides/upgrades/how-to-upgrade-eks-cluster-addons)
- [How to Upgrade EKS](https://docs.cloudposse.com/reference-architecture/how-to-guides/upgrades/how-to-upgrade-eks)
- [EBS CSI Migration FAQ](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi-migration-faq.html)

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/eks/cluster) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
