# Component: `dms/replication-instance`

This component provisions DMS replication instances.

## Usage

**Stack Level**: Regional

Here are some example snippets for how to use this component:

```yaml
components:
  terraform:
    dms/replication-instance/defaults:
      metadata:
        type: abstract
      settings:
        spacelift:
          workspace_enabled: true
          autodeploy: false
      vars:
        enabled: true
        allocated_storage: 50
        apply_immediately: true
        auto_minor_version_upgrade: true
        allow_major_version_upgrade: false
        availability_zone: null
        engine_version: "3.4"
        multi_az: false
        preferred_maintenance_window: "sun:10:30-sun:14:30"
        publicly_accessible: false
        tags:
          team: kin
          app_name: dms

    dms-replication-instance-t2-small:
      metadata:
        component: dms/replication-instance
        inherits:
          - dms/replication-instance/defaults
      vars:
        # Replication instance name must start with a letter, only contain alphanumeric characters and hyphens
        name: "t2-small"
        replication_instance_class: "dms.t2.small"
        allocated_storage: 50
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
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/dms/modules/dms-replication-instance) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
