# Component: `ecs-service`

This component is responsible for creating an ECS service.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
# stacks/catalog/ecs-service/defaults.yaml
components:
  terraform:
    ecs-service/defaults:
      metadata:
        component: ecs-service
        type: abstract
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        public_lb_enabled: false
        ecr_stage_name: mgmt-automation
        task:
          launch_type: FARGATE
          network_mode: awsvpc
          desired_count: 1
          ignore_changes_desired_count: true
          ignore_changes_task_definition: false
          assign_public_ip: false
          propagate_tags: SERVICE
          wait_for_steady_state: true
          circuit_breaker_deployment_enabled: true
          circuit_breaker_rollback_enabled: true
```

This will launch a `kong` service using an ecr image from `mgmt-automation` account.

NOTE: Usage of `ecr_image` instead of `image`.

```yaml
import:
  - catalog/ecs-service/defaults

components:
  terraform:
    ecs/b2b/kong/service:
      metadata:
        component: ecs-service
        inherits:
          - ecs-service/defaults
      vars:
        name: kong
        public_lb_enabled: true
        cluster_attributes: [b2b]
        containers:
          service:
            name: "kong-gateway"
            ecr_image: kong:latest
            map_environment:
              KONG_DECLARATIVE_CONFIG: /home/kong/production.yml
            port_mappings:
              - containerPort: 8000
                hostPort: 8000
                protocol: tcp
        task:
          desired_count: 1
          task_memory: 512
          task_cpu: 256
```

This will launch a `httpd` service using an external image from dockerhub

NOTE: Usage of `image` instead of `ecr_image`.

```yaml
# stacks/catalog/ecs-service/httpd.yaml
import:
  - catalog/ecs-service/defaults

components:
  terraform:
    ecs/platform/httpd/service:
      metadata:
        component: ecs-service
        inherits:
          - ecs-service/defaults
      vars:
        enabled: true
        name: httpd
        public_lb_enabled: true
        cluster_attributes: [platform]
        containers:
          service:
            name: "Hello"
            image: httpd:2.4
            port_mappings:
              - containerPort: 80
                hostPort: 80
                protocol: tcp
            command:
              - '/bin/sh -c "echo ''<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px;
                background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS
                Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon
                ECS.</p> </div></body></html>'' >  /usr/local/apache2/htdocs/index.html && httpd-foreground"'
            entrypoint: ["sh", "-c"]
        task:
          desired_count: 1
          task_memory: 512
          task_cpu: 256
```

This will launch google's `echoserver` using an external image from gcr

NOTE: Usage of `image` instead of `ecr_image`.

```yaml
# stacks/catalog/ecs-service/echoserver.yaml
import:
  - catalog/ecs-service/defaults

components:
  terraform:
    ecs/platform/echoserver/service:
      metadata:
        component: ecs-service
        inherits:
          - ecs-service/defaults
      vars:
        enabled: true
        name: echoserver
        public_lb_enabled: true
        cluster_attributes: [platform]
        containers:
          service:
            name: "echoserver"
            image: gcr.io/google_containers/echoserver:1.10
            port_mappings:
              - containerPort: 8080
                hostPort: 8080
                protocol: tcp
        task:
          desired_count: 1
          task_memory: 512
          task_cpu: 256
```

#### Other Domains

This component supports alternate service names for your ECS Service through a couple of variables:

- `vanity_domain` & `vanity_alias` - This will create a route to the service in the listener rules of the ALB. This will
  also create a Route 53 alias record in the hosted zone in this account. The hosted zone is looked up by the
  `vanity_domain` input.
- `additional_targets` - This will create a route to the service in the listener rules of the ALB. This will not create
  a Route 53 alias record.

Examples:

```yaml
ecs/platform/service/echo-server:
  vars:
    vanity_domain: "dev-acme.com"
    vanity_alias:
      - "echo-server.dev-acme.com"
    additional_targets:
      - "echo.acme.com"
```

This then creates the following listener rules:

```text
HTTP Host Header is
echo-server.public-platform.use2.dev.plat.service-discovery.com
 OR echo-server.dev-acme.com
 OR echo.acme.com
```

It will also create the record in Route53 to point `"echo-server.dev-acme.com"` to the ALB. Thus
`"echo-server.dev-acme.com"` should resolve.

We can then create a pointer to this service in the `acme.come` hosted zone.

```yaml
dns-primary:
  vars:
    domain_names:
      - acme.com
    record_config:
      - root_zone: acme.com
        name: echo.
        type: CNAME
        ttl: 60
        records:
          - echo-server.dev-acme.com
```

This will create a CNAME record in the `acme.com` hosted zone that points `echo.acme.com` to `echo-server.dev-acme.com`.

### EFS

EFS is supported by this ecs service, you can use either `efs_volumes` or `efs_component_volumes` in your task
definition.

This example shows how to use `efs_component_volumes` which remote looks up efs component and uses the `efs_id` to mount
the volume. And how to use `efs_volumes`

```yaml
components:
  terraform:
    ecs-services/my-service:
      metadata:
        component: ecs-service
        inherits:
          - ecs-services/defaults
      vars:
        containers:
          service:
            name: app
            image: my-image:latest
            log_configuration:
              logDriver: awslogs
              options: {}
            port_mappings:
              - containerPort: 8080
                hostPort: 8080
                protocol: tcp
            mount_points:
              - containerPath: "/var/lib/"
                sourceVolume: "my-volume-mount"

        task:
          efs_component_volumes:
            - name: "my-volume-mount"
              host_path: null
              efs_volume_configuration:
                - component: efs/my-volume-mount
                  root_directory: "/var/lib/"
                  transit_encryption: "ENABLED"
                  transit_encryption_port: 2999
                  authorization_config: []
          efs_volumes:
            - name: "my-volume-mount-2"
              host_path: null
              efs_volume_ configuration:
                - file_system_id: "fs-1234"
                  root_directory: "/var/lib/"
                  transit_encryption: "ENABLED"
                  transit_encryption_port: 2998
                  authorization_config: []
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.66.1 |
| `jq` | >=0.2.0 |
| `template` | >= 2.2 |


### Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.66.1 |
| `jq` | >=0.2.0 |
| `template` | >= 2.2 |


### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`alb` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`alb_ingress` | 0.28.0 | [`cloudposse/alb-ingress/aws`](https://registry.terraform.io/modules/cloudposse/alb-ingress/aws/0.28.0) | n/a
`cloudmap_namespace` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`cloudmap_namespace_service_discovery` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`container_definition` | 0.61.1 | [`cloudposse/ecs-container-definition/aws`](https://registry.terraform.io/modules/cloudposse/ecs-container-definition/aws/0.61.1) | n/a
`datadog_configuration` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`datadog_container_definition` | 0.58.1 | [`cloudposse/ecs-container-definition/aws`](https://registry.terraform.io/modules/cloudposse/ecs-container-definition/aws/0.58.1) | n/a
`datadog_fluent_bit_container_definition` | 0.58.1 | [`cloudposse/ecs-container-definition/aws`](https://registry.terraform.io/modules/cloudposse/ecs-container-definition/aws/0.58.1) | n/a
`datadog_sidecar_logs` | 0.6.6 | [`cloudposse/cloudwatch-logs/aws`](https://registry.terraform.io/modules/cloudposse/cloudwatch-logs/aws/0.6.6) | n/a
`ecs_alb_service_task` | 0.72.0 | [`cloudposse/ecs-alb-service-task/aws`](https://registry.terraform.io/modules/cloudposse/ecs-alb-service-task/aws/0.72.0) | n/a
`ecs_cloudwatch_autoscaling` | 0.7.3 | [`cloudposse/ecs-cloudwatch-autoscaling/aws`](https://registry.terraform.io/modules/cloudposse/ecs-cloudwatch-autoscaling/aws/0.7.3) | n/a
`ecs_cloudwatch_sns_alarms` | 0.12.3 | [`cloudposse/ecs-cloudwatch-sns-alarms/aws`](https://registry.terraform.io/modules/cloudposse/ecs-cloudwatch-sns-alarms/aws/0.12.3) | n/a
`ecs_cluster` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`efs` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`gha_assume_role` | latest | [`../account-map/modules/team-assume-role-policy`](https://registry.terraform.io/modules/../account-map/modules/team-assume-role-policy/) | n/a
`gha_role_name` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`iam_role` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`logs` | 0.6.8 | [`cloudposse/cloudwatch-logs/aws`](https://registry.terraform.io/modules/cloudposse/cloudwatch-logs/aws/0.6.8) | n/a
`nlb` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`rds` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`roles_to_principals` | latest | [`../account-map/modules/roles-to-principals`](https://registry.terraform.io/modules/../account-map/modules/roles-to-principals/) | n/a
`s3` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`security_group` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`service_domain` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vanity_alias` | 0.13.0 | [`cloudposse/route53-alias/aws`](https://registry.terraform.io/modules/cloudposse/route53-alias/aws/0.13.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_iam_policy.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)(main.tf#422)
  - [`aws_iam_role.github_actions`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)(github-actions-iam-role.mixin.tf#53)
  - [`aws_kinesis_stream.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_stream) (resource)(main.tf#543)
  - [`aws_s3_bucket_object.task_definition_template`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object) (resource)(main.tf#588)
  - [`aws_security_group_rule.custom_sg_rules`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)(main.tf#329)
  - [`aws_service_discovery_service.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) (resource)(cloud-map.tf#46)
  - [`aws_ssm_parameter.full_urls`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)(systems-manager.tf#48)

### Data Sources

The following data sources are used by this module:

  - [`aws_caller_identity.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
  - [`aws_ecs_task_definition.created_task`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) (data source)
  - [`aws_iam_policy_document.github_actions_iam_ecspresso_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.github_actions_iam_platform_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.github_actions_iam_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_kms_alias.selected`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) (data source)
  - [`aws_route53_zone.selected`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) (data source)
  - [`aws_route53_zone.selected_vanity`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) (data source)
  - [`aws_s3_object.task_definition`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_object) (data source)
  - [`aws_s3_objects.mirror`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_objects) (data source)
  - [`aws_ssm_parameters_by_path.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameters_by_path) (data source)
  - [`jq_query.service_domain_query`](https://registry.terraform.io/providers/massdriver-cloud/jq/latest/docs/data-sources/query) (data source)
  - [`template_file.envs`](https://registry.terraform.io/providers/cloudposse/template/latest/docs/data-sources/file) (data source)
---
### Required Variables
### `region` (`string`) <i>required</i>


AWS Region<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>



---
### Optional Variables
### `additional_targets` (`list(string)`) <i>optional</i>


Additional target routes to add to the ALB that point to this service. The only difference between this and `var.vanity_alias` is `var.vanity_alias` will create an alias record in Route 53 in the hosted zone in this account as well. `var.additional_targets` only adds the listener route to this service's target group.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `alb_configuration` (`string`) <i>optional</i>


The configuration to use for the ALB, specifying which cluster alb configuration to use<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"default"</code>
>   </dd>
> </dl>
>


### `alb_name` (`string`) <i>optional</i>


The name of the ALB this service should attach to<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `autoscaling_dimension` (`string`) <i>optional</i>


The dimension to use to decide to autoscale<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"cpu"</code>
>   </dd>
> </dl>
>


### `autoscaling_enabled` (`bool`) <i>optional</i>


Should this service autoscale using SNS alarams<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `chamber_service` (`string`) <i>optional</i>


SSM parameter service name for use with chamber. This is used in chamber_format where /$chamber_service/$name/$container_name/$parameter would be the default.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"ecs-service"</code>
>   </dd>
> </dl>
>


### `cluster_attributes` (`list(string)`) <i>optional</i>


The attributes of the cluster name e.g. if the full name is `namespace-tenant-environment-dev-ecs-b2b` then the `cluster_name` is `ecs` and this value should be `b2b`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `containers` <i>optional</i>


Feed inputs into container definition module<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   map(object({
    name                     = string
    ecr_image                = optional(string)
    image                    = optional(string)
    memory                   = optional(number)
    memory_reservation       = optional(number)
    cpu                      = optional(number)
    essential                = optional(bool, true)
    readonly_root_filesystem = optional(bool, null)
    privileged               = optional(bool, null)
    container_depends_on = optional(list(object({
      containerName = string
      condition     = string # START, COMPLETE, SUCCESS, HEALTHY
    })), null)

    port_mappings = optional(list(object({
      containerPort = number
      hostPort      = optional(number)
      protocol      = optional(string)
      name          = optional(string)
      appProtocol   = optional(string)
    })), [])
    command    = optional(list(string), null)
    entrypoint = optional(list(string), null)
    healthcheck = optional(object({
      command     = list(string)
      interval    = number
      retries     = number
      startPeriod = number
      timeout     = number
    }), null)
    ulimits = optional(list(object({
      name      = string
      softLimit = number
      hardLimit = number
    })), null)
    log_configuration = optional(object({
      logDriver = string
      options   = optional(map(string), {})
    }))
    docker_labels   = optional(map(string), null)
    map_environment = optional(map(string), {})
    map_secrets     = optional(map(string), {})
    volumes_from = optional(list(object({
      sourceContainer = string
      readOnly        = bool
    })), null)
    mount_points = optional(list(object({
      sourceVolume  = optional(string)
      containerPath = optional(string)
      readOnly      = optional(bool)
    })), [])
  }))
>   ```
>
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `cpu_utilization_high_alarm_actions` (`list(string)`) <i>optional</i>


A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High Alarm action<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `cpu_utilization_high_evaluation_periods` (`number`) <i>optional</i>


Number of periods to evaluate for the alarm<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>1</code>
>   </dd>
> </dl>
>


### `cpu_utilization_high_ok_actions` (`list(string)`) <i>optional</i>


A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High OK action<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `cpu_utilization_high_period` (`number`) <i>optional</i>


Duration in seconds to evaluate for the alarm<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>300</code>
>   </dd>
> </dl>
>


### `cpu_utilization_high_threshold` (`number`) <i>optional</i>


The maximum percentage of CPU utilization average<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>80</code>
>   </dd>
> </dl>
>


### `cpu_utilization_low_alarm_actions` (`list(string)`) <i>optional</i>


A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low Alarm action<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `cpu_utilization_low_evaluation_periods` (`number`) <i>optional</i>


Number of periods to evaluate for the alarm<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>1</code>
>   </dd>
> </dl>
>


### `cpu_utilization_low_ok_actions` (`list(string)`) <i>optional</i>


A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low OK action<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `cpu_utilization_low_period` (`number`) <i>optional</i>


Duration in seconds to evaluate for the alarm<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>300</code>
>   </dd>
> </dl>
>


### `cpu_utilization_low_threshold` (`number`) <i>optional</i>


The minimum percentage of CPU utilization average<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>20</code>
>   </dd>
> </dl>
>


### `custom_security_group_rules` <i>optional</i>


The list of custom security group rules to add to the service security group<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string)
  }))
>   ```
>
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `datadog_agent_sidecar_enabled` (`bool`) <i>optional</i>


Enable the Datadog Agent Sidecar<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `datadog_log_method_is_firelens` (`bool`) <i>optional</i>


Datadog logs can be sent via cloudwatch logs (and lambda) or firelens, set this to true to enable firelens via a sidecar container for fluentbit<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `datadog_logging_default_tags_enabled` (`bool`) <i>optional</i>


Add Default tags to all logs sent to Datadog<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `datadog_logging_tags` (`map(string)`) <i>optional</i>


Tags to add to all logs sent to Datadog<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `datadog_sidecar_containers_logs_enabled` (`bool`) <i>optional</i>


Enable the Datadog Agent Sidecar to send logs to aws cloudwatch group, requires `datadog_agent_sidecar_enabled` to be true<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `ecr_region` (`string`) <i>optional</i>


The region to use for the fully qualified ECR image URL. Defaults to the current region.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `ecr_stage_name` (`string`) <i>optional</i>


The ecr stage (account) name to use for the fully qualified ECR image URL.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"auto"</code>
>   </dd>
> </dl>
>


### `ecs_cluster_name` (`any`) <i>optional</i>


The name of the ECS Cluster this belongs to<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"ecs"</code>
>   </dd>
> </dl>
>


### `exec_enabled` (`bool`) <i>optional</i>


Specifies whether to enable Amazon ECS Exec for the tasks within the service<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `github_actions_allowed_repos` (`list(string)`) <i>optional</i>


  A list of the GitHub repositories that are allowed to assume this role from GitHub Actions. For example,<br/>
  ["cloudposse/infra-live"]. Can contain "*" as wildcard.<br/>
  If org part of repo name is omitted, "cloudposse" will be assumed.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `github_actions_ecspresso_enabled` (`bool`) <i>optional</i>


Create IAM policies required for deployments with Ecspresso<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `github_actions_iam_role_attributes` (`list(string)`) <i>optional</i>


Additional attributes to add to the role name<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `github_actions_iam_role_enabled` (`bool`) <i>optional</i>


Flag to toggle creation of an IAM Role that GitHub Actions can assume to access AWS resources<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `github_oidc_trusted_role_arns` (`list(string)`) <i>optional</i>


A list of IAM Role ARNs allowed to assume this cluster's GitHub OIDC role<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `health_check_healthy_threshold` (`number`) <i>optional</i>


The number of consecutive health checks successes required before healthy<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>2</code>
>   </dd>
> </dl>
>


### `health_check_interval` (`number`) <i>optional</i>


The duration in seconds in between health checks<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>15</code>
>   </dd>
> </dl>
>


### `health_check_matcher` (`string`) <i>optional</i>


The HTTP response codes to indicate a healthy check<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"200-404"</code>
>   </dd>
> </dl>
>


### `health_check_path` (`string`) <i>optional</i>


The destination for the health check request<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"/health"</code>
>   </dd>
> </dl>
>


### `health_check_port` (`string`) <i>optional</i>


The port to use to connect with the target. Valid values are either ports 1-65536, or `traffic-port`. Defaults to `traffic-port`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"traffic-port"</code>
>   </dd>
> </dl>
>


### `health_check_timeout` (`number`) <i>optional</i>


The amount of time to wait in seconds before failing a health check request<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>10</code>
>   </dd>
> </dl>
>


### `health_check_unhealthy_threshold` (`number`) <i>optional</i>


The number of consecutive health check failures required before unhealthy<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>2</code>
>   </dd>
> </dl>
>


### `http_protocol` (`string`) <i>optional</i>


Which http protocol to use in outputs and SSM url params. This value is ignored if a load balancer is not used. If it is `null`, the redirect value from the ALB determines the protocol.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `iam_policy_enabled` (`bool`) <i>optional</i>


If set to true will create IAM policy in AWS<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `iam_policy_statements` (`any`) <i>optional</i>


Map of IAM policy statements to use in the policy. This can be used with or instead of the `var.iam_source_json_url`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `kinesis_enabled` (`bool`) <i>optional</i>


Enable Kinesis<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `kms_alias_name_ssm` (`string`) <i>optional</i>


KMS alias name for SSM<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"alias/aws/ssm"</code>
>   </dd>
> </dl>
>


### `kms_key_alias` (`string`) <i>optional</i>


ID of KMS key<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"default"</code>
>   </dd>
> </dl>
>


### `lb_catch_all` (`bool`) <i>optional</i>


Should this service act as catch all for all subdomain hosts of the vanity domain<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `logs` (`any`) <i>optional</i>


Feed inputs into cloudwatch logs module<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `memory_utilization_high_alarm_actions` (`list(string)`) <i>optional</i>


A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High Alarm action<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `memory_utilization_high_evaluation_periods` (`number`) <i>optional</i>


Number of periods to evaluate for the alarm<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>1</code>
>   </dd>
> </dl>
>


### `memory_utilization_high_ok_actions` (`list(string)`) <i>optional</i>


A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High OK action<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `memory_utilization_high_period` (`number`) <i>optional</i>


Duration in seconds to evaluate for the alarm<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>300</code>
>   </dd>
> </dl>
>


### `memory_utilization_high_threshold` (`number`) <i>optional</i>


The maximum percentage of Memory utilization average<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>80</code>
>   </dd>
> </dl>
>


### `memory_utilization_low_alarm_actions` (`list(string)`) <i>optional</i>


A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low Alarm action<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `memory_utilization_low_evaluation_periods` (`number`) <i>optional</i>


Number of periods to evaluate for the alarm<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>1</code>
>   </dd>
> </dl>
>


### `memory_utilization_low_ok_actions` (`list(string)`) <i>optional</i>


A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low OK action<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `memory_utilization_low_period` (`number`) <i>optional</i>


Duration in seconds to evaluate for the alarm<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>300</code>
>   </dd>
> </dl>
>


### `memory_utilization_low_threshold` (`number`) <i>optional</i>


The minimum percentage of Memory utilization average<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>20</code>
>   </dd>
> </dl>
>


### `nlb_name` (`string`) <i>optional</i>


The name of the NLB this service should attach to<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `rds_name` (`any`) <i>optional</i>


The name of the RDS database this service should allow access to<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `retention_period` (`number`) <i>optional</i>


Length of time data records are accessible after they are added to the stream<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>48</code>
>   </dd>
> </dl>
>


### `s3_mirror_name` (`string`) <i>optional</i>


The name of the S3 mirror component<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `service_connect_configurations` <i>optional</i>


The list of Service Connect configurations.<br/>
See `service_connect_configuration` docs https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#service_connect_configuration<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
    enabled   = bool
    namespace = optional(string, null)
    log_configuration = optional(object({
      log_driver = string
      options    = optional(map(string), null)
      secret_option = optional(list(object({
        name       = string
        value_from = string
      })), [])
    }), null)
    service = optional(list(object({
      client_alias = list(object({
        dns_name = string
        port     = number
      }))
      discovery_name        = optional(string, null)
      ingress_port_override = optional(number, null)
      port_name             = string
    })), [])
  }))
>   ```
>
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `service_registries` <i>optional</i>


The list of Service Registries.<br/>
See `service_registries` docs https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#service_registries<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
    namespace      = string
    registry_arn   = optional(string)
    port           = optional(number)
    container_name = optional(string)
    container_port = optional(number)
  }))
>   ```
>
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `shard_count` (`number`) <i>optional</i>


Number of shards that the stream will use<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>1</code>
>   </dd>
> </dl>
>


### `shard_level_metrics` (`list(string)`) <i>optional</i>


List of shard-level CloudWatch metrics which can be enabled for the stream<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
>    [
>
>      "IncomingBytes",
>
>      "IncomingRecords",
>
>      "IteratorAgeMilliseconds",
>
>      "OutgoingBytes",
>
>      "OutgoingRecords",
>
>      "ReadProvisionedThroughputExceeded",
>
>      "WriteProvisionedThroughputExceeded"
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `ssm_enabled` (`bool`) <i>optional</i>


If `true` create SSM keys for the database user and password.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `ssm_key_format` (`string`) <i>optional</i>


SSM path format. The values will will be used in the following order: `var.ssm_key_prefix`, `var.name`, `var.ssm_key_*`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"/%v/%v/%v"</code>
>   </dd>
> </dl>
>


### `ssm_key_prefix` (`string`) <i>optional</i>


SSM path prefix. Omit the leading forward slash `/`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"ecs-service"</code>
>   </dd>
> </dl>
>


### `stickiness_cookie_duration` (`number`) <i>optional</i>


The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. The range is 1 second to 1 week (604800 seconds). The default value is 1 day (86400 seconds)<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>86400</code>
>   </dd>
> </dl>
>


### `stickiness_enabled` (`bool`) <i>optional</i>


Boolean to enable / disable `stickiness`. Default is `true`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `stickiness_type` (`string`) <i>optional</i>


The type of sticky sessions. The only current possible value is `lb_cookie`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"lb_cookie"</code>
>   </dd>
> </dl>
>


### `stream_mode` (`string`) <i>optional</i>


Stream mode details for the Kinesis stream<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"PROVISIONED"</code>
>   </dd>
> </dl>
>


### `task` <i>optional</i>


Feed inputs into ecs_alb_service_task module<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   object({
    task_cpu                = optional(number)
    task_memory             = optional(number)
    task_role_arn           = optional(string, "")
    pid_mode                = optional(string, null)
    ipc_mode                = optional(string, null)
    network_mode            = optional(string)
    propagate_tags          = optional(string)
    assign_public_ip        = optional(bool, false)
    use_alb_security_groups = optional(bool, true)
    launch_type             = optional(string, "FARGATE")
    scheduling_strategy     = optional(string, "REPLICA")
    capacity_provider_strategies = optional(list(object({
      capacity_provider = string
      weight            = number
      base              = number
    })), [])

    deployment_minimum_healthy_percent = optional(number, null)
    deployment_maximum_percent         = optional(number, null)
    desired_count                      = optional(number, 0)
    min_capacity                       = optional(number, 1)
    max_capacity                       = optional(number, 2)
    wait_for_steady_state              = optional(bool, true)
    circuit_breaker_deployment_enabled = optional(bool, true)
    circuit_breaker_rollback_enabled   = optional(bool, true)

    ecs_service_enabled = optional(bool, true)
    bind_mount_volumes = optional(list(object({
      name      = string
      host_path = string
    })), [])
    efs_volumes = optional(list(object({
      host_path = string
      name      = string
      efs_volume_configuration = list(object({
        file_system_id          = string
        root_directory          = string
        transit_encryption      = string
        transit_encryption_port = string
        authorization_config = list(object({
          access_point_id = string
          iam             = string
        }))
      }))
    })), [])
    efs_component_volumes = optional(list(object({
      host_path = string
      name      = string
      efs_volume_configuration = list(object({
        component   = optional(string, "efs")
        tenant      = optional(string, null)
        environment = optional(string, null)
        stage       = optional(string, null)

        root_directory          = string
        transit_encryption      = string
        transit_encryption_port = string
        authorization_config = list(object({
          access_point_id = string
          iam             = string
        }))
      }))
    })), [])
    docker_volumes = optional(list(object({
      host_path = string
      name      = string
      docker_volume_configuration = list(object({
        autoprovision = bool
        driver        = string
        driver_opts   = map(string)
        labels        = map(string)
        scope         = string
      }))
    })), [])
    fsx_volumes = optional(list(object({
      host_path = string
      name      = string
      fsx_windows_file_server_volume_configuration = list(object({
        file_system_id = string
        root_directory = string
        authorization_config = list(object({
          credentials_parameter = string
          domain                = string
        }))
      }))
    })), [])
  })
>   ```
>
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `task_enabled` (`bool`) <i>optional</i>


Whether or not to use the ECS task module<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `task_exec_policy_arns_map` (`map(string)`) <i>optional</i>


A map of name to IAM Policy ARNs to attach to the generated task execution role.<br/>
The names are arbitrary, but must be known at plan time. The purpose of the name<br/>
is so that changes to one ARN do not cause a ripple effect on the other ARNs.<br/>
If you cannot provide unique names known at plan time, use `task_exec_policy_arns` instead.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `task_iam_role_component` (`string`) <i>optional</i>


A component that outputs an iam_role module as 'role' for adding to the service as a whole.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `task_policy_arns` (`list(string)`) <i>optional</i>


The IAM policy ARNs to attach to the ECS task IAM role<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
>    [
>
>      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
>
>      "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `task_security_group_component` (`string`) <i>optional</i>


A component that outputs security_group_id for adding to the service as a whole.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `unauthenticated_paths` (`list(string)`) <i>optional</i>


Unauthenticated path pattern to match<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `unauthenticated_priority` (`string`) <i>optional</i>


The priority for the rules without authentication, between 1 and 50000 (1 being highest priority). Must be different from `authenticated_priority` since a listener can't have multiple rules with the same priority	<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>0</code>
>   </dd>
> </dl>
>


### `use_lb` (`bool`) <i>optional</i>


Whether use load balancer for the service<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `use_rds_client_sg` (`bool`) <i>optional</i>


Use the RDS client security group<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `vanity_alias` (`list(string)`) <i>optional</i>


The vanity aliases to use for the public LB.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `vanity_domain` (`string`) <i>optional</i>


Whether to use the vanity domain alias for the service<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `zone_component` (`string`) <i>optional</i>


The component name to look up service domain remote-state on<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"dns-delegated"</code>
>   </dd>
> </dl>
>


### `zone_component_output` (`string`) <i>optional</i>


A json query to use to get the zone domain from the remote state. See <br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>".default_domain_name"</code>
>   </dd>
> </dl>
>



---
### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>
### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `attributes` (`list(string)`) <i>optional</i>


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `context` (`any`) <i>optional</i>


Single object for setting entire context at once.<br/>
See description of individual variables for details.<br/>
Leave string and numeric variables as `null` to use default value.<br/>
Individual variable settings (non-null) override settings in context object,<br/>
except for attributes, tags, and additional_tag_map, which are merged.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
>    {
>
>      "additional_tag_map": {},
>
>      "attributes": [],
>
>      "delimiter": null,
>
>      "descriptor_formats": {},
>
>      "enabled": true,
>
>      "environment": null,
>
>      "id_length_limit": null,
>
>      "label_key_case": null,
>
>      "label_order": [],
>
>      "label_value_case": null,
>
>      "labels_as_tags": [
>
>        "unset"
>
>      ],
>
>      "name": null,
>
>      "namespace": null,
>
>      "regex_replace_chars": null,
>
>      "stage": null,
>
>      "tags": {},
>
>      "tenant": null
>
>    }
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `descriptor_formats` (`any`) <i>optional</i>


Describe additional descriptors to be output in the `descriptors` output map.<br/>
Map of maps. Keys are names of descriptors. Values are maps of the form<br/>
`{<br/>
   format = string<br/>
   labels = list(string)<br/>
}`<br/>
(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>
`format` is a Terraform format string to be passed to the `format()` function.<br/>
`labels` is a list of labels, in order, to pass to `format()` function.<br/>
Label values will be normalized before being passed to `format()` so they will be<br/>
identical to how they appear in `id`.<br/>
Default is `{}` (`descriptors` output will be empty).<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `enabled` (`bool`) <i>optional</i>


Set to false to prevent the module from creating any resources<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `environment` (`string`) <i>optional</i>


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
Does not affect `id_full`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `label_key_case` (`string`) <i>optional</i>


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper`.<br/>
Default value: `title`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `label_order` (`list(string)`) <i>optional</i>


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `label_value_case` (`string`) <i>optional</i>


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
Default value: `lower`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `labels_as_tags` (`set(string)`) <i>optional</i>


Set of labels (ID elements) to include as tags in the `tags` output.<br/>
Default is to include all labels.<br/>
Tags with empty values will not be included in the `tags` output.<br/>
Set to `[]` to suppress all generated tags.<br/>
**Notes:**<br/>
  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
  changed in later chained modules. Attempts to change it will be silently ignored.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>set(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
>    [
>
>      "default"
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `regex_replace_chars` (`string`) <i>optional</i>


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `stage` (`string`) <i>optional</i>


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>



</details>

### Outputs

<dl>
  <dt><code>ecs_cluster_arn</code></dt>
  <dd>
    Selected ECS cluster ARN<br/>

  </dd>
  <dt><code>environment_map</code></dt>
  <dd>
    Environment variables to pass to the container, this is a map of key/value pairs, where the key is `containerName,variableName`<br/>

  </dd>
  <dt><code>full_domain</code></dt>
  <dd>
    Domain to respond to GET requests<br/>

  </dd>
  <dt><code>github_actions_iam_role_arn</code></dt>
  <dd>
    ARN of IAM role for GitHub Actions<br/>

  </dd>
  <dt><code>github_actions_iam_role_name</code></dt>
  <dd>
    Name of IAM role for GitHub Actions<br/>

  </dd>
  <dt><code>lb_arn</code></dt>
  <dd>
    Selected LB ARN<br/>

  </dd>
  <dt><code>lb_listener_https</code></dt>
  <dd>
    Selected LB HTTPS Listener<br/>

  </dd>
  <dt><code>lb_sg_id</code></dt>
  <dd>
    Selected LB SG ID<br/>

  </dd>
  <dt><code>logs</code></dt>
  <dd>
    Output of cloudwatch logs module<br/>

  </dd>
  <dt><code>service_image</code></dt>
  <dd>
    The image of the service container<br/>

  </dd>
  <dt><code>ssm_key_prefix</code></dt>
  <dd>
    SSM prefix<br/>

  </dd>
  <dt><code>ssm_parameters</code></dt>
  <dd>
    SSM parameters for the ECS Service<br/>

  </dd>
  <dt><code>subnet_ids</code></dt>
  <dd>
    Selected subnet IDs<br/>

  </dd>
  <dt><code>task_definition_arn</code></dt>
  <dd>
    The task definition ARN<br/>

  </dd>
  <dt><code>task_definition_revision</code></dt>
  <dd>
    The task definition revision<br/>

  </dd>
  <dt><code>task_template</code></dt>
  <dd>
    The task template rendered<br/>

  </dd>
  <dt><code>vpc_id</code></dt>
  <dd>
    Selected VPC ID<br/>

  </dd>
  <dt><code>vpc_sg_id</code></dt>
  <dd>
    Selected VPC SG ID<br/>

  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/ecs-service) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
