# Component: `ses`

This component is responsible for provisioning the AWS Simple Email Service (SES). It includes setting up the various DNS records required for verification, which depends on the [dns-delegated component](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/dns-delegated). All data for SES usage (Access Key ID, Secret Access Key, Username, and Password) is pushed into AWS SSM Parameter Store for downstream use.

## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    ses:
      vars:
        ses_verify_domain: true
        ses_verify_dkim: true
```

