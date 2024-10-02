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
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_awsutils"></a> [awsutils](#provider\_awsutils) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.2 |
| <a name="module_guardduty"></a> [guardduty](#module\_guardduty) | cloudposse/guardduty/aws | 0.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |

## Resources

| Name | Type |
|------|------|
| [awsutils_guardduty_organization_settings.this](https://registry.terraform.io/providers/hashicorp/awsutils/latest/docs/resources/guardduty_organization_settings) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_guardduty_detector_arn"></a> [guardduty\_detector\_arn](#output\_guardduty\_detector\_arn) | GuardDuty detector ARN |
| <a name="output_guardduty_detector_id"></a> [guardduty\_detector\_id](#output\_guardduty\_detector\_id) | GuardDuty detector ID |
| <a name="output_sns_topic_name"></a> [sns\_topic\_name](#output\_sns\_topic\_name) | SNS topic name |
| <a name="output_sns_topic_subscriptions"></a> [sns\_topic\_subscriptions](#output\_sns\_topic\_subscriptions) | SNS topic subscriptions |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References
* [AWS GuardDuty Documentation](https://aws.amazon.com/guardduty/)
* [Cloud Posse's upstream component](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/guardduty/common/)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
