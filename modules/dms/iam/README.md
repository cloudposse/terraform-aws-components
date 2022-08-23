# Component: `dms/iam`

This component provisions IAM roles required for DMS.

## Usage

**Stack Level**: Regional

Here are some example snippets for how to use this component:

```yaml
components:
  terraform:
    dms/iam:
      metadata:
        component: dms/iam
      settings:
        spacelift:
          workspace_enabled: true
          autodeploy: false
      vars:
        enabled: true
        name: dms
        tags:
          team: kin
          app_name: dms
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

## Providers

## Modules

## Resources

## Inputs

## Outputs
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/dms/modules/dms-iam) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
