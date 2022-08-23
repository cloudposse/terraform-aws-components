# Component: `dms/replication-task`

This component provisions DMS replication tasks.

## Usage

**Stack Level**: Regional

Here are some example snippets for how to use this component:

```yaml
components:
  terraform:
    dms/replication-task/defaults:
      metadata:
        type: abstract
      settings:
        spacelift:
          workspace_enabled: true
          autodeploy: false
      vars:
        enabled: true
        start_replication_task: true
        migration_type: full-load-and-cdc

    dms-replication-task-example:
      metadata:
        component: dms/replication-task
        inherits:
          - dms/replication-task/defaults
      vars:
        name: example
        replication_instance_component_name: dms-replication-instance-t2-small
        source_endpoint_component_name: dms-endpoint-source-example
        target_endpoint_component_name: dms-endpoint-target-example
        replication_task_settings_file: "config/replication-task-settings-example.json"
        table_mappings_file: "config/replication-task-table-mappings-example.json"
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
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/dms/modules/dms-replication-task) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
