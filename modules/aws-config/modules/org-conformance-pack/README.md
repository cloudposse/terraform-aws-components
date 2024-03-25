# AWS Config Conformance Pack

This module deploys a
[Conformance Pack](https://docs.aws.amazon.com/config/latest/developerguide/conformance-packs.html). A conformance pack
is a collection of AWS Config rules and remediation actions that can be easily deployed as a single entity in an account
and a Region or across an organization in AWS Organizations. Conformance packs are created by authoring a YAML template
that contains the list of AWS Config managed or custom rules and remediation actions.

The Conformance Pack cannot be deployed until AWS Config is deployed, which can be deployed using the
[root module](../../) of this repository.

## Usage

First, make sure your root `account` allows the service access principal `config-multiaccountsetup.amazonaws.com` to
update child organizations. You can see the docs on the account module here:
[aws_service_Access_principals](https://docs.cloudposse.com/components/library/aws/account/#input_aws_service_access_principals)

Then set the `scope` of the parent `aws-config` to be `organization`.

After that, any conformance packs you define in the `conformance_packs` variable will be deployed to all child accounts
of the organization.

An example yaml stack config for atmos is as follows:

```yaml
components:
  terraform:
    account:
      vars:
        aws_service_access_principals:
          - config-multiaccountsetup.amazonaws.com

    aws-config:
      vars:
        scope: organization
        conformance_packs:
          - name: Operational-Best-Practices-for-CIS-AWS-v1.4-Level1
            conformance_pack: https://raw.githubusercontent.com/awslabs/aws-config-rules/master/aws-config-conformance-packs/Operational-Best-Practices-for-CIS-AWS-v1.4-Level1.yaml
```
