# Component: `redshift`

This component is responsible for provisioning a RedShift instance. It seeds relevant database information (hostnames, username, password, etc.) into AWS SSM Parameter Store.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    redshift:
      vars:
        enabled: true
        name: redshift
        database_name: redshift
        publicly_accessible: false
        node_type: dc2.large
        number_of_nodes: 1
        cluster_type: single-node
        ssm_enabled: true
        log_exports:
          - userlog
          - connectionlog
          - useractivitylog
        admin_user: redshift
        custom_sg_enabled: true
        custom_sg_rules:
          - type: ingress
            key: postgres
            description: Allow inbound traffic to the redshift cluster
            from_port: 5439
            to_port: 5439
            protocol: tcp
            cidr_blocks:
              - 10.0.0.0/8

```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/redshift) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
