# CHANGELOG

## 1.510.0



<details>
  <summary>`bugfix` ECS Service to use Datadog-Configuration Component #1135 @Benbentwo (#1138)</summary>
## what

* ECS Service to use Datadog-Configuration Component

## why

* Regression from #810 
* Several Customers & PRs were incoming and ECS Service Component missed an opportunity to merge new functionality. 
* No component anymore called `datadog_keys`

## references

 - #810 
 - #1135 
</details>

<details>
  <summary>Update Changelog for `1.509.0` @github-actions (#1137)</summary>
Update Changelog for [`1.509.0`](https://github.com/cloudposse/terraform-aws-components/releases/tag/1.509.0)
</details>



## 1.509.0



<details>
  <summary>Restore Datadog-Configuration Support @Benbentwo (#1135)</summary>
## what

* ECS Service to use Datadog-Configuration Component

## why

* Regression from #810 
* Several Customers & PRs were incoming and ECS Service Component missed an opportunity to merge new functionality. 
* No component anymore called `datadog_keys`

## references

 - #810 

</details>

<details>
  <summary>Update Changelog for `1.508.0` @github-actions (#1134)</summary>
Update Changelog for [`1.508.0`](https://github.com/cloudposse/terraform-aws-components/releases/tag/1.508.0)
</details>



## 1.508.0



<details>
  <summary>chore(account-settings): upgrades budgets child-module to 0.5.1 @Gowiem (#1133)</summary>
## what

* Upgrades `terraform-aws-budgets` submodule usage in account-settings to 0.5.1

## why

* This enables passing `subscriber_email_addresses` to budgets for receiving emails

## references

* See fix in https://github.com/cloudposse/terraform-aws-budgets/pull/51
</details>

<details>
  <summary>Update Changelog for `1.507.1` @github-actions (#1132)</summary>
Update Changelog for [`1.507.1`](https://github.com/cloudposse/terraform-aws-components/releases/tag/1.507.1)
</details>



## 1.507.1



<details>
  <summary>Update Changelog for `1.506.0` @github-actions (#1130)</summary>
Update Changelog for [`1.506.0`](https://github.com/cloudposse/terraform-aws-components/releases/tag/1.506.0)
</details>


## 🚀 Enhancements

<details>
  <summary>mq-broker: upgrade versions @johncblandii (#602)</summary>
## what
* Upgraded to the latest `terraform-aws-mq-broker`
* Updated the `providers` to match the common pattern
* Updated the module versions

## why
* The component was dated

## references



</details>



## 1.506.0



<details>
  <summary>Add scheduled overrides feature @oleksiimorozenko (#750)</summary>
## what
* This pull request adds the scheduled overrides feature supported by ARC

## why
* It could be useful for pre-scaling during work hours and downscaling respectively when a work time ends coming back to `minReplicas`

## references
* Scheduled overrides section in [ARC Automatically scaling runners documentation](https://github.com/actions/actions-runner-controller/blob/master/docs/automatically-scaling-runners.md#scheduled-overrides)


</details>

<details>
  <summary>Update Changelog for `1.505.0` @github-actions (#1129)</summary>
Update Changelog for [`1.505.0`](https://github.com/cloudposse/terraform-aws-components/releases/tag/1.505.0)
</details>



## 1.505.0



<details>
  <summary>fix: account-quota drift reduced @dudymas (#1102)</summary>
## what

- encode values into a `for_each` on service quota resources

## why

- terraform sometimes gets bad state back from the AWS API, so fetched results
ought to be ignored. Instead, input values should be respected as truth.

## references

- AWS CLI
  [command to list service quotas](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/service-quotas/list-service-quotas.html) `aws service-quotas list-service-quotas`.
   Note where it says "For some quotas, only the default values are available."
- [Medium article](https://medium.com/@jsonk/the-limit-does-not-exist-hidden-visibility-of-aws-service-limits-4b786f846bc0)
  explaining how many AWS service limits are not available.


</details>

<details>
  <summary>Update Changelog for `1.504.0` @github-actions (#1128)</summary>
Update Changelog for [`1.504.0`](https://github.com/cloudposse/terraform-aws-components/releases/tag/1.504.0)
</details>



## 1.504.0



<details>
  <summary>feat: allow vulnerability scanning of Argo repository and implement ignore changes for non-change drift @RoseSecurity (#1120)</summary>
## what

- Attempted to refactor code to ensure changes don't occur on each run (did not resolve)
- Opened an issue with [GitHub](https://github.com/integrations/terraform-provider-github/issues/2243) but is still in the triaging state
- This is a quick fix for addressing the following non-change

```console
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # github_branch_protection.default[0] will be updated in-place
  ~ resource "github_branch_protection" "default" {
        id                              = "XXXXXXX"
        # (10 unchanged attributes hidden)

      ~ restrict_pushes {
          ~ push_allowances  = [
              + "XXXXXXX",
            ]
```

## why

- [X] Adds lifecycle meta-argument for ignoring changes to `push_allowances`
- [X] Enable vulnerability alerting for vulnerable dependencies by default to address `tfsec` findings

## Testing

- [X] Validated with `atmos validate stacks` 
- [X] Performed successful `atmos terraform deploy` on component

</details>

<details>
  <summary>Update Changelog for `1.502.0` @github-actions (#1126)</summary>
Update Changelog for [`1.502.0`](https://github.com/cloudposse/terraform-aws-components/releases/tag/1.502.0)
</details>



## 1.502.0



<details>
  <summary>upstream `tailscale` @Benbentwo (#835)</summary>
## what
* Initial Tailscale deployment

## why
* tailscale operators

## references
* https://github.com/tailscale/tailscale/tree/main/docs/k8s

</details>

<details>
  <summary>Update Changelog for `1.501.0` @github-actions (#1125)</summary>
Update Changelog for [`1.501.0`](https://github.com/cloudposse/terraform-aws-components/releases/tag/1.501.0)
</details>

<details>
  <summary>docs: improve external-dns snippet in readme @sgtoj (#986)</summary>
## what

- update the `eks/external-dns` component example in readme
    - set latest chart version
    - set the resource configure properly
    - add `txt_prefix` var to snippet

## why

- help the future engineers deploying or updating external-dns

## references

- n/a

</details>

<details>
  <summary>Update Changelog for `1.500.0` @github-actions (#1124)</summary>
Update Changelog for [`1.500.0`](https://github.com/cloudposse/terraform-aws-components/releases/tag/1.500.0)
</details>



## 1.501.0

<details>
  <summary>Fix release changelog space issue @goruha (#1122)</summary>
## what
* Fix release changelog space issue

![CleanShot 2024-10-01 at 12 27 42@2x](https://github.com/user-attachments/assets/2d42740a-1d5d-4990-94ac-eb49bdfe4c32)

## why
* Have nice changelog

## references
* https://github.com/cloudposse/terraform-aws-components/pull/1117/files#diff-06572a96a58dc510037d5efa622f9bec8519bc1beab13c9f251e97e657a9d4edR10


## 1.500.0



## Affected Components
- [eks/argocd](https://docs.cloudposse.com/components/library/aws/eks/argocd#changelog)
- [eks/cluster](https://docs.cloudposse.com/components/library/aws/eks/cluster#changelog)
- [eks/datadog-agent](https://docs.cloudposse.com/components/library/aws/eks/datadog-agent#changelog)
- [eks/github-actions-runner](https://docs.cloudposse.com/components/library/aws/eks/github-actions-runner#changelog)
- [spa-s3-cloudfront](https://docs.cloudposse.com/components/library/aws/spa-s3-cloudfront#changelog)


<details>
  <summary>add additional waf features @mcalhoun (#791)</summary>

  ## what
* Add the ability to specify a list of ALBs to attach WAF to
* Add the ability to specify a list of tags to target ALBs to attach WAF to

## why
* To provider greater flexibility in attaching WAF to ALBs
</details>

<details>
  <summary>Update Changelog for `1.499.0` @github-actions (#1123)</summary>

  Update Changelog for [`1.499.0`](https://github.com/cloudposse/terraform-aws-components/releases/tag/1.499.0)
</details>

<details>
  <summary>docs: fix typos using `codespell` @RoseSecurity (#1114)</summary>

  ## what and why

> [!NOTE]
> Feel free to close this PR if the changes are not worth the review. I won't be offended

- For context, I wanted to clean up some of the documentation in our repository, which identified several typos in our variables and READMEs. I decided to use `codespell` to automate this process and thought it might be useful for a quick cleanup here!

### usage

```sh
codespell -w
```

</details>



## 1.499.0



<details>
  <summary>feat: add detector features to guard duty component @dudymas (#1112)</summary>

  ## what

- add detector features to guard duty

## why

- added functionality

## references

- [Detector Feature API](https://docs.aws.amazon.com/guardduty/latest/APIReference/API_DetectorFeatureConfiguration.html)

</details>

<details>
  <summary>Update Changelog for `1.497.0` @github-actions (#1117)</summary>

  Update Changelog for [`1.497.0`](https://github.com/cloudposse/terraform-aws-components/releases/tag/1.497.0)
</details>



## 1.497.0



<details>
  <summary>Fix Update changelog workflow @goruha (#1116)</summary>

  ## what
* Fix modules path from `components/terraform` to `modules`

## why 
* It seems that `components/terraform` was testing value. In actual repo components are in `modules` directory

## references
* DEV-2556 Investigate release issues with terraform-aws-components
</details>



## 1.298.0 (2023-08-28T20:56:25Z)

<details>
  <summary>Aurora Postgres Engine Options @milldr (#845)</summary>

### what

- Add scaling configuration variables for both Serverless and Serverless v2 to `aurora-postgres`
- Update `aurora-postgres` README

### why

- Support both serverless options
- Add an explanation for how to configure each, and where to find valid engine options

### references

- n/a

</details>

## 1.297.0 (2023-08-28T18:06:11Z)

<details>
  <summary>AWS provider V5 dependency updates @max-lobur (#729)</summary>

### what

- Update component dependencies for the AWS provider V5

Requested components:

- cloudtrail-bucket
- config-bucket
- datadog-logs-archive
- eks/argocd
- eks/efs-controller
- eks/metric-server
- spacelift-worker-pool
- eks/external-secrets-operator

### why

- Maintenance

</details>

## 1.296.0 (2023-08-28T16:24:05Z)

<details>
  <summary>datadog agent update defaults @Benbentwo (#839)</summary>

### what

- prevent fargate agents
- use sockets instead of ports for APM
- enable other services

### why

- Default Datadog APM enabled over k8s

### references

</details>

## 1.295.0 (2023-08-26T00:51:10Z)

<details>
  <summary>TGW FAQ and Spoke Alternate VPC Support @milldr (#840)</summary>

### what

- Added FAQ to the TGW upgrade guide for replacing attachments
- Added note about destroying TGW components
- Added option to not create TGW propagation and association when connecting an alternate VPC

### why

- When connecting an alternate VPC in the same region as the primary VPC, we do not want to create a duplicate TGW
  propagation and association

### references

- n/a

</details>

## 1.294.0 (2023-08-26T00:07:42Z)

<details>
  <summary>Aurora Upstream: Serverless, Tags, Enabled: False @milldr (#841)</summary>

### what

- Set `module.context` to `module.cluster` across all resources
- Only set parameter for replica if cluster size is > 0
- `enabled: false` support

### why

- Missing tags for SSM parameters for cluster attributes
- Serverless clusters set `cluster_size: 0`, which will break the SSM parameter for replica hostname (since it does not
  exist)
- Support enabled false for `aurora-*-resources` components

### references

- n/a

</details>

## 1.293.2 (2023-08-24T15:50:53Z)

### 🚀 Enhancements

<details>
  <summary>Update `root_stack` output in `modules/spacelift/admin-stack/outputs.tf` @aknysh (#837)</summary>

### what

- Update `root_stack` output in `modules/spacelift/admin-stack/outputs.tf`

### why

- Fix the issue described in https://github.com/cloudposse/terraform-aws-components/issues/771

### related

- Closes https://github.com/cloudposse/terraform-aws-components/issues/771

</details>

## 1.293.1 (2023-08-24T11:24:46Z)

### 🐛 Bug Fixes

<details>
  <summary>[spacelift/worker-pool] Update providers.tf nesting @Nuru (#834)</summary>

### what

- Update relative path to `account-map` in `spacelift/worker-pool/providers.tf`

### why

- Fixes #828

</details>

## 1.293.0 (2023-08-23T01:18:53Z)

<details>
  <summary>Add visibility to default VPC component name @milldr (#833)</summary>

### what

- Set the default component name for `vpc` in variables, not remote-state

### why

- Bring visibility to where the default is set

### references

- Follow up on comments on #832

</details>

## 1.292.0 (2023-08-22T21:33:18Z)

<details>
  <summary>Aurora Optional `vpc` Component Names @milldr (#832)</summary>

### what

- Allow optional VPC component names in the aurora components

### why

- Support deploying the clusters for other VPC components than `"vpc"`

### references

- n/a

</details>

## 1.291.1 (2023-08-22T20:25:17Z)

### 🐛 Bug Fixes

<details>
  <summary>[aws-sso] Fix root provider, restore `SetSourceIdentity` permission @Nuru (#830)</summary>

### what

For `aws-sso`:

- Fix root provider, improperly restored in #740
- Restore `SetSourceIdentity` permission inadvertently removed in #740

### why

- When deploying to `identity`, `root` provider did not reference `root` account
- Likely unintentional removal due to merge error

### references

- #740
- #738

</details>

## 1.291.0 (2023-08-22T17:08:27Z)

<details>
  <summary>chore: remove defaults from components @dudymas (#831)</summary>

### what

- remove `defaults.auto.tfvars` from component modules

### why

- in favor of drying up configuration using atmos

### Notes

- Some defaults may not be captured yet. Regressions might occur.

</details>

## 1.290.0 (2023-08-21T18:57:43Z)

<details>
  <summary>Upgrade aws-config and conformance pack modules to 1.1.0 @johncblandii (#829)</summary>

### what

- Upgrade aws-config and conformance pack modules to 1.1.0

### why

- They're outdated.

### references

- #771

</details>

## 1.289.2 (2023-08-21T08:53:08Z)

### 🐛 Bug Fixes

<details>
  <summary>[eks/alb-controller] Fix naming convention of overridable local variable @Nuru (#826)</summary>

### what

- [eks/alb-controller] Change name of local variable from `distributed_iam_policy_overridable` to
  `overridable_distributed_iam_policy`

### why

- Cloud Posse style guide requires `overridable` as prefix, not suffix.

</details>

## 1.289.1 (2023-08-19T05:20:26Z)

### 🐛 Bug Fixes

<details>
  <summary>[eks/alb-controller] Update ALB controller IAM policy @Nuru (#821)</summary>

### what

- [eks/alb-controller] Update ALB controller IAM policy

### why

- Previous policy had error preventing the creation of the ELB service-linked role

</details>

## 1.289.0 (2023-08-18T20:18:12Z)

<details>
  <summary>Spacelift Alternate git Providers @milldr (#825)</summary>

### what

- set alternate git provider blocks to filter under `settings.spacelift`

### why

- Debugging GitLab support specifically
- These settings should be defined under `settings.spacelift`, not as a top-level configuration

### references

- n/a

</details>

## 1.288.0 (2023-08-18T15:12:16Z)

<details>
  <summary>Placeholder for `upgrade-guide.md` @milldr (#823)</summary>

### what

- Added a placeholder file for `docs/upgrade-guide.md` with a basic explanation of what is to come

### why

- With #811 we moved the contents of this upgrade-guide file to the individual component. We plan to continue adding
  upgrade guides for individual components, and in addition, create a higher-level upgrade guide here
- However, the build steps for refarch-scaffold expect `docs/upgrade-guide.md` to exist and are failing without it. We
  need a placeholder until the `account-map`, etc changes are added to this file

### references

- Example of failing release: https://github.com/cloudposse/refarch-scaffold/actions/runs/5885022872

</details>

## 1.287.2 (2023-08-18T14:42:49Z)

### 🚀 Enhancements

<details>
  <summary>update boolean logic @mcalhoun (#822)</summary>

### what

- Update the GuardDuty component to enable GuardDuty on the root account

### why

The API call to designate organization members now fails with the following if GuardDuty was not already enabled in the
organization management (root) account :

```
Error: error designating guardduty administrator account members: [{
│   AccountId: "111111111111,
│   Result: "Operation failed because your organization master must first enable GuardDuty to be added as a member"
│ }]
```

</details>

## 1.287.1 (2023-08-17T16:41:24Z)

### 🚀 Enhancements

<details>
  <summary>chore: Remove unused
 @MaxymVlasov (#818)</summary>

# why

```
TFLint in components/terraform/eks/cluster/:
2 issue(s) found:

Warning: [Fixable] local.identity_account_name is declared but not used (terraform_unused_declarations)

  on main.tf line 9:
   9:   identity_account_name = module.iam_roles.identity_account_account_name

Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.4.0/docs/rules/terraform_unused_declarations.md

Warning: [Fixable] variable "aws_teams_rbac" is declared but not used (terraform_unused_declarations)

  on variables.tf line 117:
 117: variable "aws_teams_rbac" {

Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.4.0/docs/rules/terraform_unused_declarations.md
```

</details>

## 1.287.0 (2023-08-17T15:52:57Z)

<details>
  <summary>Update `remote-states` modules to the latest version @aknysh (#820)</summary>

### what

- Update `remote-states` modules to the latest version

### why

- `remote-state` version `1.5.0` uses the latest version of `terraform-provider-utils` which uses the latest version of
  Atmos with many new features and improvements

</details>

## 1.286.0 (2023-08-17T05:49:45Z)

<details>
  <summary>Update cloudposse/utils/aws to 1.3.0 @RoseSecurity (#815)</summary>

### What:

- Updated the following to utilize the newest version of `cloudposse/utils/aws`:

```
0.8.1 modules/spa-s3-cloudfront
1.1.0 modules/aws-config
1.1.0 modules/datadog-configuration/modules/datadog_keys
1.1.0 modules/dns-delegated
```

### Why:

- `cloudposse/utils/aws` components were not updated to `1.3.0`

### References:

- [AWS Utils](https://github.com/cloudposse/terraform-aws-utils/releases/tag/1.3.0)

</details>

## 1.285.0 (2023-08-17T05:49:09Z)

<details>
  <summary>Update api-gateway-account-settings README.md @johncblandii (#819)</summary>

### what

- Updated the title

### why

- It was an extra helping of copy/pasta

### references

</details>

## 1.284.0 (2023-08-17T02:10:47Z)

<details>
  <summary>Datadog upgrades @Nuru (#814)</summary>

### what

- Update Datadog components:
  - `eks/datadog-agent` see `eks/datadog-agent/CHANGELOG.md`
  - `datadog-configuration` better handling of `enabled = false`
  - `datadog-integration` move "module count" back to "module" for better compatibility and maintainability, see
    `datadog-integration/CHANGELOG.md`
  - `datadog-lambda-forwared` fix issues around `enable = false` and incomplete destruction of resources (particularly
    log groups) see `datadog-lambda-forwarder/CHANGELOG.md`
  - Cleanup `datadog-monitor` see `datadog-monitor/CHANGELOG.md` for details. Possible breaking change in that several
    inputs have been removed, but they were previously ignored anyway, so no infrastructure change should result from
    you simply removing any inputs you had for the removed inputs.
  - Update `datadog-sythetics` dependency `remote-state` version
  - `datadog-synthetics-private-location` migrate control of namespace to `helm-release` module. Possible destruction
    and recreation of component on upgrade. See CHANGELOG.md

### why

- More reliable deployments, especially when destroying or disabling them
- Bug fixes and new features

</details>

## 1.283.0 (2023-08-16T17:23:39Z)

<details>
  <summary>Update EC2-Autoscale-Group Modules to 0.35.1 @RoseSecurity (#809)</summary>

### What:

- Updated `modules/spacelift/worker-pool` from 0.34.2 to 0.35.1 and adapted new variable features
- Updated `modules/bastion` from 0.35.0 to 0.35.1
- Updated `modules/github-runners` from 0.35.0 to 0.35.1

### Why:

- Modules were utilizing previous `ec2-autoscale-group` versions

### References:

- [terraform-aws-ec2-autoscale-group](https://github.com/cloudposse/terraform-aws-ec2-autoscale-group/blob/main/variables.tf)
- [Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#instance_refresh)

</details>

<details>
  <summary>Update storage-class efs component documentation @max-lobur (#817)</summary>

### what

- Update storage-class efs component defaults

### why

- Follow component move outside of eks dir

</details>

## 1.282.1 (2023-08-15T21:48:02Z)

### 🐛 Bug Fixes

<details>
  <summary>Karpenter bugfix, EKS add-ons to managed node group @Nuru (#816)</summary>

### what

- [eks/karpenter] use Instance Profile name from EKS output
- Clarify recommendation and fix defaults regarding deploying add-ons to managed node group

### why

- Bug fix: Karpenter did not work when legacy mode disabled
- Originally we expected to use Karpenter-only clusters and the documentation and defaults aligned with this. Now we
  recommend all Add-Ons be deployed to a managed node group, but the defaults and documentation did not reflect this.

</details>

## 1.282.0 (2023-08-14T16:05:08Z)

<details>
  <summary>Upstream the latest ecs-service module @goruha (#810)</summary>

### what

- Upstream the latest `ecs-service` component

### why

- Support ecspresso deployments
- Support s3 task definition mirroring
- Support external ALB/NLN components

</details>

## 1.281.0 (2023-08-14T09:10:42Z)

<details>
  <summary>Refactor Changelog @milldr (#811)</summary>

### what

- moved changelog for individual components
- changed title

### why

- Title changelogs consistently by components version
- Separate changes by affected components

### references

- https://github.com/cloudposse/knowledge-base/discussions/132

</details>

## 1.280.1 (2023-08-14T08:06:42Z)

### 🚀 Enhancements

<details>
  <summary>Fix eks/cluster default values @Nuru (#813)</summary>

### what

- Fix eks/cluster `node_group_defaults` to default to legal (empty) values for `kubernetes_labels` and
  `kubernetes_taints`
- Increase eks/cluster managed node group default disk size from 20 to 50 GB

### why

- Default values should be legal values or else they are not really defaults
- Nodes were running out of disk space just hosting daemon set pods at 20 GB

</details>

## 1.280.0 (2023-08-11T20:13:45Z)

<details>
  <summary>Updated ssm parameter versions @RoseSecurity (#812)</summary>

### Why:

- `cloudposse/ssm-parameter-store/aws` was out of date
- There are no new [changes](https://github.com/cloudposse/terraform-aws-ssm-parameter-store/releases/tag/0.11.0)
  incorporated but just wanted to standardize new modules to updated version

### What:

- Updated the following to `v0.11.0`:

```
0.10.0 modules/argocd-repo
0.10.0 modules/aurora-mysql
0.10.0 modules/aurora-postgres
0.10.0 modules/datadog-configuration
0.10.0 modules/eks/platform
0.10.0 modules/opsgenie-team/modules/integration
0.10.0 modules/ses
0.9.1 modules/datadog-integration
```

</details>

## 1.279.0 (2023-08-11T16:39:01Z)

<details>
  <summary>fix: restore argocd notification ssm lookups @dudymas (#764)</summary>

### what

- revert some changes to `argocd` component
- connect argocd notifications with ssm secrets
- remove `deployment_id` from `argocd-repo` component
- correct `app_hostname` since gha usually adds protocol

### why

- regressions with argocd notifications caused github actions to timeout
- `deployment_id` no longer needed for fascilitating communication between gha and ArgoCD
- application urls were incorrect and problematic during troubleshooting

</details>

## 1.278.0 (2023-08-09T21:54:09Z)

<details>
  <summary>Upstream `eks/keda` @milldr (#808)</summary>

### what

- Added the component `eks/keda`

### why

- We've deployed KEDA for a few customers now and the component should be upstreamed

### references

- n/a

</details>

## 1.277.0 (2023-08-09T20:39:21Z)

<details>
  <summary>Added Inputs for `elasticsearch` and `cognito` @milldr (#786)</summary>

### what

- Added `deletion_protection` for `cognito`
- Added options for dedicated master for `elasticsearch`

### why

- Allow the default options to be customized

### references

- Customer requested additions

</details>

## 1.276.1 (2023-08-09T20:30:36Z)

<details>
  <summary>Update upgrade-guide.md Version @milldr (#807)</summary>

### what

- Set the version to the correct updated release

### why

- Needs to match correct version

### references

#804

</details>

### 🚀 Enhancements

<details>
  <summary>feat: allow email to be configured at account level @sgtoj (#799)</summary>

### what

- allow email to be configured at account level

### why

- to allow importing existing accounts with email address that does not met the organization standard naming format

### references

- n/a

</details>

## 1.276.0 (2023-08-09T16:38:40Z)

<details>
  <summary>Transit Gateway Cross-Region Support @milldr (#804)</summary>

### what

- Upgraded `tgw` components to support cross region connections
- Added back `tgw/cross-region-hub-connector` with overhaul to support updated `tgw/hub` component

### why

- Deploy `tgw/cross-region-hub-connector` to create peered TGW hubs
- Use `tgw/hub` both for in region and intra region connections

### references

- n/a

</details>

## 1.275.0 (2023-08-09T02:53:39Z)

<details>
  <summary>[eks/cluster] Proper handling of cold start and enabled=false @Nuru (#806)</summary>

### what

- Proper handling of cold start and `enabled=false`

### why

- Fixes #797
- Supersedes and closes #798
- Cloud Posse standard requires error-free operation and no resources created when `enabled` is `false`, but previously
  this component had several errors

</details>

## 1.274.2 (2023-08-09T00:13:36Z)

### 🚀 Enhancements

<details>
  <summary>Added Enabled Parameter to aws-saml/okta-user and datadog-synthetics-private-location @RoseSecurity (#805)</summary>

### What:

- Added `enabled` parameter for `modules/aws-saml/modules/okta-user/main.tf` and
  `modules/datadog-private-location-ecs/main.tf`

### Why:

- No support for disabling the creation of the resources

</details>

## 1.274.1 (2023-08-09T00:11:55Z)

### 🚀 Enhancements

<details>
  <summary>Updated Security Group Component to 2.2.0 @RoseSecurity (#803)</summary>

### What:

- Updated `bastion`, `redshift`, `rds`, `spacelift`, and `vpc` to utilize the newest version of
  `cloudposse/security-group/aws`

### Why:

- `cloudposse/security-group/aws` components were not updated to `2.2.0`

### References:

- [AWS Security Group Component](https://github.com/cloudposse/terraform-aws-security-group/compare/2.0.0-rc1...2.2.0)

</details>

## 1.274.0 (2023-08-08T17:03:41Z)

<details>
  <summary>bug: update descriptions *_account_account_name variables @sgtoj (#801)</summary>

### what

- update descriptions `*_account_account_name` variables
  - I replaced `stage` with `short` because that is the description used for the respective `outputs` entries

### why

- to help future implementers of CloudPosse's architectures

### references

- n/a

</details>

## 1.273.0 (2023-08-08T17:01:23Z)

<details>
  <summary>docs: fix issue with eks/cluster usage snippet @sgtoj (#796)</summary>

### what

- update usage snippet in readme for `eks/cluster` component

### why

- fix incorrect shape for one of the items in `aws_team_roles_rbac`
- improve consistency
- remove variables that are not applicable for the component

### references

- n/a

</details>

## 1.272.0 (2023-08-08T17:00:32Z)

<details>
  <summary>feat: filter out “SUSPENDED” accounts for account-map @sgtoj (#800)</summary>

### what

- filter out “SUSPENDED” accounts (aka accounts in waiting period for termination) for `account-map` component

### why

- suspended account cannot be used, so therefore it should not exist in the account-map
- allows for new _active_ accounts with same exact name of suspended account to exists and work with `account-map`

### references

- n/a

</details>

## 1.271.0 (2023-08-08T16:44:18Z)

<details>
  <summary>`eks/karpenter` Readme.md update @Benbentwo (#792)</summary>

### what

- Adding Karpenter troubleshooting to readme
- Adding https://endoflife.date/amazon-eks to `EKS/Cluster`

### references

- https://karpenter.sh/docs/troubleshooting/
- https://endoflife.date/amazon-eks

</details>

## 1.270.0 (2023-08-07T21:54:49Z)

<details>
  <summary>[eks/cluster] Add support for BottleRocket and EFS add-on @Nuru (#795)</summary>

### what

- Add support for EKS EFS add-on
- Better support for Managed Node Group's Block Device Storage
- Deprecate and ignore `aws_teams_rbac` and remove `identity` roles from `aws-auth`
- Support `eks/cluster` provisioning EC2 Instance Profile for Karpenter nodes (disabled by default via legacy flags)
- More options for specifying Availability Zones
- Deprecate `eks/ebs-controller` and `eks/efs-controller`
- Deprecate `eks/eks-without-spotinst`

### why

- Support EKS add-ons, follow-up to #723
- Support BottleRocket, `gp3` storage, and provisioned iops and throughput
- Feature never worked
- Avoid specific failure mode when deleting and recreating an EKS cluster
- Maintain feature parity with `vpc` component
- Replace with add-ons
- Was not being maintained or used

</details>

<details>
  <summary>[eks/storage-class] Initial implementation @Nuru (#794)</summary>

### what

- Initial implementation of `eks/storage-class`

### why

- Until now, we provisioned StorageClasses as a part of deploying
  [eks/ebs-controller](https://github.com/cloudposse/terraform-aws-components/blob/ba309ab4ffa96169b2b8dadce0643d13c1bd3ae9/modules/eks/ebs-controller/main.tf#L20-L56)
  and
  [eks/efs-controller](https://github.com/cloudposse/terraform-aws-components/blob/ba309ab4ffa96169b2b8dadce0643d13c1bd3ae9/modules/eks/efs-controller/main.tf#L48-L60).
  However, with the switch from deploying "self-managed" controllers to EKS add-ons, we no longer deploy
  `eks/ebs-controller` or `eks/efs-controller`. Therefore, we need a new component to manage StorageClasses
  independently of controllers.

### references

- #723

</details>

<details>
  <summary>[eks/karpenter] Script to update Karpenter CRDs @Nuru (#793)</summary>

### what

- [eks/karpenter] Script to update Karpenter CRDs

### why

- Upgrading Karpenter to v0.28.0 requires updating CRDs, which is not handled by current Helm chart. This script updates
  them by modifying the existing CRDs to be labeled as being managed by Helm, then installing the `karpenter-crd` Helm
  chart.

### references

- Karpenter [CRD Upgrades](https://karpenter.sh/docs/upgrade-guide/#custom-resource-definition-crd-upgrades)

</details>

## 1.269.0 (2023-08-03T20:47:56Z)

<details>
  <summary>upstream `api-gateway` and `api-gateway-settings` @Benbentwo (#788)</summary>

### what

- Upstream api-gateway and it's corresponding settings component

</details>

## 1.268.0 (2023-08-01T05:04:37Z)

<details>
  <summary>Added new variable into `argocd-repo` component to configure ArgoCD's `ignore-differences` @zdmytriv (#785)</summary>

### what

- Added new variable into `argocd-repo` component to configure ArcoCD `ignore-differences`

### why

- There are cases when application and/or third-party operators might want to change k8s API objects. For example,
  change the number of replicas in deployment. This will conflict with ArgoCD application because the ArgoCD controller
  will spot drift and will try to make an application in sync with the codebase.

### references

- https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/#respect-ignore-difference-configs

</details>

## 1.267.0 (2023-07-31T19:41:43Z)

<details>
  <summary>Spacelift `admin-stack` `var.description` @milldr (#787)</summary>

### what

- added missing description option

### why

- Variable is defined, but never passed to the modules

### references

n/a

</details>

## 1.266.0 (2023-07-29T18:00:25Z)

<details>
  <summary>Use s3_object_ownership variable @sjmiller609 (#779)</summary>

### what

- Pass s3_object_ownership variable into s3 module

### why

- I think it was accidentally not included
- Make possible to disable ACL from stack config

### references

- https://github.com/cloudposse/terraform-aws-s3-bucket/releases/tag/3.1.0

</details>

## 1.265.0 (2023-07-28T21:35:14Z)

<details>
  <summary>`bastion` support for `availability_zones` and public IP and subnets @milldr (#783)</summary>

### what

- Add support for `availability_zones`
- Fix issue with public IP and subnets
- `tflint` requirements -- removed all unused locals, variables, formatting

### why

- All instance types are not available in all AZs in a region
- Bug fix

### references

- [Internal Slack reference](https://cloudposse.slack.com/archives/C048LCN8LKT/p1689085395494969)

</details>

## 1.264.0 (2023-07-28T18:57:28Z)

<details>
  <summary>Aurora Resource Submodule Requirements @milldr (#775)</summary>

### what

- Removed unnecessary requirement for aurora resources for the service name not to equal the user name for submodules of
  both aurora resource components

### why

- This conditional doesn't add any value besides creating an unnecessary restriction. We should be able to create a user
  name as the service name if we want

### references

- n/a

</details>

## 1.263.0 (2023-07-28T18:12:30Z)

<details>
  <summary>fix: restore notifications config in argocd @dudymas (#782)</summary>

### what

- Restore ssm configuration options for argocd notifications

### why

- notifications were not firing and tasks time out in some installations

</details>

## 1.262.0 (2023-07-27T17:05:37Z)

<details>
  <summary>Upstream `spa-s3-cloudfront` @milldr (#780)</summary>

### what

- Update module
- Add Cloudfront Invalidation permission to GitHub policy

### why

- Corrected bug in the module
- Allow GitHub Actions to run invalidations

### references

- https://github.com/cloudposse/terraform-aws-cloudfront-s3-cdn/pull/288

</details>

## 1.261.0 (2023-07-26T16:20:37Z)

<details>
  <summary>Upstream `spa-s3-cloudfront` @milldr (#778)</summary>

### what

- Upstream changes to `spa-s3-cloudfront`

### why

- Updated the included modules to support Terraform v5
- Handle disabled WAF from remote-state

### references

- https://github.com/cloudposse/terraform-aws-cloudfront-s3-cdn/pull/284

</details>

## 1.260.1 (2023-07-25T05:10:20Z)

### 🚀 Enhancements

<details>
  <summary>[vpc] bugfix, [aurora-postgres] & [cloudtrail-bucket] Tflint fixes @Nuru (#776)</summary>

### what

- [vpc]: disable vpc_endpoints when enabled = false
- [aurora-postgres]: ensure variables have explicit types
- [cloudtrail-bucket]: ensure variables have explicit types

### why

- bugfix
- tflint fix
- tflint fix

</details>

### 🐛 Bug Fixes

<details>
  <summary>[vpc] bugfix, [aurora-postgres] & [cloudtrail-bucket] Tflint fixes @Nuru (#776)</summary>

### what

- [vpc]: disable vpc_endpoints when enabled = false
- [aurora-postgres]: ensure variables have explicit types
- [cloudtrail-bucket]: ensure variables have explicit types

### why

- bugfix
- tflint fix
- tflint fix

</details>

## 1.260.0 (2023-07-23T23:08:53Z)

<details>
  <summary>Update `alb` component @aknysh (#773)</summary>

### what

- Update `alb` component

### why

- Fixes after provisioning and testing on AWS

</details>

## 1.259.0 (2023-07-20T04:32:13Z)

<details>
  <summary>`elasticsearch` DNS Component Lookup @milldr (#769)</summary>

### what

- add environment for `dns-delegated` component lookup

### why

- `elasticsearch` is deployed in a regional environment, but `dns-delegated` is deployed to `gbl`

### references

- n/a

</details>

## 1.258.0 (2023-07-20T04:17:31Z)

<details>
  <summary>Bump `lambda-elasticsearch-cleanup` module @milldr (#768)</summary>

### what

- bump version of `lambda-elasticsearch-cleanup` module

### why

- Support Terraform provider v5

### references

- https://github.com/cloudposse/terraform-aws-lambda-elasticsearch-cleanup/pull/48

</details>

## 1.257.0 (2023-07-20T03:04:51Z)

<details>
  <summary>Bump ECS cluster module @max-lobur (#752)</summary>

### what

- Update ECS cluster module

### why

- Maintenance

</details>

## 1.256.0 (2023-07-18T23:57:44Z)

<details>
  <summary>Bump `elasticache-redis` Module @milldr (#767)</summary>

### what

- Bump `elasticache-redis` module

### why

- Resolve issues with terraform provider v5

### references

- https://github.com/cloudposse/terraform-aws-elasticache-redis/issues/199

</details>

## 1.255.0 (2023-07-18T22:53:51Z)

<details>
  <summary>Aurora Postgres Enhanced Monitoring Input @milldr (#766)</summary>

### what

- Added `enhanced_monitoring_attributes` as option
- Set default `aurora-mysql` component name

### why

- Set this var with a custom value to avoid IAM role length restrictions (default unchanged)
- Set common value as default

### references

- n/a

</details>

## 1.254.0 (2023-07-18T21:00:30Z)

<details>
  <summary>feat: acm no longer requires zone @dudymas (#765)</summary>

### what

- `acm` only looks up zones if `process_domain_validation_options` is true

### why

- Allow external validation of acm certs

</details>

## 1.253.0 (2023-07-18T17:45:16Z)

<details>
  <summary>`alb` and `ssm-parameters` Upstream for Basic Use @milldr (#763)</summary>

### what

- `alb` component can get the ACM cert from either `dns-delegated` or `acm`
- Support deploying `ssm-parameters` without SOPS
- `waf` requires a value for `visibility_config` in the stack catalog

### why

- resolving bugs while deploying example components

### references

- https://cloudposse.atlassian.net/browse/JUMPSTART-1185

</details>

## 1.252.0 (2023-07-18T16:14:23Z)

<details>
  <summary>fix: argocd flags, versions, and expressions @dudymas (#753)</summary>

### what

- adjust expressions in argocd
- update helmchart module
- tidy up variables

### why

- component wouldn't run

</details>

## 1.251.0 (2023-07-15T03:47:29Z)

<details>
  <summary>fix: ecs capacity provider typing @dudymas (#762)</summary>

### what

- Adjust typing of `capacity_providers_ec2`

### why

- Component doesn't work without these fixes

</details>

## 1.250.3 (2023-07-15T00:31:40Z)

### 🚀 Enhancements

<details>
  <summary>Update `alb` and `eks/alb-controller` components @aknysh (#760)</summary>

### what

- Update `alb` and `eks/alb-controller` components

### why

- Remove unused variables and locals
- Apply variables that are defined in `variables.tf` but were not used

</details>

## 1.250.2 (2023-07-14T23:34:14Z)

### 🚀 Enhancements

<details>
  <summary>[aws-teams] Remove obsolete restriction on assuming roles in identity account @Nuru (#761)</summary>

### what

- [aws-teams] Remove obsolete restriction on assuming roles in the `identity` account

### why

Some time ago, there was an implied permission for any IAM role to assume any other IAM role in the same account if the
originating role had sufficient permissions to perform `sts:AssumeRole`. For this reason, we had an explicit policy
against assuming roles in the `identity` account.

AWS has removed that implied permission and now requires all roles to have explicit trust policies. Our current Team
structure requires Teams (e.g. `spacelift`) to be able to assume roles in `identity` (e.g. `planner`). Therefore, the
previous restriction is both not needed and actually hinders desired operation.

</details>

### 🐛 Bug Fixes

<details>
  <summary>[aws-teams] Remove obsolete restriction on assuming roles in identity account @Nuru (#761)</summary>

### what

- [aws-teams] Remove obsolete restriction on assuming roles in the `identity` account

### why

Some time ago, there was an implied permission for any IAM role to assume any other IAM role in the same account if the
originating role had sufficient permissions to perform `sts:AssumeRole`. For this reason, we had an explicit policy
against assuming roles in the `identity` account.

AWS has removed that implied permission and now requires all roles to have explicit trust policies. Our current Team
structure requires Teams (e.g. `spacelift`) to be able to assume roles in `identity` (e.g. `planner`). Therefore, the
previous restriction is both not needed and actually hinders desired operation.

</details>

## 1.250.1 (2023-07-14T02:14:46Z)

### 🚀 Enhancements

<details>
  <summary>[eks/karpenter-provisioner] minor improvements @Nuru (#759)</summary>

### what

- [eks/karpenter-provisioner]:
  - Implement `metadata_options`
  - Avoid Terraform errors by marking Provisoner `spec.requirements` a computed field
  - Add explicit error message about Consolidation and TTL Seconds After Empty being mutually exclusive
  - Add `instance-category` and `instance-generation` to example in README
  - Make many inputs optional
- [eks/karpenter] Update README to indicate that version 0.19 or later of Karpenter is required to work with this code.

### why

- Bug Fix: Input was there, but was being ignored, leading to unexpected behavior
- If a requirement that had a default value was not supplied, Terraform would fail with an error about inconsistent
  plans because Karpenter would fill in the default
- Show some default values and how to override them
- Reduce the burden of supplying empty fields

</details>

## 1.250.0 (2023-07-14T02:10:46Z)

<details>
  <summary>Add EKS addons and the required IRSA to the `eks` component @aknysh (#723)</summary>

### what

- Deprecate the `eks-iam` component
- Add EKS addons and the required IRSA for the addons to the `eks` component
- Add ability to specify configuration values and timeouts for addons
- Add ability to deploy addons to Fargate when necessary
- Add ability to omit specifying Availability Zones and infer them from private subnets
- Add recommended but optional and requiring opt-in: use a single Fargate Pod Execution Role for all Fargate Profiles

### why

- The `eks-iam` component is not in use (we now create the IAM roles for Kubernetes Service Accounts in the
  https://github.com/cloudposse/terraform-aws-helm-release module), and has very old and outdated code

- AWS recommends to provision the required EKS addons and not to rely on the managed addons (some of which are
  automatically provisioned by EKS on a cluster)

- Some EKS addons (e.g. `vpc-cni` and `aws-ebs-csi-driver`) require an IAM Role for Kubernetes Service Account (IRSA)
  with specific permissions. Since these addons are critical for cluster functionality, we create the IRSA roles for the
  addons in the `eks` component and provide the role ARNs to the addons

- Some EKS addons can be configured. In particular, `coredns` requires configuration to enable it to be deployed to
  Fargate.

- Users relying on Karpenter to deploy all nodes and wanting to deploy `coredns` or `aws-ebs-csi-driver` addons need to
  deploy them to Fargate or else the EKS deployment will fail.

- Enable DRY specification of Availability Zones, and use of AZ IDs, by reading the VPCs AZs.

- A cluster needs only one Fargate Pod Execution Role, and it was a mistake to provision one for every profile. However,
  making the change would break existing clusters, so it is optional and requires opt-in.

### references

- https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html
- https://docs.aws.amazon.com/eks/latest/userguide/managing-add-ons.html#creating-an-add-on
- https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html
- https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
- https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-role
- https://aws.github.io/aws-eks-best-practices/networking/vpc-cni/#deploy-vpc-cni-managed-add-on
- https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
- https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons
- https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html#csi-iam-role
- https://github.com/kubernetes-sigs/aws-ebs-csi-driver

</details>

## 1.249.0 (2023-07-14T01:23:37Z)

<details>
  <summary>Make alb-controller default Ingress actually the default Ingress @Nuru (#758)</summary>

### what

- Make the `alb-controller` default Ingress actually the default Ingress

### why

- When setting `default_ingress_enabled = true` it is a reasonable expectation that the deployed Ingress be marked as
  the Default Ingress. The previous code suggests this was the intended behavior, but does not work with the current
  Helm chart and may have never worked.

</details>

## 1.248.0 (2023-07-13T00:21:29Z)

<details>
  <summary>Upstream `gitops` Policy Update @milldr (#757)</summary>

### what

- allow actions on table resources

### why

- required to be able to query using a global secondary index

### references

- https://github.com/cloudposse/github-action-terraform-plan-storage/pull/16

</details>

## 1.247.0 (2023-07-12T19:32:33Z)

<details>
  <summary>Update `waf` and `alb` components @aknysh (#755)</summary>

### what

- Update `waf` component
- Update `alb` component

### why

- For `waf` component, add missing features supported by the following resources:

  - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl
  - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration

- For `waf` component, remove deprecated features not supported by Terraform `aws` provider v5:

  - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-5-upgrade#resourceaws_wafv2_web_acl
  - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-5-upgrade#resourceaws_wafv2_web_acl_logging_configuration

- For `waf` component, allow specifying a list of Atmos components to read from the remote state and associate their
  ARNs with the web ACL

- For `alb` component, update the modules to the latest versions and allow specifying Atmos component names for the
  remote state in the variables (for the cases where the Atmos component names are not standard)

### references

- https://github.com/cloudposse/terraform-aws-waf/pull/45

</details>

## 1.246.0 (2023-07-12T18:57:58Z)

<details>
  <summary>`acm` Upstream @Benbentwo (#756)</summary>

### what

- Upstream ACM

### why

- New Variables
  - `subject_alternative_names_prefixes`
  - `domain_name_prefix`

</details>

## 1.245.0 (2023-07-11T19:36:11Z)

<details>
  <summary>Bump `spaces` module versions @milldr (#754)</summary>

### what

- bumped module version for `terraform-spacelift-cloud-infrastructure-automation`

### why

- New policy added to `spaces`

### references

- https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/releases/tag/1.1.0

</details>

## 1.244.0 (2023-07-11T17:50:19Z)

<details>
  <summary>Upstream Spacelift and Documentation @milldr (#732)</summary>

### what

- Minor corrections to spacelift components
- Documentation

### why

- Deployed this at a customer and resolved the changed errors
- Adding documentation for updated Spacelift design

### references

- n/a

</details>

## 1.243.0 (2023-07-06T20:04:08Z)

<details>
  <summary>Upstream `gitops` @milldr (#735)</summary>

### what

- Upstream new component, `gitops`

### why

- This component is used to create a role for GitHub to assume. This role is used to assume the `gitops` team and is
  required for enabling GitHub Action Terraform workflows

### references

- JUMPSTART-904

</details>

## 1.242.1 (2023-07-05T19:46:08Z)

### 🚀 Enhancements

<details>
  <summary>Use the new subnets data source @max-lobur (#737)</summary>

### what

- Use the new subnets data source

### why

- Planned migration according to https://github.com/hashicorp/terraform-provider-aws/pull/18803

</details>

## 1.242.0 (2023-07-05T17:05:57Z)

<details>
  <summary>Restore backwards compatibility of account-map output @Nuru (#748)</summary>

### what

- Restore backwards compatibility of `account-map` output

### why

- PR #715 removed outputs from `account-map` that `iam-roles` relied on. Although it removed the references in
  `iam-roles`, this imposed an ordering on the upgrade: the `iam-roles` code had to be deployed before the module could
  be applied. That proved to be inconvenient. Furthermore, if a future `account-map` upgrade added outputs that
  iam-roles`required, neither order of operations would go smoothly. With this update, the standard practice of applying`account-map`
  before deploying code will work again.

</details>

## 1.241.0 (2023-07-05T16:52:58Z)

<details>
  <summary>Fixed broken links in READMEs @zdmytriv (#749)</summary>

### what

- Fixed broken links in READMEs

### why

- Fixed broken links in READMEs

### references

- https://github.com/cloudposse/terraform-aws-components/issues/747

</details>

## 1.240.1 (2023-07-04T04:54:28Z)

### Upgrade notes

This fixes issues with `aws-sso` and `github-oidc-provider`. Versions from v1.227 through v1.240 should not be used.

After installing this version of `aws-sso`, you may need to change the configuration in your stacks. See
[modules/aws-sso/changelog](https://github.com/cloudposse/terraform-aws-components/blob/main/modules/aws-sso/CHANGELOG.md)
for more information. Note: this release is from PR #740

After installing this version of `github-oidc-provider`, you may need to change the configuration in your stacks. See
the release notes for v1.238.1 for more information.

### 🐛 Bug Fixes

<details>
  <summary>bugfix `aws-sso`, `github-oidc-provider` @Benbentwo (#740)</summary>

### what

- Bugfixes `filter` depreciation issue via module update to `1.1.1`
- Bugfixes missing `aws.root` provider
- Bugfixes `github-oidc-provider` v1.238.1

### why

- Bugfixes

### references

- https://github.com/cloudposse/terraform-aws-sso/pull/44
- closes #744

</details>

## 1.240.0 (2023-07-03T18:14:14Z)

<details>
  <summary>Fix TFLint violations in account-map @MaxymVlasov (#745)</summary>

### Why

I'm too lazy to fix it each time when we get module updates via `atmos vendor` GHA

### References

- https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.4.0/docs/rules/terraform_deprecated_index.md
- https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.4.0/docs/rules/terraform_comment_syntax.md
- https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.4.0/docs/rules/terraform_unused_declarations.md

</details>

## 1.239.0 (2023-06-29T23:34:53Z)

<details>
  <summary>Bump `cloudposse/ec2-autoscale-group/aws` to `0.35.0` @milldr (#734)</summary>

### what

- bumped ASG module version, `cloudposse/ec2-autoscale-group/aws` to `0.35.0`

### why

- Recent versions of this module resolve errors for these components

### references

- https://github.com/cloudposse/terraform-aws-ec2-autoscale-group

</details>

## 1.238.1 (2023-06-29T21:15:50Z)

### Upgrade notes:

There is a bug in this version of `github-oidc-provider`. Upgrade to version v1.240.1 or later instead.

After installing this version of `github-oidc-provider`, you may need to change the configuration in your stacks.

- If you have dynamic Terraform roles enabled, then this should be configured like a normal component. The previous
  component may have required you to set

      ```yaml
      backend:
        s3:
          role_arn: null
      ````

  and **that configuration should be removed** everywhere.

- If you only use SuperAdmin to deploy things to the `identity` account, then for the `identity` (and `root`, if
  applicable) account **_only_**, set

      ```yaml
      backend:
        s3:
          role_arn: null
      vars:
        superadmin: true
      ````

  **Deployments to other accounts should not have any of those settings**.

### 🚀 Enhancements

<details>
  <summary>[github-oidc-provider] extra-compatible provider @Nuru (#742)</summary>

### what && why

- This updates `provider.tf` to provide compatibility with various legacy configurations as well as the current
  reference architecture
- This update does NOT require updating `account-map`

</details>

## 1.238.0 (2023-06-29T19:39:15Z)

<details>
  <summary>IAM upgrades: SSO Permission Sets as Teams, SourceIdentity support, region independence @Nuru (#738)</summary>

### what

- Enable SSO Permission Sets to function as teams
- Allow SAML sign on via any regional endpoint, not only us-east-1
- Allow use of AWS "Source Identity" for SAML and SSO users (not enabled for OIDC)

### why

- Reduce the friction between SSO permission sets and SAML roles by allowing people to use either interchangeably.
  (Almost. SSO permission sets do not yet have the same permissions as SAML roles in the `identity` account itself.)
- Enable continued access in the event of a regional outage in us-east-1 as happened recently
- Enable auditing of who is using assumed roles

### References

- [Monitor and control actions taken with assumed roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_control-access_monitor.html)
- [How to integrate AWS STS SourceIdentity with your identity provider](https://aws.amazon.com/blogs/security/how-to-integrate-aws-sts-sourceidentity-with-your-identity-provider/)
- [AWS Sign-In endpoints](https://docs.aws.amazon.com/general/latest/gr/signin-service.html)
- [Available keys for SAML-based AWS STS federation](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_iam-condition-keys.html#condition-keys-saml)

### Upgrade notes

The regional endpoints and Source Identity support are non-controversial and cannot be disabled. They do, however,
require running `terraform apply` against `aws-saml`, `aws-teams`, and `aws-team-roles` in all accounts.

#### AWS SSO updates

To enable SSO Permission Sets to function as teams, you need to update `account-map` and `aws-sso`, then apply changes
to

- `tfstate-backend`
- `aws-teams`
- `aws-team-roles`
- `aws-sso`

This is all enabled by default. If you do not want it, you only need to update `account-map`, and add
`account-map/modules/roles-to-principles/variables_override.tf` in which you set
`overridable_team_permission_sets_enabled` to default to `false`

Under the old `iam-primary-roles` component, corresponding permission sets were named `Identity<role>RoleAccess`. Under
the current `aws-teams` component, they are named `Identity<role>TeamAccess`. The current `account-map` defaults to the
latter convention. To use the earlier convention, add `account-map/modules/roles-to-principles/variables_override.tf` in
which you set `overridable_team_permission_set_name_pattern` to default to `"Identity%sRoleAccess"`

There is a chance the resulting trust policies will be too big, especially for `tfstate-backend`. If you get an error
like

```
Cannot exceed quota for ACLSizePerRole: 2048
```

You need to request a quota increase (Quota Code L-C07B4B0D), which will be automatically granted, usually in about 5
minutes. The max quota is 4096, but we recommend increasing it to 3072 first, so you retain some breathing room for the
future.

</details>

## 1.237.0 (2023-06-27T22:27:49Z)

<details>
  <summary>Add Missing `github-oidc-provider` Thumbprint @milldr (#736)</summary>

### what

- include both thumbprints for GitHub OIDC

### why

- There are two possible intermediary certificates for the Actions SSL certificate and either can be returned by
  Github's servers, requiring customers to trust both. This is a known behavior when the intermediary certificates are
  cross-signed by the CA.

### references

- https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/

</details>

## 1.236.0 (2023-06-26T18:14:29Z)

<details>
  <summary>Update `eks/echo-server` and `eks/alb-controller-ingress-group` components @aknysh (#733)</summary>

### what

- Update `eks/echo-server` and `eks/alb-controller-ingress-group` components
- Allow specifying
  [alb.ingress.kubernetes.io/scheme](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/#scheme)
  (`internal` or `internet-facing`)

### why

- Allow the echo server to work with internal load balancers

### references

- https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/

</details>

## 1.235.0 (2023-06-22T21:06:18Z)

<details>
  <summary>[account-map]  Backwards compatibility for terraform profile users and eks/cluster  @Nuru (#731)</summary>

### what

- [account-map/modules/iam-roles] Add `profiles_enabled` input to override global value
- [eks/cluster] Use `iam-roles` `profiles_enabled` input to force getting a role ARN even when profiles are in use
- [guardduty] Make providers compatible with static and dynamic TF roles

### why

- Previously, when the global `account-map` `profiles_enabled` flag was `true`, `iam_roles.terraform_role_arn` would be
  null. However, `eks/cluster` requires `terraform_role_arn` regardless.
- Changes made in #728 work in environments that have not adopted dynamic Terraform roles but would fail in environments
  that have (when using SuperAdmin)

</details>

## 1.234.0 (2023-06-21T22:44:55Z)

<details>
  <summary>[account-map] Feature flag to enable legacy Terraform role mapping @Nuru (#730)</summary>

### what

- [account-map] Add `legacy_terraform_uses_admin` feature flag to retain backwards compatibility

### why

- Historically, the `terraform` roles in `root` and `identity` were not used for Terraform plan/apply, but for other
  things, and so the `terraform_roles` map output selected the `admin` roles for those accounts. This "wart" has been
  remove in current `aws-team-roles` and `tfstate-backend` configurations, but for people who do not want to migrate to
  the new conventions, this feature flag enables them to maintain the status quo with respect to role usage while taking
  advantage of other updates to `account-map` and other components.

### references

This update is recommended for all customers wanting to use **_any_** component version 1.227 or later.

- #715
-

</details>

## 1.233.0 (2023-06-21T20:03:36Z)

<details>
  <summary>[lambda] feat: allows to use YAML instead of JSON for IAM policy @gberenice (#692)</summary>

### what

- BREAKING CHANGE: Actually use variable `function_name` to set the lambda function name.
- Make the variable `function_name` optional. When not set, the old null-lable-derived name will be use.
- Allow IAM policy to be specified in a custom terraform object as an alternative to JSON.

### why

- `function_name` was required to set, but it wasn't actually passed to `module "lambda"` inputs.
- Allow callers to stop providing `function_name` and preserve old behavior of using automatically generated name.
- When using [Atmos](https://atmos.tools/) to generate inputs from "stack" YAML files, having the ability to pass the
  statements in as a custom object means specifying them via YAML, which makes the policy declaration in stack more
  readable compared to embedding a JSON string in the YAML.

</details>

## 1.232.0 (2023-06-21T15:49:06Z)

<details>
  <summary>refactor securityhub component @mcalhoun (#728)</summary>

### what

- Refactor the Security Hub components into a single component

### why

- To improve the overall dev experience and to prevent needing to do multiple deploys with variable changes in-between.

</details>

## 1.231.0 (2023-06-21T14:54:50Z)

<details>
  <summary>roll guard duty back to previous providers logic @mcalhoun (#727)</summary>

### what

- Roll the Guard Duty component back to using the previous logic for role assumption.

### why

- The newer method is causing the provider to try to assume the role twice. We get the error:

```
AWS Error: operation error STS: AssumeRole, https response error StatusCode: 403, RequestID: 00000000-0000-0000-0000-00000000, api error AccessDenied: User: arn:aws:sts::000000000000:assumed-role/acme-core-gbl-security-terraform/aws-go-sdk-1687312396297825294 is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::000000000000:role/acme-core-gbl-security-terraform
```

</details>

## 1.230.0 (2023-06-21T01:49:52Z)

<details>
  <summary>refactor guardduty module @mcalhoun (#725)</summary>

### what

- Refactor the GuardDuty components into a single component

### why

- To improve the overall dev experience and to prevent needing to do multiple deploys with variable changes in-between.

</details>

## 1.229.0 (2023-06-20T19:37:35Z)

<details>
  <summary>upstream `github-action-runners` dockerhub authentication @Benbentwo (#726)</summary>

### what

- Adds support for dockerhub authentication

### why

- Dockerhub limits are unrealistically low for actually using dockerhub as an image registry for automated builds

</details>

## 1.228.0 (2023-06-15T20:57:45Z)

<details>
  <summary>alb: use the https_ssl_policy @johncblandii (#722)</summary>

### what

- Apply the HTTPS policy

### why

- The policy was unused so it was defaulting to an old policy

### references

</details>

## 1.227.0 (2023-06-12T23:41:45Z)

Possibly breaking change:

In this update, `account-map/modules/iam-roles` acquired a provider, making it no longer able to be used with `count`.
If you have code like

```hcl
module "optional_role" {
  count = local.optional_role_enabled ? 1 : 0

  source  = "../account-map/modules/iam-roles"
  stage   = var.optional_role_stage
  context = module.this.context
}
```

You will need to rewrite it, removing the `count` parameter. It will be fine to always instantiate the module. If there
are problems with ensuring appropriate settings with the module is disabled, you can always replace them with the
component's inputs:

```hcl
module "optional_role" {
  source  = "../account-map/modules/iam-roles"
  stage   = local.optional_role_enabled ? var.optional_role_stage : var.stage
  context = module.this.context
}
```

The update to components 1.227.0 is huge, and you have options.

- Enable, or not, dynamic Terraform IAM roles, which allow you to give some people (and Spacelift) the ability to run
  Terraform plan in some accounts without allowing apply. Note that these users will still have read/write access to
  Terraform state, but will not have IAM permissions to make changes in accounts.
  [terraform_dynamic_role_enabled](https://github.com/cloudposse/terraform-aws-components/blob/1b338fe664e5debc5bbac30cfe42003f7458575a/modules/account-map/variables.tf#L96-L100)
- Update to new `aws-teams` team names. The new names are (except for support) distinct from team-roles, making it
  easier to keep track. Also, the new managers team can run Terraform for identity and root in most (but not all) cases.
- Update to new `aws-team-roles`, including new permissions. The custom policies that have been removed are replaced in
  the `aws-team-roles` configuration with AWS managed policy ARNs. This is required to add the `planner` role and
  support the `terraform plan` restriction.
- Update the `providers.tf for` all components. Or some of them now, some later. Most components do not require updates,
  but all of them have updates. The new `providers.tf`, when used with dynamic Terraform roles, allows users directly
  logged into target accounts (rather than having roles in the `identity` account) to use Terraform in that account, and
  also allows SuperAdmin to run Terraform in more cases (almost everywhere).

**If you do not want any new features**, you only need to update `account-map` to v1.235 or later, to be compatible with
future components. Note that when updating `account-map` this way, you should update the code everywhere (all open PRs
and branches) before applying the Terraform changes, because the applied changes break the old code.

If you want all the new features, we recommend updating all of the following to the current release in 1 PR:

- account-map
- aws-teams
- aws-team-roles
- tfstate-backend

<details>
  <summary>Enable `terraform plan` access via dynamic Terraform roles @Nuru (#715)</summary>

### Reviewers, please note:

The PR changes a lot of files. In particular, the `providers.tf` and therefore the `README.md` for nearly every
component. Therefore it will likely be easier to review this PR one commit at a time.

`import_role_arn` and `import_profile_name` have been removed as they are no longer needed. Current versions of
Terraform (probably beginning with v1.1.0, but maybe as late as 1.3.0, I have not found authoritative information) can
read data sources during plan and so no longer need a role to be explicitly specified while importing. Feel free to
perform your own tests to make yourself more comfortable that this is correct.

### what

- Updates to allow Terraform to dynamically assume a role based on the user, to allow some users to run `terraform plan`
  but not `terraform apply`
  - Deploy standard `providers.tf` to all components that need an `aws` provider
  - Move extra provider configurations to separate file, so that `providers.tf` can remain consistent/identical among
    components and thus be easily updated
  - Create `provider-awsutils.mixin.tf` to provide consistent, maintainable implementation
- Make `aws-sso` vendor safe
- Deprecate `sso` module in favor of `aws-saml`

### why

- Allow users to try new code or updated configurations by running `terraform plan` without giving them permission to
  make changes with Terraform
- Make it easier for people directly logged into target accounts to still run Terraform
- Follow-up to #697, which updated `aws-teams` and `aws-team-roles`, to make `aws-sso` consistent
- Reduce confusion by moving deprecated code to `deprecated/`

</details>

## 1.226.0 (2023-06-12T17:42:51Z)

<details>
  <summary>chore: Update and add more basic pre-commit hooks @MaxymVlasov (#714)</summary>

### what

Fix common issues in the repo

### why

It violates our basic checks, which adds a headache to using
https://github.com/cloudposse/github-action-atmos-component-updater as is

![image](https://github.com/cloudposse/terraform-aws-components/assets/11096782/248febbe-b65f-4080-8078-376ef576b457)

> **Note**: It is much simpler to review PR if
> [hide whitespace changes](https://github.com/cloudposse/terraform-aws-components/pull/714/files?w=1)

</details>

## 1.225.0 (2023-06-12T14:57:20Z)

<details>
  <summary>Removed list of components from main README.md @zdmytriv (#721)</summary>

### what

- Removed list of components from main README.md

### why

- That list is outdated

### references

</details>

## 1.224.0 (2023-06-09T19:52:51Z)

<details>
  <summary>upstream argocd @Benbentwo (#634)</summary>

### what

- Upstream fixes that allow for Google OIDC

</details>

## 1.223.0 (2023-06-09T14:28:08Z)

<details>
  <summary>add new spacelift components @mcalhoun (#717)</summary>

### what

- Add the newly developed spacelift components
- Deprecate the previous components

### why

- We undertook a process of decomposing a monolithic module and broke it into smaller, composable pieces for a better
  developer experience

### references

- Corresponding
  [Upstream Module PR](https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/pull/143)

</details>

## 1.222.0 (2023-06-08T23:28:34Z)

<details>
  <summary>Karpenter Node Interruption Handler @milldr (#713)</summary>

### what

- Added Karpenter Interruption Handler to existing component

### why

- Interruption is supported by karpenter, but we need to deploy sqs queue and event bridge rules to enable

### references

- https://github.com/cloudposse/knowledge-base/discussions/127

</details>

## 1.221.0 (2023-06-07T18:11:23Z)

<details>
  <summary>feat: New Component `aws-ssosync` @dudymas (#625)</summary>

### what

- adds a fork of [aws-ssosync](https://github.com/awslabs/ssosync) as a lambda on a 15m cronjob

### Why

Google is one of those identity providers that doesn't have good integration with AWS SSO. In order to sync groups and
users across we need to use some API calls, luckily AWS Built [aws-ssosync](https://github.com/awslabs/ssosync) to
handle that.

Unfortunately, it required ASM so we use [Benbentwo/ssosync](https://github.com/Benbentwo/ssosync) as it removes that
requirement.

</details>

## 1.220.0 (2023-06-05T22:31:10Z)

<details>
  <summary>Disable helm experiments by default, block Kubernetes provider 2.21.0 @Nuru (#712)</summary>

### what

- Set `helm_manifest_experiment_enabled` to `false` by default
- Block Kubernetes provider 2.21.0

### why

- The `helm_manifest_experiment_enabled` reliably breaks when a Helm chart installs CRDs. The initial reason for
  enabling it was for better drift detection, but the provider seems to have fixed most if not all of the drift
  detection issues since then.
- Kubernetes provider 2.21.0 had breaking changes which were reverted in 2.21.1.

### references

- https://github.com/hashicorp/terraform-provider-kubernetes/pull/2084#issuecomment-1576711378

</details>

## 1.219.0 (2023-06-05T20:23:17Z)

<details>
  <summary>Expand ECR GH OIDC Default Policy @milldr (#711)</summary>

### what

- updated default ECR GH OIDC policy

### why

- This policy should grant GH OIDC access both public and private ECR repos

### references

- https://cloudposse.slack.com/archives/CA4TC65HS/p1685993698149499?thread_ts=1685990234.560589&cid=CA4TC65HS

</details>

## 1.218.0 (2023-06-05T01:59:49Z)

<details>
  <summary>Move `profiles_enabled` logic out of `providers.tf` and into `iam-roles` @Nuru (#702)</summary>

### what

- For Terraform roles and profiles used in `providers.tf`, return `null` for unused option
- Rename variables to `overridable_*` and update documentation to recommend `variables_override.tf` for customization

### why

- Prepare for `providers.tf` updates to support dynamic Terraform roles
- ARB decision on customization compatible with vendoring

</details>

## 1.217.0 (2023-06-04T23:11:44Z)

<details>
  <summary>[eks/external-secrets-operator] Normalize variables, update dependencies @Nuru (#708)</summary>

### what

For `eks/external-secrets-operator`:

- Normalize variables, update dependencies
- Exclude Kubernetes provider v2.21.0

### why

- Bring in line with other Helm-based modules
- Take advantage of improvements in dependencies

### references

- [Breaking change in Kubernetes provider v2.21.0](https://github.com/hashicorp/terraform-provider-kubernetes/pull/2084)

</details>

## 1.216.2 (2023-06-04T23:08:39Z)

### 🚀 Enhancements

<details>
  <summary>Update modules for Terraform AWS provider v5 @Nuru (#707)</summary>

### what

- Update modules for Terraform AWS provider v5

### why

- Provider version 5.0.0 was released with breaking changes. This fixes the breakage.

### references

- [v5 upgrade guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-5-upgrade)
- [v5.0.0 Release Notes](https://github.com/hashicorp/terraform-provider-aws/releases/tag/v5.0.0)

</details>

## 1.216.1 (2023-06-04T01:18:31Z)

### 🚀 Enhancements

<details>
  <summary>Preserve custom roles when vendoring in updates @Nuru (#697)</summary>

### what

- Add `additional-policy-map.tf` as glue meant to be replaced by customers with map of their custom policies.

### why

- Currently, custom polices have to be manually added to the map in `main.tf`, but that gets overwritten with every
  vendor update. Putting that map in a separate, optional file allows for the custom code to survive vendoring.

</details>

## 1.216.0 (2023-06-02T18:02:01Z)

<details>
  <summary>ssm-parameters: support tiers @johncblandii (#705)</summary>

### what

- Added support for ssm param tiers
- Updated the minimum version to `>= 1.3.0` to support `optional` parameters

### why

- `Standard` tier only supports 4096 characters. This allows Advanced and Intelligent Tiering support.

### references

</details>

## 1.215.0 (2023-06-02T14:28:29Z)

<details>
  <summary>`.editorconfig` Typo @milldr (#704)</summary>

### what

fixed intent typo

### why

should be spelled "indent"

### references

https://cloudposse.slack.com/archives/C01EY65H1PA/p1685638634845009

</details>

## 1.214.0 (2023-05-31T17:46:35Z)

<details>
  <summary>Transit Gateway `var.connections` Redesign @milldr (#685)</summary>

### what

- Updated how the connection variables for `tgw/hub` and `tgw/spoke` are defined
- Moved the old versions of `tgw` to `deprecated/tgw`

### why

- We want to be able to define multiple or alternately named `vpc` or `eks/cluster` components for both hub and spoke
- The cross-region components are not updated yet with this new design, since the current customers requesting these
  updates do not need cross-region access at this time. But we want to still support the old design s.t. customers using
  cross-region components can access the old components. We will need to update the cross-region components with follow
  up effort

### references

- https://github.com/cloudposse/knowledge-base/discussions/112

</details>

## 1.213.0 (2023-05-31T14:50:16Z)

<details>
  <summary>Introducing Security Hub @zdmytriv (#683)</summary>

### what

- Introducing Security Hub component

### why

Amazon Security Hub enables users to centrally manage and monitor the security and compliance of their AWS accounts and
resources. It aggregates, organizes, and prioritizes security findings from various AWS services, third-party tools, and
integrated partner solutions.

Here are the key features and capabilities of Amazon Security Hub:

- Centralized security management: Security Hub provides a centralized dashboard where users can view and manage
  security findings from multiple AWS accounts and regions. This allows for a unified view of the security posture
  across the entire AWS environment.

- Automated security checks: Security Hub automatically performs continuous security checks on AWS resources,
  configurations, and security best practices. It leverages industry standards and compliance frameworks, such as AWS
  CIS Foundations Benchmark, to identify potential security issues.

- Integrated partner solutions: Security Hub integrates with a wide range of AWS native services, as well as third-party
  security products and solutions. This integration enables the ingestion and analysis of security findings from diverse
  sources, offering a comprehensive security view.

- Security standards and compliance: Security Hub provides compliance checks against industry standards and regulatory
  frameworks, such as PCI DSS, HIPAA, and GDPR. It identifies non-compliant resources and provides guidance on
  remediation actions to ensure adherence to security best practices.

- Prioritized security findings: Security Hub analyzes and prioritizes security findings based on severity, enabling
  users to focus on the most critical issues. It assigns severity levels and generates a consolidated view of security
  alerts, allowing for efficient threat response and remediation.

- Custom insights and event aggregation: Security Hub supports custom insights, allowing users to create their own rules
  and filters to focus on specific security criteria or requirements. It also provides event aggregation and correlation
  capabilities to identify related security findings and potential attack patterns.

- Integration with other AWS services: Security Hub seamlessly integrates with other AWS services, such as AWS
  CloudTrail, Amazon GuardDuty, AWS Config, and AWS IAM Access Analyzer. This integration allows for enhanced
  visibility, automated remediation, and streamlined security operations.

- Alert notifications and automation: Security Hub supports alert notifications through Amazon SNS, enabling users to
  receive real-time notifications of security findings. It also facilitates automation and response through integration
  with AWS Lambda, allowing for automated remediation actions.

By utilizing Amazon Security Hub, organizations can improve their security posture, gain insights into security risks,
and effectively manage security compliance across their AWS accounts and resources.

### references

- https://aws.amazon.com/security-hub/
- https://github.com/cloudposse/terraform-aws-security-hub/

</details>

## 1.212.0 (2023-05-31T14:45:30Z)

<details>
  <summary>Introducing GuardDuty @zdmytriv (#682)</summary>

### what

- Introducing GuardDuty component

### why

AWS GuardDuty is a managed threat detection service. It is designed to help protect AWS accounts and workloads by
continuously monitoring for malicious activities and unauthorized behaviors. GuardDuty analyzes various data sources
within your AWS environment, such as AWS CloudTrail logs, VPC Flow Logs, and DNS logs, to detect potential security
threats.

Key features and components of AWS GuardDuty include:

- Threat detection: GuardDuty employs machine learning algorithms, anomaly detection, and integrated threat intelligence
  to identify suspicious activities, unauthorized access attempts, and potential security threats. It analyzes event
  logs and network traffic data to detect patterns, anomalies, and known attack techniques.

- Threat intelligence: GuardDuty leverages threat intelligence feeds from AWS, trusted partners, and the global
  community to enhance its detection capabilities. It uses this intelligence to identify known malicious IP addresses,
  domains, and other indicators of compromise.

- Real-time alerts: When GuardDuty identifies a potential security issue, it generates real-time alerts that can be
  delivered through AWS CloudWatch Events. These alerts can be integrated with other AWS services like Amazon SNS or AWS
  Lambda for immediate action or custom response workflows.

- Multi-account support: GuardDuty can be enabled across multiple AWS accounts, allowing centralized management and
  monitoring of security across an entire organization's AWS infrastructure. This helps to maintain consistent security
  policies and practices.

- Automated remediation: GuardDuty integrates with other AWS services, such as AWS Macie, AWS Security Hub, and AWS
  Systems Manager, to facilitate automated threat response and remediation actions. This helps to minimize the impact of
  security incidents and reduces the need for manual intervention.

- Security findings and reports: GuardDuty provides detailed security findings and reports that include information
  about detected threats, affected AWS resources, and recommended remediation actions. These findings can be accessed
  through the AWS Management Console or retrieved via APIs for further analysis and reporting.

GuardDuty offers a scalable and flexible approach to threat detection within AWS environments, providing organizations
with an additional layer of security to proactively identify and respond to potential security risks.

### references

- https://aws.amazon.com/guardduty/
- https://github.com/cloudposse/terraform-aws-guardduty

</details>

## 1.211.0 (2023-05-30T16:30:47Z)

<details>
  <summary>Upstream `aws-inspector` @milldr (#700)</summary>

### what

Upstream `aws-inspector` from past engagement

### why

- This component was never upstreamed and now were want to use it again
- AWS Inspector is a security assessment service offered by Amazon Web Services (AWS). It helps you analyze and evaluate
  the security and compliance of your applications and infrastructure deployed on AWS. AWS Inspector automatically
  assesses the resources within your AWS environment, such as Amazon EC2 instances, for potential security
  vulnerabilities and deviations from security best practices. Here are some key features and functionalities of AWS
  Inspector:

  - Security Assessments: AWS Inspector performs security assessments by analyzing the behavior of your resources and
    identifying potential security vulnerabilities. It examines the network configuration, operating system settings,
    and installed software to detect common security issues.

  - Vulnerability Detection: AWS Inspector uses a predefined set of rules to identify common vulnerabilities,
    misconfigurations, and security exposures. It leverages industry-standard security best practices and continuously
    updates its knowledge base to stay current with emerging threats.

  - Agent-Based Architecture: AWS Inspector utilizes an agent-based approach, where you install an Inspector agent on
    your EC2 instances. The agent collects data about the system and its configuration, securely sends it to AWS
    Inspector, and allows for more accurate and detailed assessments.

  - Security Findings: After performing an assessment, AWS Inspector generates detailed findings that highlight security
    vulnerabilities, including their severity level, impact, and remediation steps. These findings can help you
    prioritize and address security issues within your AWS environment.

  - Integration with AWS Services: AWS Inspector seamlessly integrates with other AWS services, such as AWS
    CloudFormation, AWS Systems Manager, and AWS Security Hub. This allows you to automate security assessments, manage
    findings, and centralize security information across your AWS infrastructure.

### references

DEV-942

</details>

## 1.210.1 (2023-05-27T18:52:11Z)

### 🚀 Enhancements

<details>
  <summary>Fix tags @aknysh (#701)</summary>

### what

- Fix tags

### why

- Typo

</details>

### 🐛 Bug Fixes

<details>
  <summary>Fix tags @aknysh (#701)</summary>

### what

- Fix tags

### why

- Typo

</details>

## 1.210.0 (2023-05-25T22:06:24Z)

<details>
  <summary>EKS FAQ for Addons @milldr (#699)</summary>

### what

Added docs for EKS Cluster Addons

### why

FAQ, requested for documentation

### references

DEV-846

</details>

## 1.209.0 (2023-05-25T19:05:53Z)

<details>
  <summary>Update ALB controller IAM policy @Nuru (#696)</summary>

### what

- Update `eks/alb-controller` controller IAM policy

### why

- Email from AWS:
  > On June 1, 2023, we will be adding an additional layer of security to ELB ‘Create*' API calls where API callers must
  > have explicit access to add tags in their Identity and Access Management (IAM) policy. Currently, access to attach
  > tags was implicitly granted with access to 'Create*' APIs.

### references

- [Updated IAM policy](https://github.com/kubernetes-sigs/aws-load-balancer-controller/pull/3068)

</details>

## 1.208.0 (2023-05-24T11:12:15Z)

<details>
  <summary>Managed rules for AWS Config @zdmytriv (#690)</summary>

### what

- Added option to specify Managed Rules for AWS Config in addition to Conformance Packs

### why

- Managed rules will allows to add and tune AWS predefined rules in addition to Conformance Packs

### references

- [About AWS Config Manager Rules](https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config_use-managed-rules.html)
- [List of AWS Config Managed Rules](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html)

</details>

## 1.207.0 (2023-05-22T18:40:06Z)

<details>
  <summary>Corrections to `dms` components @milldr (#658)</summary>

### what

- Corrections to `dms` components

### why

- outputs were incorrect
- set pass and username with ssm

### references

- n/a

</details>

## 1.206.0 (2023-05-20T19:41:35Z)

<details>
  <summary>Upgrade S3 Bucket module to support recent changes made by AWS team regarding ACL @zdmytriv (#688)</summary>

### what

- Upgraded S3 Bucket module version

### why

- Upgrade S3 Bucket module to support recent changes made by AWS team regarding ACL

### references

- https://github.com/cloudposse/terraform-aws-s3-bucket/pull/178

</details>

## 1.205.0 (2023-05-19T23:55:14Z)

<details>
  <summary>feat: add lambda monitors to datadog-monitor @dudymas (#686)</summary>

### what

- add lambda error monitor
- add datadog lambda log forwarder config monitor

### why

- Observability

</details>

## 1.204.1 (2023-05-19T19:54:05Z)

### 🚀 Enhancements

<details>
  <summary>Update `module "datadog_configuration"` modules @aknysh (#684)</summary>

### what

- Update `module "datadog_configuration"` modules

### why

- The module does not accept the `region` variable
- The module must be always enabled to be able to read the Datadog API keys even if the component is disabled

</details>

## 1.204.0 (2023-05-18T20:31:49Z)

<details>
  <summary>`datadog-agent` bugfixes @Benbentwo (#681)</summary>

### what

- update datadog agent to latest
- remove variable in datadog configuration

</details>

## 1.203.0 (2023-05-18T19:44:08Z)

<details>
  <summary>Update `vpc` and `eks/cluster` components @aknysh (#677)</summary>

### what

- Update `vpc` and `eks/cluster` components

### why

- Use latest module versions

- Take into account `var.availability_zones` for the EKS cluster itself. Only the `node-group` module was using
  `var.availability_zones` to use the subnets from the provided AZs. The EKS cluster (control plane) was using all the
  subnets provisioned in a VPC. This caused issues because EKS is not available in all AZs in a region, e.g. it's not
  available in `us-east-1e` b/c of a limited capacity, and when using all AZs from `us-east-1`, the deployment fails

- The latest version of the `vpc` component (which was updated in this PR as well) has the outputs to get a map of AZs
  to the subnet IDs in each AZ

```
  # Get only the public subnets that correspond to the AZs provided in `var.availability_zones`
  # `az_public_subnets_map` is a map of AZ names to list of public subnet IDs in the AZs
  public_subnet_ids = flatten([for k, v in local.vpc_outputs.az_public_subnets_map : v if contains(var.availability_zones, k)])

  # Get only the private subnets that correspond to the AZs provided in `var.availability_zones`
  # `az_private_subnets_map` is a map of AZ names to list of private subnet IDs in the AZs
  private_subnet_ids = flatten([for k, v in local.vpc_outputs.az_private_subnets_map : v if contains(var.availability_zones, k)])
```

</details>

## 1.202.0 (2023-05-18T16:15:12Z)

<details>
  <summary>feat: adds ability to list principals of Lambdas allowed to access ECR @gberenice (#680)</summary>

### what

- This change allows listing IDs of the accounts allowed to consume ECR.

### why

- This is supported by [terraform-aws-ecr](https://github.com/cloudposse/terraform-aws-ecr/tree/main), but not the
  component.

### references

- N/A

</details>

## 1.201.0 (2023-05-18T15:08:54Z)

<details>
  <summary>Introducing AWS Config component @zdmytriv (#675)</summary>

### what

- Added AWS Config and related `config-bucket` components

### why

- Added AWS Config and related `config-bucket` components

### references

</details>

## 1.200.1 (2023-05-18T14:52:10Z)

### 🚀 Enhancements

<details>
  <summary>Fix `datadog` components @aknysh (#679)</summary>

### what

- Fix all `datadog` components

### why

- Variable `region` is not supported by the `datadog-configuration/modules/datadog_keys` submodule

</details>

## 1.200.0 (2023-05-17T09:19:40Z)

- No changes

## 1.199.0 (2023-05-16T15:01:56Z)

<details>
  <summary>`eks/alb-controller-ingress-group`: Corrected Tags to pull LB Data Resource @milldr (#676)</summary>

### what

- corrected tag reference for pull lb data resource

### why

- the tags that are used to pull the ALB that's created should be filtering using the same group_name that is given when
  the LB is created

### references

- n/a

</details>

## 1.198.3 (2023-05-15T20:01:18Z)

### 🐛 Bug Fixes

<details>
  <summary>Correct `cloudtrail` Account-Map Reference @milldr (#673)</summary>

### what

- Correctly pull Audit account from `account-map` for `cloudtrail`
- Remove `SessionName` from EKS RBAC user name wrongly added in #668

### why

- account-map remote state was missing from the `cloudtrail` component
- Account names should be pulled from account-map, not using a variable
- Session Name automatically logged in `user.extra.sessionName.0` starting at Kubernetes 1.20, plus addition had a typo
  and was only on Teams, not Team Roles

### references

- Resolves change requests https://github.com/cloudposse/terraform-aws-components/pull/638#discussion_r1193297727 and
  https://github.com/cloudposse/terraform-aws-components/pull/638#discussion_r1193298107
- Closes #672
- [Internal Slack thread](https://cloudposse.slack.com/archives/CA4TC65HS/p1684122388801769)

</details>

## 1.198.2 (2023-05-15T19:47:39Z)

### 🚀 Enhancements

<details>
  <summary>bump config yaml dependency on account component as it still depends on hashicorp template provider @lantier (#671)</summary>

### what

- Bump [cloudposse/config/yaml](https://github.com/cloudposse/terraform-yaml-config) module dependency from version
  1.0.1 to 1.0.2

### why

- 1.0.1 still uses hashicorp/template provider, which has no M1 binary equivalent, 1.0.2 already uses the cloudposse
  version which has the binary

### references

- (https://github.com/cloudposse/terraform-yaml-config/releases/tag/1.0.2)

</details>

## 1.198.1 (2023-05-15T18:55:09Z)

### 🐛 Bug Fixes

<details>
  <summary>Fixed `route53-resolver-dns-firewall` for the case when logging is disabled @zdmytriv (#669)</summary>

### what

- Fixed `route53-resolver-dns-firewall` for the case when logging is disabled

### why

- Component still required bucket when logging disabled

### references

</details>

## 1.198.0 (2023-05-15T17:37:47Z)

<details>
  <summary>Add `aws-shield` component @aknysh (#670)</summary>

### what

- Add `aws-shield` component

### why

- The component is responsible for enabling AWS Shield Advanced Protection for the following resources:

  - Application Load Balancers (ALBs)
  - CloudFront Distributions
  - Elastic IPs
  - Route53 Hosted Zones

This component also requires that the account where the component is being provisioned to has been
[subscribed to AWS Shield Advanced](https://docs.aws.amazon.com/waf/latest/developerguide/enable-ddos-prem.html).

</details>

## 1.197.2 (2023-05-15T15:25:39Z)

### 🚀 Enhancements

<details>
  <summary>EKS terraform module variable type fix @PiotrPalkaSpotOn (#674)</summary>

### what

- use `bool` rather than `string` type for a variable that's designed to hold `true`/`false` value

### why

- using `string` makes the
  [if .Values.pvc_enabled](https://github.com/SpotOnInc/cloudposse-actions-runner-controller-tf-module-bugfix/blob/f224c7a4ee8b2ab4baf6929710d6668bd8fc5e8c/modules/eks/actions-runner-controller/charts/actions-runner/templates/runnerdeployment.yaml#L1)
  condition always true and creates persistent volumes even if they're not intended to use

</details>

## 1.197.1 (2023-05-11T20:39:03Z)

### 🐛 Bug Fixes

<details>
  <summary>Remove (broken) root access to EKS clusters @Nuru (#668)</summary>

### what

- Remove (broken) root access to EKS clusters
- Include session name in audit trail of users accessing EKS

### why

- Test code granting access to all `root` users and roles was accidentally left in #645 and breaks when Tenants are part
  of account names
- There is no reason to allow `root` users to access EKS clusters, so even when this code worked it was wrong
- Audit trail can keep track of who is performing actions

### references

- https://aws.github.io/aws-eks-best-practices/security/docs/iam/#use-iam-roles-when-multiple-users-need-identical-access-to-the-cluster

</details>

## 1.197.0 (2023-05-11T17:59:40Z)

<details>
  <summary>`rds` Component readme update @Benbentwo (#667)</summary>

### what

- Updating default example from mssql to postgres

</details>

## 1.196.0 (2023-05-11T17:56:41Z)

<details>
  <summary>Update `vpc-flow-logs` @milldr (#649)</summary>

### what

- Modernized `vpc-flow-logs` with latest conventions

### why

- Old version of the component was significantly out of date
- #498

### references

- DEV-880

</details>

## 1.195.0 (2023-05-11T07:27:29Z)

<details>
  <summary>Add `iam-policy` to `ecs-service` @milldr (#663)</summary>

### what

Add an option to attach the `iam-policy` resource to `ecs-service`

### why

This policy is already created, but is missing its attachment. We should attach this to the resource when enabled

### references

https://cloudposse.slack.com/archives/CA4TC65HS/p1683729972134479

</details>

## 1.194.0 (2023-05-10T18:36:37Z)

<details>
  <summary>upstream `acm` and `datadog-integration` @Benbentwo (#666)</summary>

### what

- ACM allows disabling `*.my.domain`
- Datadog-Integration supports allow-list'ing regions

</details>

## 1.193.0 (2023-05-09T16:00:08Z)

<details>
  <summary>Add `route53-resolver-dns-firewall` and `network-firewall` components @aknysh (#651)</summary>

### what

- Add `route53-resolver-dns-firewall` component
- Add `network-firewall` component

### why

- The `route53-resolver-dns-firewall` component is responsible for provisioning
  [Route 53 Resolver DNS Firewall](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-dns-firewall.html)
  resources, including Route 53 Resolver DNS Firewall, domain lists, firewall rule groups, firewall rules, and logging
  configuration

- The `network-firewall` component is responsible for provisioning
  [AWS Network Firewall](https://aws.amazon.com/network-firewal) resources, including Network Firewall, firewall policy,
  rule groups, and logging configuration

</details>

## 1.192.0 (2023-05-09T15:40:43Z)

<details>
  <summary>[ecs-service] Added IAM policies for ecspresso deployments @goruha (#659)</summary>

### what

- [ecs-service] Added IAM policies for [Ecspresso](https://github.com/kayac/ecspresso) deployments

</details>

## 1.191.0 (2023-05-05T22:16:44Z)

<details>
  <summary>`elasticsearch` Corrections @milldr (#662)</summary>

### what

- Modernize Elasticsearch component

### why

- `elasticsearch` was not deployable as is. Added up-to-date config

### references

- n/a

</details>

## 1.190.0 (2023-05-05T18:46:26Z)

<details>
  <summary>fix: remove stray component.yaml in lambda @dudymas (#661)</summary>

### what

- Remove the `component.yaml` in the lambda component

### why

- Vendoring would potentially cause conflicts

</details>

## 1.189.0 (2023-05-05T18:22:04Z)

<details>
  <summary>fix: eks/efs-controller iam policy updates @dudymas (#660)</summary>

### what

- Update the iam policy for eks/efs-controller

### why

- Older permissions will not work with new versions of the controller

### references

- [official iam policy sample](https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/docs/iam-policy-example.json)

</details>

## 1.188.0 (2023-05-05T17:05:23Z)

<details>
  <summary>Move `eks/efs` to `efs` @milldr (#653)</summary>

### what

- Moved `eks/efs` to `efs`

### why

- `efs` shouldn't be a submodule of `eks`. You can deploy EFS without EKS

### references

- n/a

</details>

## 1.187.0 (2023-05-04T23:04:26Z)

<details>
  <summary>ARC enhancement, aws-config bugfix, DNS documentation @Nuru (#655)</summary>

### what

- Fix bug in `aws-config`
- Enhance documentation to explain relationship of `dns-primary` and `dns-delegated` components and `dns` account
- [`eks/actions-runner-controller`] Add support for annotations and improve support for ephemeral storage

### why

- Bugfix
- Customer query, supersedes and closes #652
- Better support for longer lived jobs

### references

- https://github.com/actions/actions-runner-controller/issues/2562

</details>

## 1.186.0 (2023-05-04T18:15:31Z)

<details>
  <summary>Update `RDS` @Benbentwo (#657)</summary>

### what

- Update RDS Modules
- Allow disabling Monitoring Role

### why

- Monitoring not always needed
- Context.tf Updates in modules

</details>

## 1.185.0 (2023-04-26T21:30:24Z)

<details>
  <summary>Add `amplify` component @aknysh (#650)</summary>

### what

- Add `amplify` component

### why

- Terraform component to provision AWS Amplify apps, backend environments, branches, domain associations, and webhooks

### references

- https://aws.amazon.com/amplify

</details>

## 1.184.0 (2023-04-25T14:29:29Z)

<details>
  <summary>Upstream: `eks/ebs-controller` @milldr (#640)</summary>

### what

- Added component for `eks/ebs-controller`

### why

- Upstreaming this component for general use

### references

- n/a

</details>

## 1.183.0 (2023-04-24T23:21:17Z)

<details>
  <summary>GitHub OIDC FAQ @milldr (#648)</summary>

### what

Added common question for GHA

### why

This is asked frequently

### references

https://cloudposse.slack.com/archives/C04N39YPVAS/p1682355553255269

</details>

## 1.182.1 (2023-04-24T19:37:31Z)

### 🚀 Enhancements

<details>
  <summary>[aws-config] Update usage info, add "help" and "teams" commands @Nuru (#647)</summary>

### what

Update `aws-config` command:

- Add `teams` command and suggest "aws-config-teams" file name instead of "aws-config-saml" because we want to use
  "aws-config-teams" for both SAML and SSO logins with Leapp handling the difference.
- Add `help` command
- Add more extensive help
- Do not rely on script generated by `account-map` for command `main()` function

### why

- Reflect latest design pattern
- Improved user experience

</details>

## 1.182.0 (2023-04-21T17:20:14Z)

<details>
  <summary>Athena CloudTrail Queries @milldr (#638)</summary>

### what

- added cloudtrail integration to athena
- conditionally allow audit account to decrypt kms key used for cloudtrail

### why

- allow queries against cloudtrail logs from a centralized account (audit)

### references

n/a

</details>

## 1.181.0 (2023-04-20T22:00:24Z)

<details>
  <summary>Format Identity Team Access Permission Set Name @milldr (#646)</summary>

### what

- format permission set roles with hyphens

### why

- pretty Permission Set naming. We want `devops-super` to format to `IdentityDevopsSuperTeamAccess`

### references

https://github.com/cloudposse/refarch-scaffold/pull/127

</details>

## 1.180.0 (2023-04-20T21:12:28Z)

<details>
  <summary>Fix `s3-bucket` `var.bucket_name` @milldr (#637)</summary>

### what

changed default value for bucket name to empty string not null

### why

default bucket name should be empty string not null. Module checks against name length

### references

n/a

</details>

## 1.179.0 (2023-04-20T20:26:20Z)

<details>
  <summary>ecs-service: fix lint issues @kevcube (#636)</summary>

</details>

## 1.178.0 (2023-04-20T20:23:10Z)

<details>
  <summary>fix:aws-team-roles have stray locals @dudymas (#642)</summary>

### what

- remove locals from modules/aws-team-roles

### why

- breaks component when it tries to configure locals (the remote state for account_map isn't around)

</details>

## 1.177.0 (2023-04-20T05:13:53Z)

<details>
  <summary>Convert eks/cluster to aws-teams and aws-sso @Nuru (#645)</summary>

### what

- Convert `eks/cluster` to `aws-teams`
- Add `aws-sso` support to `eks/cluster`
- Undo automatic allowance of `identity` `aws-sso` permission sets into account roles added in #567

### why

- Keep in sync with other modules
- #567 is a silent privilege escalation and not needed to accomplish desired goals

</details>

## 1.176.1 (2023-04-19T14:20:27Z)

### 🚀 Enhancements

<details>
  <summary>fix: Use `vpc` without tenant @MaxymVlasov (#644)</summary>

### why

```bash
│ Error: Error in function call
│
│   on remote-state.tf line 10, in module "vpc_flow_logs_bucket":
│   10:   tenant      = coalesce(var.vpc_flow_logs_bucket_tenant_name, module.this.tenant)
│     ├────────────────
│     │ while calling coalesce(vals...)
│     │ module.this.tenant is ""
│     │ var.vpc_flow_logs_bucket_tenant_name is null
│
│ Call to function "coalesce" failed: no non-null, non-empty-string
│ arguments.
```

</details>

## 1.176.0 (2023-04-18T18:46:38Z)

<details>
  <summary>feat: cloudtrail-bucket can have acl configured @dudymas (#643)</summary>

### what

- add `acl` var to `cloudtrail-bucket` component

### why

- Creating new cloudtrail buckets will fail if the acl isn't set to private

### references

- This is part of
  [a security update from AWS](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-faq.html)

</details>

## 1.175.0 (2023-04-11T12:11:46Z)

<details>
  <summary>[argocd-repo] Added ArgoCD git commit notifications @goruha (#633)</summary>

### what

- [argocd-repo] Added ArgoCD git commit notifications

### why

- ArgoCD sync deployment

</details>

## 1.174.0 (2023-04-11T08:53:06Z)

<details>
  <summary>[argocd] Added github commit status notifications @goruha (#631)</summary>

### what

- [argocd] Added github commit status notifications

### why

- ArgoCD sync deployment fix concurrent issue

</details>

## 1.173.0 (2023-04-06T19:21:23Z)

<details>
  <summary>Missing Version Pins for Bats @milldr (#629)</summary>

### what

added missing provider version pins

### why

missing provider versions, required for bats

### references

#626 #628, #627

</details>

## 1.172.0 (2023-04-06T18:32:04Z)

<details>
  <summary>update datadog_lambda_forwarder ref for darwin_arm64 @kevcube (#626)</summary>

### what

- update datadog-lambda-forwarder module for darwin_arm64

### why

- run on Darwin_arm64 hardware

</details>

## 1.171.0 (2023-04-06T18:11:40Z)

<details>
  <summary>Version Pinning Requirements @milldr (#628)</summary>

### what

- missing bats requirements resolved

### why

- PR #627 missed a few bats requirements in submodules

### references

- #627
- #626

</details>

## 1.170.0 (2023-04-06T17:38:24Z)

<details>
  <summary>Bats Version Pinning @milldr (#627)</summary>

### what

- upgraded pattern for version pinning

### why

- bats would fail for all of these components unless these versions are pinned as such

### references

- https://github.com/cloudposse/terraform-aws-components/pull/626

</details>

## 1.169.0 (2023-04-05T20:28:39Z)

<details>
  <summary>[eks/actions-runner-controller]: support Runner Group, webhook queue size @Nuru (#621)</summary>

### what

- `eks/actions-runner-controller`
  - Support
    [Runner Groups](https://docs.github.com/en/actions/hosting-your-own-runners/managing-access-to-self-hosted-runners-using-groups)
  - Enable configuration of the webhook queue size limit
  - Change runner controller Docker image designation
- Add documentation on Runner Groups and Autoscaler configuration

### why

- Enable separate access control to self-hosted runners
- For users that launch a large number of jobs in a short period of time, allow bigger queues to avoid losing jobs
- Maintainers recommend new tag format. `ghcr.io` has better rate limits than `docker.io`.

### references

- https://github.com/actions/actions-runner-controller/issues/2056

</details>

## 1.168.0 (2023-04-04T21:48:58Z)

<details>
  <summary>s3-bucket: use cloudposse template provider for arm64 @kevcube (#618)</summary>

### what

- use cloud posse's template provider

### why

- arm64
- also this provider was not pinned in versions.tf so that had to be fixed somehow

### references

- closes #617

</details>

## 1.167.0 (2023-04-04T18:14:45Z)

<details>
  <summary>chore: aws-sso modules updated to 1.0.0 @dudymas (#623)</summary>

### what

- upgrade aws-sso modules: permission_sets, sso_account_assignments, and sso_account_assignments_root

### why

- upstream updates

</details>

## 1.166.0 (2023-04-03T13:39:53Z)

<details>
  <summary>Add `datadog-synthetics` component @aknysh (#619)</summary>

### what

- Add `datadog-synthetics` component

### why

- This component is responsible for provisioning Datadog synthetic tests

- Supports Datadog synthetics private locations

  - https://docs.datadoghq.com/getting_started/synthetics/private_location
  - https://docs.datadoghq.com/synthetics/private_locations

- Synthetic tests allow you to observe how your systems and applications are performing using simulated requests and
  actions from the AWS managed locations around the globe and to monitor internal endpoints from private locations

</details>

## 1.165.0 (2023-03-31T22:11:26Z)

<details>
  <summary>Update `eks/cluster` README @milldr (#616)</summary>

### what

- Updated the README with EKS cluster

### why

The example stack is outdated. Add notes for Github OIDC and karpenter

### references

https://cloudposse.atlassian.net/browse/DEV-835

</details>

## 1.164.1 (2023-03-30T20:03:15Z)

### 🚀 Enhancements

<details>
  <summary>spacelift: Update README.md example login policy @johncblandii (#597)</summary>

### what

- Added support for allowing spaces read access to all members
- Added a reference for allowing spaces write access to the "Developers" group

### why

- Spacelift moved to Spaces Access Control

### references

- https://docs.spacelift.io/concepts/spaces/access-control

</details>

## 1.164.0 (2023-03-30T16:25:28Z)

<details>
  <summary>Update several component Readmes @Benbentwo (#611)</summary>

### what

- Update Readmes of many components from Refarch Docs

</details>

## 1.163.0 (2023-03-29T19:52:46Z)

<details>
  <summary>add providers to `mixins` folder @Benbentwo (#613)</summary>

### what

- Copies some common providers to the mixins folder

### why

- Have a central place where our common providers are held.

</details>

## 1.162.0 (2023-03-29T19:30:15Z)

<details>
  <summary>Added ArgoCD GitHub notification subscription @goruha (#615)</summary>

### what

- Added ArgoCD GitHub notification subscription

### why

- To use synchronous deployment pattern

</details>

## 1.161.1 (2023-03-29T17:20:27Z)

### 🚀 Enhancements

<details>
  <summary>waf component, update dependency versions for  aws provider and waf terraform module @arcaven (#612)</summary>

### what

- updates to waf module:
  - aws provider from ~> 4.0 to => 4.0
  - module cloudposse/waf/aws from 0.0.4 to 0.2.0
  - different recommended catalog entry

### why

- @aknysh suggested some updates before we start using waf module

</details>

## 1.161.0 (2023-03-28T19:51:27Z)

<details>
  <summary>Quick fixes to EKS/ARC arm64 Support  @Nuru (#610)</summary>

### what

- While supporting EKS/ARC `arm64`, continue to deploy `amd64` by default
- Make `tolerations.value` optional

### why

- Majority of echosystem support is currently `amd64`
- `tolerations.value` is option in Kubernetes spec

### references

- Corrects issue which escaped review in #609

</details>

## 1.160.0 (2023-03-28T18:26:20Z)

<details>
  <summary>Upstream EKS/ARC amd64 Support @milldr (#609)</summary>

### what

Added arm64 support for eks/arc

### why

when supporting both amd64 and arm64, we need to select the correct architecture

### references

https://github.com/cloudposse/infra-live/pull/265

</details>

## 1.159.0 (2023-03-27T16:19:29Z)

<details>
  <summary>Update account-map to output account information for aws-config script @Nuru (#608)</summary>

### what

- Update `account-map` to output account information for `aws-config` script
- Output AWS profile name for root of credential chain

### why

- Enable `aws-config` to output account IDs and to generate configuration for "AWS Extend Switch Roles" browser plugin
- Support multiple namespaces in a single infrastructure repo

</details>

<details>
  <summary>Update CODEOWNERS to remove contributors @Nuru (#607)</summary>

### what

- Update CODEOWNERS to remove contributors

### why

- Require approval from engineering team (or in some cases admins) for all changes, to keep better quality control on
  this repo

</details>

## 1.158.0 (2023-03-27T03:41:43Z)

<details>
  <summary>Upstream latest datadog-agent and datadog-configuration updates @nitrocode (#598)</summary>

### what

- Upstream latest datadog-agent and datadog-configuration updates

### why

- datadog irsa role
- removing unused input vars
- default to `public.ecr.aws` images
- ignore deprecated `default.auto.tfvars`
- move `datadog-agent` to `eks/` subfolder for consistency with other helm charts

### references

N/A

</details>

## 1.157.0 (2023-03-24T19:12:17Z)

<details>
  <summary>Remove `root_account_tenant_name`  @milldr (#605)</summary>

### what

- bumped ecr
- remove unnecessary variable

### why

- ECR version update
- We shouldn't need to set `root_account_tenant_name` in providers
- Some Terraform docs are out-of-date

### references

- n/a

</details>

## 1.156.0 (2023-03-23T21:03:46Z)

<details>
  <summary>exposing variables from 2.0.0 of `VPC` module @Benbentwo (#604)</summary>

### what

- Adding vars for vpc module and sending them directly to module

### references

- https://github.com/cloudposse/terraform-aws-vpc/blob/master/variables.tf#L10-L44

</details>

## 1.155.0 (2023-03-23T02:01:29Z)

<details>
  <summary>Add Privileged Option for GH OIDC @milldr (#603)</summary>

### what

- allow gh oidc role to use privileged as option for reading tf backend

### why

- If deploying GH OIDC with a component that needs to be applied with SuperAdmin (aws-teams) we need to set privileged
  here

### references

- https://cloudposse.slack.com/archives/C04N39YPVAS/p1679409325357119

</details>

## 1.154.0 (2023-03-22T17:40:35Z)

<details>
  <summary>update `opsgenie-team` to be delete-able via `enabled: false` @Benbentwo (#589)</summary>

### what

- Uses Datdaog Configuration as it's source of datadog variables
- Now supports `enabled: false` on a team to destroy it.

</details>

## 1.153.0 (2023-03-21T19:22:03Z)

<details>
  <summary>Upstream AWS Teams components  @milldr (#600)</summary>

### what

- added eks view only policy

### why

- Provided updates from recent contracts

### references

- https://github.com/cloudposse/refarch-scaffold/pull/99

</details>

## 1.152.0 (2023-03-21T15:42:51Z)

<details>
  <summary>upstream 'datadog-lambda-forwarder' @gberenice (#601)</summary>

### what

- Upgrade 'datadog-lambda-forwarder' component to v1.3.0

### why

- Be able [to forward Cloudwatch Events](https://github.com/cloudposse/terraform-aws-datadog-lambda-forwarder/pull/48)
  via components.

### references

- N/A

</details>

## 1.151.0 (2023-03-15T15:56:20Z)

<details>
  <summary>Upstream `eks/external-secrets-operator` @milldr (#595)</summary>

### what

- Adding new module for `eks/external-secrets-operator`

### why

- Other customers want to use this module now, and it needs to be upstreamed

### references

- n/a

</details>

## 1.150.0 (2023-03-14T20:20:41Z)

<details>
  <summary>chore(spacelift): update with dependency resource @dudymas (#594)</summary>

### what

- update spacelift component to 0.55.0

### why

- support feature flag for spacelift_stack_dependency resource

### references

- [spacelift module 0.55.0](https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/releases/tag/0.55.0)

</details>

## 1.149.0 (2023-03-13T15:25:25Z)

<details>
  <summary>Fix SSO SAML provider fixes @goruha (#592)</summary>

### what

- Fix SSO SAML provider fixes

</details>

## 1.148.0 (2023-03-10T18:07:36Z)

<details>
  <summary>ArgoCD SSO improvements @goruha (#590)</summary>

### what

- ArgoCD SSO improvements

</details>

## 1.147.0 (2023-03-10T17:52:18Z)

<details>
  <summary>Upstream: `eks/echo-server` @milldr (#591)</summary>

### what

- Adding the `ingress.alb.group_name` annotation to Echo Server

### why

- Required to set the ALB specifically, rather than using the default

### references

- n/a

</details>

## 1.146.0 (2023-03-08T23:13:13Z)

<details>
  <summary>Improve platform and external-dns for release engineering @goruha (#588)</summary>

### what

- `eks/external-dns` support `dns-primary`
- `eks/platform` support json query remote components outputs

### why

- `vanity domain` pattern support by `eks/external-dns`
- Improve flexibility of `eks/platform`

</details>

## 1.145.0 (2023-03-07T00:28:25Z)

<details>
  <summary>`eks/actions-runner-controller`: use coalesce @Benbentwo (#586)</summary>

### what

- use coalesce instead of try, as we need a value passed in here

</details>

## 1.144.0 (2023-03-05T20:24:09Z)

<details>
  <summary>Upgrade Remote State to `1.4.1` @milldr (#585)</summary>

### what

- Upgrade _all_ remote state modules (`cloudposse/stack-config/yaml//modules/remote-state`) to version `1.4.1`

### why

- In order to use go templating with Atmos, we need to use the latest cloudposse/utils version. This version is
  specified by `1.4.1`

### references

- https://github.com/cloudposse/terraform-yaml-stack-config/releases/tag/1.4.1

</details>

## 1.143.0 (2023-03-02T18:07:53Z)

<details>
  <summary>bugfix: rds anomalies monitor not sending team information @Benbentwo (#583)</summary>

### what

- Update monitor to have default CP tags

</details>

## 1.142.0 (2023-03-02T17:49:40Z)

<details>
  <summary>datadog-lambda-forwarder: if s3_buckets not set, module fails @kevcube (#581)</summary>

This module attempts to do length() on the value for s3_buckets.

We are not using s3_buckets, and it defaults to null, so length() fails.

</details>

## 1.141.0 (2023-03-01T19:10:07Z)

<details>
  <summary>`datadog-monitors`: Team Grouping @Benbentwo (#580)</summary>

### what

- grouping by team helps ensure the team tag is sent to Opsgenie

### why

- ensures most data is fed to a valid team tag instead of `@opsgenie-`

</details>

## 1.140.0 (2023-02-28T18:47:44Z)

<details>
  <summary>`spacelift` add missing `var.region` @johncblandii (#574)</summary>

### what

- Added the missing `var.region`

### why

- The AWS provider requires it and it was not available

### references

</details>

## 1.139.0 (2023-02-28T18:46:35Z)

<details>
  <summary>datadog monitors improvements @Benbentwo (#579)</summary>

### what

- Datadog monitor improvements
  - Prepends `(<stack slug>)` e.g. `(tenant-environment-stage)`
  - Fixes some messages that had improper syntax - dd uses `{{ var.name }}`

### why

- Datadog monitor improvements

</details>

## 1.138.0 (2023-02-28T18:45:48Z)

<details>
  <summary>update `account` readme.md @Benbentwo (#570)</summary>

### what

- Updated account readme

</details>

## 1.137.0 (2023-02-27T20:39:34Z)

<details>
  <summary>Update `eks/cluster` @Benbentwo (#578)</summary>

### what

- Update EKS Cluster Module to re-include addons

</details>

## 1.136.0 (2023-02-27T17:36:47Z)

<details>
  <summary>Set spacelift-worker-pool ami explicitly to x86_64 @arcaven (#577)</summary>

### why

- autoscaling group for spacelift-worker-pool will fail to launch when new arm64 images return first
- arm64 ami image is being returned first at the moment in us-east-1

### what

- set spacelift-worker-pool ami statically to return only x86_64 results

### references

- Spacelift Worker Pool ASG may fail to scale due to ami/instance type mismatch #575
- Note: this is an alternative to spacelift-worker-pool README update and AMI limits #573 which I read after, but I
  think this filter approach will be more easily be refactored into setting this as an attribute in variables.tf in the
  near future

</details>

## 1.135.0 (2023-02-27T13:56:48Z)

<details>
  <summary>github-runners add support for runner groups @johncblandii (#569)</summary>

### what

- Added optional support for separating runners by groups

NOTE: I don't know if the default of `default` is valid or if it is `Default`. I'll confirm this soon.

### why

- Groups are supported by GitHub and allow for Actions to target specific runners by group vs by label

### references

- https://docs.github.com/en/actions/hosting-your-own-runners/managing-access-to-self-hosted-runners-using-groups

</details>

## 1.134.0 (2023-02-24T20:59:40Z)

<details>
  <summary>[account-map] Update remote config module version @goruha (#572)</summary>

### what

- Update remote config module version `1.4.1`

### why

- Solve terraform module version conflict

</details>

## 1.133.0 (2023-02-24T17:55:52Z)

<details>
  <summary>Fix ArgoCD minor issues @goruha (#571)</summary>

### what

- Fix slack notification annotations
- Fix CRD creation order

### why

- Fix ArgoCD bootstrap

</details>

## 1.132.0 (2023-02-23T04:33:29Z)

<details>
  <summary>Add spacelift-policy component @nitrocode (#556)</summary>

### what

- Add spacelift-policy component

### why

- De-couple policy creation from admin and child stacks
- Auto attach policies to remove additional terraform management of resources

### references

- Depends on PR https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/pull/134

</details>

## 1.131.0 (2023-02-23T01:13:58Z)

<details>
  <summary>SSO upgrades and Support for Assume Role from Identity Users @johncblandii (#567)</summary>

### what

- Upgraded `aws-sso` to use `0.7.1` modules
- Updated `account-map/modules/roles-to-principals` to support assume role from SSO users in the identity account
- Adjusted `aws-sso/policy-Identity-role-RoleAccess.tf` to use the identity account name vs the stage so it supports
  names like `core-identity` instead of just `identity`

### why

- `aws-sso` users could not assume role to plan/apply terraform locally
- using `core-identity` as a name broke the `aws-sso` policy since account `identity` does not exist in
  `full_account_map`

### references

</details>

## 1.130.0 (2023-02-21T18:33:53Z)

<details>
  <summary>Add Redshift component @max-lobur (#563)</summary>

### what

- Add Redshift

### why

- Fulfilling the AWS catalog

### references

- https://github.com/cloudposse/terraform-aws-redshift-cluster

</details>

## 1.129.0 (2023-02-21T16:45:43Z)

<details>
  <summary>update dd agent docs @Benbentwo (#565)</summary>

### what

- Update Datadog Docs to be more clear on catalog entry

</details>

## 1.128.0 (2023-02-18T16:28:11Z)

<details>
  <summary>feat: updates spacelift to support policies outside of the comp folder @Gowiem (#522)</summary>

### what

- Adds back `policies_by_name_path` variable to spacelift component

### why

- Allows specifying spacelift policies outside of the component folder

### references

- N/A

</details>

## 1.127.0 (2023-02-16T17:53:31Z)

<details>
  <summary>[sso-saml-provider] Upstream SSO SAML provider component @goruha (#562)</summary>

### what

- [sso-saml-provider] Upstream SSO SAML provider component

### why

- Required for ArgoCD

</details>

## 1.126.0 (2023-02-14T23:01:00Z)

<details>
  <summary>upstream `opsgenie-team` @Benbentwo (#561)</summary>

### what

- Upstreams latest opsgenie-team component

</details>

## 1.125.0 (2023-02-14T21:45:32Z)

<details>
  <summary>[eks/argocd] Upstream ArgoCD @goruha (#560)</summary>

### what

- Upstream `eks/argocd`

</details>

## 1.124.0 (2023-02-14T17:34:29Z)

<details>
  <summary>`aws-backup` upstream @Benbentwo (#559)</summary>

### what

- Update `aws-backup` to latest

</details>

## 1.123.0 (2023-02-13T22:42:56Z)

<details>
  <summary>upstream lambda pt2 @Benbentwo (#558)</summary>

### what

- Add archive zip
- Change to python (no compile)

</details>

## 1.122.0 (2023-02-13T21:24:02Z)

<details>
  <summary>upstream `lambda` @Benbentwo (#557)</summary>

### what

- Upstream `lambda` component

### why

- Quickly deploy serverless code

</details>

## 1.121.0 (2023-02-13T16:59:16Z)

<details>
  <summary>Upstream `ACM` and `eks/Platform` for release_engineering  @Benbentwo (#555)</summary>

### what

- ACM Component outputs it's acm url
- EKS/Platform will deploy many terraform outputs to SSM

### why

- These components are required for CP Release Engineering Setup

</details>

## 1.120.0 (2023-02-08T16:34:25Z)

<details>
  <summary>Upstream datadog logs archive @Benbentwo (#552)</summary>

### what

- Upstream DD Logs Archive

</details>

## 1.119.0 (2023-02-07T21:32:25Z)

<details>
  <summary>Upstream `dynamodb` @milldr (#512)</summary>

### what

- Updated the `dynamodb` component

### why

- maintaining up-to-date upstream component

### references

- N/A

</details>

## 1.118.0 (2023-02-07T20:15:17Z)

<details>
  <summary>fix dd-forwarder: datadog service config depends on lambda arn config @raybotha (#531)</summary>

</details>

## 1.117.0 (2023-02-07T19:44:32Z)

<details>
  <summary>Upstream `spa-s3-cloudfront` @milldr (#500)</summary>

### what

- Added missing component from upstream `spa-s3-cloudfront`

### why

- We use this component to provision Cloudfront and related resources

### references

- N/A

</details>

## 1.116.0 (2023-02-07T00:52:27Z)

<details>
  <summary>Upstream `aurora-mysql` @milldr (#517)</summary>

### what

- Upstreaming both `aurora-mysql` and `aurora-mysql-resources`

### why

- Added option for allowing ingress by account name, rather than requiring CIDR blocks copy and pasted
- Replaced the deprecated provider for MySQL
- Resolved issues with Terraform perma-drift for the resources component with granting "ALL"

### references

- Old provider, archived: https://github.com/hashicorp/terraform-provider-mysql
- New provider: https://github.com/petoju/terraform-provider-mysql

</details>

## 1.115.0 (2023-02-07T00:49:59Z)

<details>
  <summary>Upstream `aurora-postgres` @milldr (#518)</summary>

### what

- Upstreaming `aurora-postgres` and `aurora-postgres-resources`

### why

- TLC for these components
- Added options for adding ingress by account
- Cleaned up the submodule for the resources component
- Support creating schemas
- Support conditionally pulling passwords from SSM, similar to `aurora-mysql`

</details>

## 1.114.0 (2023-02-06T17:09:31Z)

<details>
  <summary>`datadog-private-locations` update helm provider @Benbentwo (#549)</summary>

### what

- Updates Helm Provider to the latest

### why

- New API Version

</details>

## 1.113.0 (2023-02-06T02:26:22Z)

<details>
  <summary>Remove extra var from stack example @johncblandii (#550)</summary>

### what

- Stack example has an old variable defined

### why

- `The root module does not declare a variable named "eks_tags_enabled" but a value was found in file "uw2-automation-vpc.terraform.tfvars.json".`

### references

</details>

## 1.112.1 (2023-02-03T20:00:09Z)

### 🚀 Enhancements

<details>
  <summary>Fixed non-html tags that fails rendering on docusaurus @zdmytriv (#546)</summary>

### what

- Fixed non-html tags

### why

- Rendering has been failing on docusaurus mdx/jsx engine

</details>

## 1.112.0 (2023-02-03T19:02:57Z)

<details>
  <summary>`datadog-agent` allow values var merged @Benbentwo (#548)</summary>

### what

- Allows values to be passed in and merged to values file

### why

- Need to be able to easily override values files

</details>

## 1.111.0 (2023-01-31T23:02:57Z)

<details>
  <summary>Update echo and alb-controller-ingress-group @Benbentwo (#547)</summary>

### what

- Allows target group to be targeted by echo server

</details>

## 1.110.0 (2023-01-26T00:25:13Z)

<details>
  <summary>Chore/acme/bootcamp core tenant @dudymas (#543)</summary>

### what

- upgrade the vpn module in the ec2-client-vpn component
- and protect outputs on ec2-client-vpn

### why

- saml docs were broken in refarch-scaffold. module was trying to alter the cert provider

</details>

## 1.109.0 (2023-01-24T20:01:56Z)

<details>
  <summary>Chore/acme/bootcamp spacelift @dudymas (#545)</summary>

### what

- adjust the type of context_filters in spacelift

### why

- was getting errors trying to apply spacelift component

</details>

## 1.108.0 (2023-01-20T22:36:54Z)

<details>
  <summary>EC2 Client VPN Version Bump @Benbentwo (#544)</summary>

### what

- Bump Version of EC2 Client VPN

### why

- Bugfixes issue with TLS provider

### references

- https://github.com/cloudposse/terraform-aws-ec2-client-vpn/pull/58
- https://github.com/cloudposse/terraform-aws-ssm-tls-self-signed-cert/pull/20

</details>

## 1.107.0 (2023-01-19T17:34:33Z)

<details>
  <summary>Update pod security context schema in cert-manager @max-lobur (#538)</summary>

### what

Pod security context `enabled` field has been deprecated. Now you just specify the options and that's it. Update the
options per recent schema. See references

Tested on k8s 1.24

### why

- Otherwise it does not pass Deployment validation on newer clusters.

### references

https://github.com/cert-manager/cert-manager/commit/c17b11fa01455eb1b83dce0c2c06be555e4d53eb

</details>

## 1.106.0 (2023-01-18T15:36:52Z)

<details>
  <summary>Fix github actions runner controller default variables @max-lobur (#542)</summary>

### what

Default value for string is null, not false

### why

- Otherwise this does not pass schema when you deploy it without storage requests

</details>

## 1.105.0 (2023-01-18T15:24:11Z)

<details>
  <summary>Update k8s metrics-server to latest @max-lobur (#537)</summary>

### what

Upgrade metrics-server Tested on k8s 1.24 via `kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes"`

### why

- The previous one was so old that bitnami has even removed the chart.

</details>

## 1.104.0 (2023-01-18T14:52:58Z)

<details>
  <summary>Pin kubernetes provider in metrics-server @max-lobur (#541)</summary>

### what

- Pin the k8s provider version
- Update versions

### why

- Fix CI

### references

- https://github.com/cloudposse/terraform-aws-components/pull/537

</details>

## 1.103.0 (2023-01-17T21:09:56Z)

<details>
  <summary>fix(dns-primary/acm): include zone_name arg @dudymas (#540)</summary>

### what

- in dns-primary, revert version of acm module 0.17.0 -> 0.16.2 (17 is a preview)

### why

- primary zones must be specified now that names are trimmed before the dot (.)

</details>

## 1.102.0 (2023-01-17T16:09:59Z)

<details>
  <summary>Fix typo in karpenter-provisioner @max-lobur (#539)</summary>

### what

I formatted it last moment and did not notice that actually changed the object. Fixing that and reformatting all of it
so it's more obvious for future maintainers.

### why

- Fixing bug

### references

https://github.com/cloudposse/terraform-aws-components/pull/536

</details>

## 1.101.0 (2023-01-17T07:47:30Z)

<details>
  <summary>Support setting consolidation in karpenter-provisioner @max-lobur (#536)</summary>

### what

This is an alternative way of deprovisioning - proactive one.

```
There is another way to configure Karpenter to deprovision nodes called Consolidation.
This mode is preferred for workloads such as microservices and is incompatible with setting
up the ttlSecondsAfterEmpty . When set in consolidation mode Karpenter works to actively
reduce cluster cost by identifying when nodes can be removed as their workloads will run
on other nodes in the cluster and when nodes can be replaced with cheaper variants due
to a change in the workloads
```

### why

- To let users set a more aggressive deprovisioning strategy

### references

- https://ec2spotworkshops.com/karpenter/050_karpenter/consolidation.html

</details>

## 1.100.0 (2023-01-17T07:41:58Z)

<details>
  <summary>Sync karpenter chart values with the schema @max-lobur (#535)</summary>

### what

Based on
https://github.com/aws/karpenter/blob/92b3d4a0b029cae6a9d6536517ba42d70c3ebf8c/charts/karpenter/values.yaml#L129-L142
all these should go under settings.aws

### why

Ensure compatibility with the new charts

### references

Based on https://github.com/aws/karpenter/blob/92b3d4a0b029cae6a9d6536517ba42d70c3ebf8c/charts/karpenter/values.yaml

</details>

## 1.99.0 (2023-01-13T14:59:16Z)

<details>
  <summary>fix(aws-sso): dont hardcode account name for root @dudymas (#534)</summary>

### what

- remove hardcoding for root account moniker
- change default tenant from `gov` to `core` (now convention)

### why

- tenant is not included in the account prefix. In this case, changed to be 'core'
- most accounts do not use `gov` as the root tenant

</details>

## 1.98.0 (2023-01-12T00:12:36Z)

<details>
  <summary>Bump spacelift to latest @nitrocode (#532)</summary>

### what

- Bump spacelift to latest

### why

- Latest

### references

N/A

</details>

## 1.97.0 (2023-01-11T01:16:33Z)

<details>
  <summary>Upstream EKS Action Runner Controller @milldr (#528)</summary>

### what

- Upstreaming the latest additions for the EKS actions runner controller component

### why

- We've added additional features for the ARC runners, primarily adding options for ephemeral storage and persistent
  storage. Persistent storage can be used to add image caching with EFS
- Allow for setting a `webhook_startup_timeout` value different than `scale_down_delay_seconds`. Defaults to
  `scale_down_delay_seconds`

### references

- N/A

</details>

## 1.96.0 (2023-01-05T21:19:22Z)

<details>
  <summary>Datadog Upstreams and Account Settings @Benbentwo (#533)</summary>

### what

- Datadog Upgrades (Bugfixes for Configuration on default datadog URL)
- Account Settings Fixes for emoji support and updated budgets

### why

- Upstreams

</details>

## 1.95.0 (2023-01-04T23:44:35Z)

<details>
  <summary>fix(aws-sso): add missing tf update perms @dudymas (#530)</summary>

### what

- Changes for supporting [Refarch Scaffold](github.com/cloudposse/refarch-scaffold)
- TerraformUpdateAccess permission set added

### why

- Allow SSO users to update dynamodb/s3 for terraform backend

</details>

## 1.94.0 (2022-12-21T18:38:15Z)

<details>
  <summary>upstream `spacelift` @Benbentwo (#526)</summary>

### what

- Updated Spacelift Component to latest
- Updated README with new example

### why

- Upstreams

</details>

## 1.93.0 (2022-12-21T18:37:37Z)

<details>
  <summary>upstream `ecs` & `ecs-service` @Benbentwo (#529)</summary>

### what

- upstream
  - `ecs`
  - `ecs-service`

### why

- `enabled` flag correctly destroys resources
- bugfixes and improvements
- datadog support for ecs services

</details>

## 1.92.0 (2022-12-21T18:36:35Z)

<details>
  <summary>Upstream Datadog @Benbentwo (#525)</summary>

### what

- Datadog updates
- New `datadog-configuration` component for setting up share functions and making codebase more dry

</details>

## 1.91.0 (2022-11-29T17:17:58Z)

<details>
  <summary>CPLIVE-320: Set VPC to use region-less AZs @nitrocode (#524)</summary>

### what

- Set VPC to use region-less AZs

### why

- Prevent having to set VPC AZs within global region defaults

### references

- CPLIVE-320

</details>

## 1.90.2 (2022-11-20T05:41:14Z)

### 🚀 Enhancements

<details>
  <summary>Use cloudposse/template for arm support @nitrocode (#510)</summary>

### what

- Use cloudposse/template for arm support

### why

- The new cloudposse/template provider has a darwin arm binary for M1 laptops

### references

- https://github.com/cloudposse/terraform-provider-template
- https://registry.terraform.io/providers/cloudposse/template/latest

</details>

## 1.90.1 (2022-10-31T13:27:37Z)

### 🚀 Enhancements

<details>
  <summary>Allow vpc-peering to peer v2 to v2 @nitrocode (#521)</summary>

### what

- Allow vpc-peering to peer v2 to v2

### why

- Alternative to transit gateway

### references

N/A

</details>

## 1.90.0 (2022-10-31T13:24:38Z)

<details>
  <summary>Upstream iam-role component @nitrocode (#520)</summary>

### what

- Upstream iam-role component

### why

- Create simple IAM roles

### references

- https://github.com/cloudposse/terraform-aws-iam-role

</details>

## 1.89.0 (2022-10-28T15:35:38Z)

<details>
  <summary>[eks/actions-runner-controller] Auth via GitHub App, prefer webhook auto-scaling @Nuru (#519)</summary>

### what

- Support and prefer authentication via GitHub app
- Support and prefer webhook-based autoscaling

### why

- GitHub app is much more restricted, plus has higher API rate limits
- Webhook-based autoscaling is proactive without being overly expensive

</details>

## 1.88.0 (2022-10-24T15:40:47Z)

<details>
  <summary>Upstream iam-service-linked-roles @nitrocode (#516)</summary>

### what

- Upstream iam-service-linked-roles (thanks to @aknysh for writing it)

### why

- Centralized component to create IAM service linked roles

### references

- N/A

</details>

## 1.87.0 (2022-10-22T19:12:36Z)

<details>
  <summary>Add account-quotas component @Nuru (#515)</summary>

### what

- Add `account-quotas` component to manage account service quota increase requests

### why

- Add service quotas to the infrastructure that can be represented in code

### notes

Cloud Posse has a [service quotas module](https://github.com/cloudposse/terraform-aws-service-quotas), but it has
issues, such as not allowing the service to be specified by name, and not having well documented inputs. It also takes a
list input, but Atmos does not merge lists, so a map input is more appropriate. Overall I like this component better,
and if others do, too, I will replace the existing module (only at version 0.1.0) with this code.

</details>

## 1.86.0 (2022-10-19T07:28:11Z)

<details>
  <summary>Update EKS basic components @Nuru (#509)</summary>

### what && why

Update EKS cluster and basic Kubernetes components for better behavior on initial deployment and on `terraform destroy`.

- Update minimum Terraform version to 1.1.0 and use `one()` where applicable to manage resources that can be disabled
  with `count = 0` and for bug fixes regarding destroy behavior
- Update `terraform-aws-eks-cluster` to v2.5.0 for better destroy behavior
- Update all components' (plus `account-map/modules/`)`remote-state` to v1.2.0 for better destroy behavior
- Update all components' `helm-release` to v0.7.0 and move namespace creation via Kubernetes provider into it to avoid
  race conditions regarding creating IAM roles, Namespaces, and deployments, and to delete namespaces when destroyed
- Update `alb-controller` to deploy a default IngressClass for central, obvious configuration of shared default ingress
  for services that do not have special needs.
- Add `alb-controller-ingress-class` for the rare case when we want to deploy a non-default IngressClass outside of the
  component that will be using it
- Update `echo-server` to use the default IngressClass and not specify any configuration that affects other Ingresses,
  and remove dependence on `alb-controller-ingress-group` (which should be deprecated in favor of
  `alb-controller-ingress-class` and perhaps a specialized future `alb-controller-ingress`)
- Update `cert-manager` to remove `default.auto.tfvars` (which had a lot of settings) and add dependencies so that
  initial deployment succeeds in one `terraform apply` and destroy works in one `terraform destroy`
- Update `external-dns` to remove `default.auto.tfvars` (which had a lot of settings)
- Update `karpenter` to v0.18.0, fix/update IAM policy (README still needs work, but leaving that for another day)
- Update `karpenter-provisioner` to require Terraform 1.3 and make elements of the Provisioner configuration optional.
  Support block device mappings (previously broken). Avoid perpetual Terraform plan diff/drift caused by setting fields
  to `null`.
- Update `reloader`
- Update `mixins/provider-helm` to better support `terraform destroy` and to default the Kubernetes client
  authentication API version to `client.authentication.k8s.io/v1beta1`

### references

- https://github.com/cloudposse/terraform-aws-helm-release/pull/34
- https://github.com/cloudposse/terraform-aws-eks-cluster/pull/169
- https://github.com/cloudposse/terraform-yaml-stack-config/pull/56
- https://github.com/hashicorp/terraform/issues/32023

</details>

## 1.85.0 (2022-10-18T00:05:19Z)

<details>
  <summary>Upstream `github-runners` @milldr (#508)</summary>

### what

- Minor TLC updates for GitHub Runners ASG component

### why

- Maintaining up-to-date upstream

</details>

## 1.84.0 (2022-10-12T22:49:28Z)

<details>
  <summary>Fix feature allowing IAM users to assume team roles @Nuru (#507)</summary>

### what

- Replace `deny_all_iam_users` input with `iam_users_enabled`
- Fix implementation
- Provide more context for `bats` test failures

### why

- Cloud Posse style guide dictates that boolean feature flags have names ending with `_enabled`
- Previous implementation only removed 1 of 2 policy provisions that blocked IAM users from assuming a role, and
  therefore IAM users were still not allowed to assume a role. Since the previous implementation did not work, a
  breaking change (changing the variable name) does not need major warnings or a major version bump.
- Indication of what was being tested was too far removed from `bats` test failure message to be able to easily identify
  what module had failed

### notes

Currently, any component provisioned by SuperAdmin needs to have a special provider configuration that requires
SuperAdmin to provision the component. This feature is part of what is needed to enable SuperAdmin (an IAM User) to work
with "normal" provider configurations.

### references

- Breaks change introduced in #495, but that didn't work anyway.

</details>
