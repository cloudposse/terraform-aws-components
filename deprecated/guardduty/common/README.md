# Component: `guardduty/common`

This component is responsible for configuring GuardDuty and it should be used in tandem with the [guardduty/root](../root) component.

AWS GuardDuty is a managed threat detection service. It is designed to help protect AWS accounts and workloads by continuously monitoring for malicious activities and unauthorized behaviors. GuardDuty analyzes various data sources within your AWS environment, such as AWS CloudTrail logs, VPC Flow Logs, and DNS logs, to detect potential security threats.

Key features and components of AWS GuardDuty include:

- Threat detection: GuardDuty employs machine learning algorithms, anomaly detection, and integrated threat intelligence to identify suspicious activities, unauthorized access attempts, and potential security threats. It analyzes event logs and network traffic data to detect patterns, anomalies, and known attack techniques.

- Threat intelligence: GuardDuty leverages threat intelligence feeds from AWS, trusted partners, and the global community to enhance its detection capabilities. It uses this intelligence to identify known malicious IP addresses, domains, and other indicators of compromise.

- Real-time alerts: When GuardDuty identifies a potential security issue, it generates real-time alerts that can be delivered through AWS CloudWatch Events. These alerts can be integrated with other AWS services like Amazon SNS or AWS Lambda for immediate action or custom response workflows.

- Multi-account support: GuardDuty can be enabled across multiple AWS accounts, allowing centralized management and monitoring of security across an entire organization's AWS infrastructure. This helps to maintain consistent security policies and practices.

- Automated remediation: GuardDuty integrates with other AWS services, such as AWS Macie, AWS Security Hub, and AWS Systems Manager, to facilitate automated threat response and remediation actions. This helps to minimize the impact of security incidents and reduces the need for manual intervention.

- Security findings and reports: GuardDuty provides detailed security findings and reports that include information about detected threats, affected AWS resources, and recommended remediation actions. These findings can be accessed through the AWS Management Console or retrieved via APIs for further analysis and reporting.

GuardDuty offers a scalable and flexible approach to threat detection within AWS environments, providing organizations with an additional layer of security to proactively identify and respond to potential security risks.

## Usage

**Stack Level**: Regional

The example snippet below shows how to use this component:

```yaml
components:
  terraform:
    guardduty/common:
      metadata:
        component: guardduty/common
      vars:
        enabled: true
        account_map_tenant: core
        central_resource_collector_account: core-security
        admin_delegated: true
```

## Deployment

This set of steps assumes that `var.central_resource_collector_account = "core-security"`.

1. Apply `guardduty/common` to `core-security` with `var.admin_delegated = false`
2. Apply `guardduty/root` to `core-root`
3. Apply `guardduty/common` to `core-security` with `var.admin_delegated = true`

Example:

```
# Apply guardduty/common to all regions in core-security
atmos terraform apply guardduty/common-ue2 -s core-ue2-security -var=admin_delegated=false
atmos terraform apply guardduty/common-ue1 -s core-ue1-security -var=admin_delegated=false
atmos terraform apply guardduty/common-uw1 -s core-uw1-security -var=admin_delegated=false
# ... other regions

# Apply guardduty/root to all regions in core-root
atmos terraform apply guardduty/root-ue2 -s core-ue2-root
atmos terraform apply guardduty/root-ue1 -s core-ue1-root
atmos terraform apply guardduty/root-uw1 -s core-uw1-root
# ... other regions

# Apply guardduty/common to all regions in core-security but with default values for admin_delegated
atmos terraform apply guardduty/common-ue2 -s core-ue2-security
atmos terraform apply guardduty/common-ue1 -s core-ue1-security
atmos terraform apply guardduty/common-uw1 -s core-uw1-security
# ... other regions
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference



### Providers

| Provider | Version |
| --- | --- |
| `aws` | latest |
| `awsutils` | latest |


### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`account_map` | 1.4.2 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.4.2) | n/a
`guardduty` | 0.5.0 | [`cloudposse/guardduty/aws`](https://registry.terraform.io/modules/cloudposse/guardduty/aws/0.5.0) | n/a
`iam_roles` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a


### Resources

The following resources are used by this module:

  - [`awsutils_guardduty_organization_settings.this`](https://registry.terraform.io/providers/hashicorp/awsutils/latest/docs/resources/guardduty_organization_settings) (resource)(main.tf#30)

### Data Sources

The following data sources are used by this module:

  - [`aws_caller_identity.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)

### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>

</details>

### Required Inputs



### Outputs

<dl>
  <dt><code>guardduty_detector_arn</code></dt>
  <dd>
    GuardDuty detector ARN<br/>
  </dd>
  <dt><code>guardduty_detector_id</code></dt>
  <dd>
    GuardDuty detector ID<br/>
  </dd>
  <dt><code>sns_topic_name</code></dt>
  <dd>
    SNS topic name<br/>
  </dd>
  <dt><code>sns_topic_subscriptions</code></dt>
  <dd>
    SNS topic subscriptions<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References
* [AWS GuardDuty Documentation](https://aws.amazon.com/guardduty/)
* [Cloud Posse's upstream component](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/guardduty/common/)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
