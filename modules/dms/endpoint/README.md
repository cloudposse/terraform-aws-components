# Component: `dms/endpoint`

This component provisions DMS endpoints.

## Usage

**Stack Level**: Regional

Here are some example snippets for how to use this component:

```yaml
components:
  terraform:
    dms/endpoint/defaults:
      metadata:
        type: abstract
      settings:
        spacelift:
          workspace_enabled: true
          autodeploy: false
      vars:
        enabled: true
        tags:
          team: kin
          app_name: dms

    dms-endpoint-source-example:
      metadata:
        component: dms/endpoint
        inherits:
          - dms/endpoint/defaults
      vars:
        name: source-example
        endpoint_type: source
        engine_name: aurora-postgresql
        server_name: ""
        database_name: ""
        port: 5432
        extra_connection_attributes: ""
        secrets_manager_access_role_arn: ""
        secrets_manager_arn: ""
        ssl_mode: none
        attributes:
          - source

    dms-endpoint-target-example:
      metadata:
        component: dms/endpoint
        inherits:
          - dms/endpoint/defaults
      vars:
        name: target-example
        endpoint_type: target
        engine_name: s3
        extra_connection_attributes: ""
        s3_settings:
          bucket_name: ""
          bucket_folder: null
          cdc_inserts_only: false
          csv_row_delimiter: " "
          csv_delimiter: ","
          data_format: parquet
          compression_type: GZIP
          date_partition_delimiter: NONE
          date_partition_enabled: true
          date_partition_sequence: YYYYMMDD
          include_op_for_full_load: true
          parquet_timestamp_in_millisecond: true
          timestamp_column_name: timestamp
          service_access_role_arn: ""
        attributes:
          - target
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
  * [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/dms/modules/dms-endpoint) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
