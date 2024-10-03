# AWS Config Conformance Pack

This module deploys a
[Conformance Pack](https://docs.aws.amazon.com/config/latest/developerguide/conformance-packs.html). A conformance pack
is a collection of AWS Config rules and remediation actions that can be easily deployed as a single entity in an account
and a Region or across an organization in AWS Organizations. Conformance packs are created by authoring a YAML template
that contains the list of AWS Config managed or custom rules and remediation actions.

The Conformance Pack cannot be deployed until AWS Config is deployed, which can be deployed using the
[aws-config](../../) component.

## Usage

First, make sure your root `account` allows the service access principal `config-multiaccountsetup.amazonaws.com` to
update child organizations. You can see the docs on the account module here:
[aws_service_access_principals](https://docs.cloudposse.com/components/library/aws/account/#input_aws_service_access_principals)

Then you have two options:

- Set the `default_scope` of the parent `aws-config` component to be `organization` (can be overridden by the `scope` of
  each `conformance_packs` item)
- Set the `scope` of the `conformance_packs` item to be `organization`

An example YAML stack config for Atmos follows. Note, that both options are shown for demonstration purposes. In
practice you should only have one `aws-config` per account:

```yaml
components:
  terraform:
    account:
      vars:
        aws_service_access_principals:
          - config-multiaccountsetup.amazonaws.com

    aws-config/cis/level-1:
      vars:
        conformance_packs:
          - name: Operational-Best-Practices-for-CIS-AWS-v1.4-Level1
            conformance_pack: https://raw.githubusercontent.com/awslabs/aws-config-rules/master/aws-config-conformance-packs/Operational-Best-Practices-for-CIS-AWS-v1.4-Level1.yaml
            scope: organization

    aws-config/cis/level-2:
      vars:
        default_scope: organization
        conformance_packs:
          - name: Operational-Best-Practices-for-CIS-AWS-v1.4-Level2
            conformance_pack: https://raw.githubusercontent.com/awslabs/aws-config-rules/master/aws-config-conformance-packs/Operational-Best-Practices-for-CIS-AWS-v1.4-Level2.yaml
```
