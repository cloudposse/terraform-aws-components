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
              - '/bin/sh -c "echo ''<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>'' >  /usr/local/apache2/htdocs/index.html && httpd-foreground"'
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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_template"></a> [template](#provider\_template) | >= 2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb_ecs_label"></a> [alb\_ecs\_label](#module\_alb\_ecs\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_alb_ingress"></a> [alb\_ingress](#module\_alb\_ingress) | cloudposse/alb-ingress/aws | 0.24.3 |
| <a name="module_container_definition"></a> [container\_definition](#module\_container\_definition) | cloudposse/ecs-container-definition/aws | 0.58.1 |
| <a name="module_datadog_configuration"></a> [datadog\_configuration](#module\_datadog\_configuration) | ../datadog-configuration/modules/datadog_keys | n/a |
| <a name="module_datadog_container_definition"></a> [datadog\_container\_definition](#module\_datadog\_container\_definition) | cloudposse/ecs-container-definition/aws | 0.58.1 |
| <a name="module_datadog_fluent_bit_container_definition"></a> [datadog\_fluent\_bit\_container\_definition](#module\_datadog\_fluent\_bit\_container\_definition) | cloudposse/ecs-container-definition/aws | 0.58.1 |
| <a name="module_datadog_sidecar_logs"></a> [datadog\_sidecar\_logs](#module\_datadog\_sidecar\_logs) | cloudposse/cloudwatch-logs/aws | 0.6.6 |
| <a name="module_ecs_alb_service_task"></a> [ecs\_alb\_service\_task](#module\_ecs\_alb\_service\_task) | cloudposse/ecs-alb-service-task/aws | 0.66.4 |
| <a name="module_ecs_cloudwatch_autoscaling"></a> [ecs\_cloudwatch\_autoscaling](#module\_ecs\_cloudwatch\_autoscaling) | cloudposse/ecs-cloudwatch-autoscaling/aws | 0.7.3 |
| <a name="module_ecs_cloudwatch_sns_alarms"></a> [ecs\_cloudwatch\_sns\_alarms](#module\_ecs\_cloudwatch\_sns\_alarms) | cloudposse/ecs-cloudwatch-sns-alarms/aws | 0.12.3 |
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_gha_assume_role"></a> [gha\_assume\_role](#module\_gha\_assume\_role) | ../account-map/modules/team-assume-role-policy | n/a |
| <a name="module_gha_role_name"></a> [gha\_role\_name](#module\_gha\_role\_name) | cloudposse/label/null | 0.25.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_logs"></a> [logs](#module\_logs) | cloudposse/cloudwatch-logs/aws | 0.6.6 |
| <a name="module_rds"></a> [rds](#module\_rds) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_roles_to_principals"></a> [roles\_to\_principals](#module\_roles\_to\_principals) | ../account-map/modules/roles-to-principals | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vanity_alias"></a> [vanity\_alias](#module\_vanity\_alias) | cloudposse/route53-alias/aws | 0.13.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kinesis_stream.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_stream) | resource |
| [aws_iam_policy_document.github_actions_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_alias.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_route53_zone.selected_vanity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_ssm_parameters_by_path.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameters_by_path) | data source |
| [template_file.envs](https://registry.terraform.io/providers/cloudposse/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_alb_configuration"></a> [alb\_configuration](#input\_alb\_configuration) | The configuration to use for the ALB, specifying which cluster alb configuration to use | `string` | `"default"` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_autoscaling_dimension"></a> [autoscaling\_dimension](#input\_autoscaling\_dimension) | The dimension to use to decide to autoscale | `string` | `"cpu"` | no |
| <a name="input_autoscaling_enabled"></a> [autoscaling\_enabled](#input\_autoscaling\_enabled) | Should this service autoscale using SNS alarams | `bool` | `true` | no |
| <a name="input_chamber_service"></a> [chamber\_service](#input\_chamber\_service) | SSM parameter service name for use with chamber. This is used in chamber\_format where /$chamber\_service/$name/$container\_name/$parameter would be the default. | `string` | `"ecs-service"` | no |
| <a name="input_cluster_attributes"></a> [cluster\_attributes](#input\_cluster\_attributes) | The attributes of the cluster name e.g. if the full name is `namespace-tenant-environment-dev-ecs-b2b` then the `cluster_name` is `ecs` and this value should be `b2b`. | `list(string)` | `[]` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | Feed inputs into container definition module | `any` | `{}` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_cpu_utilization_high_alarm_actions"></a> [cpu\_utilization\_high\_alarm\_actions](#input\_cpu\_utilization\_high\_alarm\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High Alarm action | `list(string)` | `[]` | no |
| <a name="input_cpu_utilization_high_evaluation_periods"></a> [cpu\_utilization\_high\_evaluation\_periods](#input\_cpu\_utilization\_high\_evaluation\_periods) | Number of periods to evaluate for the alarm | `number` | `1` | no |
| <a name="input_cpu_utilization_high_ok_actions"></a> [cpu\_utilization\_high\_ok\_actions](#input\_cpu\_utilization\_high\_ok\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High OK action | `list(string)` | `[]` | no |
| <a name="input_cpu_utilization_high_period"></a> [cpu\_utilization\_high\_period](#input\_cpu\_utilization\_high\_period) | Duration in seconds to evaluate for the alarm | `number` | `300` | no |
| <a name="input_cpu_utilization_high_threshold"></a> [cpu\_utilization\_high\_threshold](#input\_cpu\_utilization\_high\_threshold) | The maximum percentage of CPU utilization average | `number` | `80` | no |
| <a name="input_cpu_utilization_low_alarm_actions"></a> [cpu\_utilization\_low\_alarm\_actions](#input\_cpu\_utilization\_low\_alarm\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low Alarm action | `list(string)` | `[]` | no |
| <a name="input_cpu_utilization_low_evaluation_periods"></a> [cpu\_utilization\_low\_evaluation\_periods](#input\_cpu\_utilization\_low\_evaluation\_periods) | Number of periods to evaluate for the alarm | `number` | `1` | no |
| <a name="input_cpu_utilization_low_ok_actions"></a> [cpu\_utilization\_low\_ok\_actions](#input\_cpu\_utilization\_low\_ok\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low OK action | `list(string)` | `[]` | no |
| <a name="input_cpu_utilization_low_period"></a> [cpu\_utilization\_low\_period](#input\_cpu\_utilization\_low\_period) | Duration in seconds to evaluate for the alarm | `number` | `300` | no |
| <a name="input_cpu_utilization_low_threshold"></a> [cpu\_utilization\_low\_threshold](#input\_cpu\_utilization\_low\_threshold) | The minimum percentage of CPU utilization average | `number` | `20` | no |
| <a name="input_datadog_agent_sidecar_enabled"></a> [datadog\_agent\_sidecar\_enabled](#input\_datadog\_agent\_sidecar\_enabled) | Enable the Datadog Agent Sidecar | `bool` | `false` | no |
| <a name="input_datadog_log_method_is_firelens"></a> [datadog\_log\_method\_is\_firelens](#input\_datadog\_log\_method\_is\_firelens) | Datadog logs can be sent via cloudwatch logs (and lambda) or firelens, set this to true to enable firelens via a sidecar container for fluentbit | `bool` | `false` | no |
| <a name="input_datadog_logging_default_tags_enabled"></a> [datadog\_logging\_default\_tags\_enabled](#input\_datadog\_logging\_default\_tags\_enabled) | Add Default tags to all logs sent to Datadog | `bool` | `true` | no |
| <a name="input_datadog_logging_tags"></a> [datadog\_logging\_tags](#input\_datadog\_logging\_tags) | Tags to add to all logs sent to Datadog | `map(string)` | `null` | no |
| <a name="input_datadog_sidecar_containers_logs_enabled"></a> [datadog\_sidecar\_containers\_logs\_enabled](#input\_datadog\_sidecar\_containers\_logs\_enabled) | Enable the Datadog Agent Sidecar to send logs to aws cloudwatch group, requires `datadog_agent_sidecar_enabled` to be true | `bool` | `true` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name to use as the host header suffix | `string` | `""` | no |
| <a name="input_ecr_region"></a> [ecr\_region](#input\_ecr\_region) | The region to use for the fully qualified ECR image URL. Defaults to the current region. | `string` | `""` | no |
| <a name="input_ecr_stage_name"></a> [ecr\_stage\_name](#input\_ecr\_stage\_name) | The ecr stage (account) name to use for the fully qualified ECR image URL. | `string` | `"auto"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_github_actions_allowed_repos"></a> [github\_actions\_allowed\_repos](#input\_github\_actions\_allowed\_repos) | A list of the GitHub repositories that are allowed to assume this role from GitHub Actions. For example,<br>  ["cloudposse/infra-live"]. Can contain "*" as wildcard.<br>  If org part of repo name is omitted, "cloudposse" will be assumed. | `list(string)` | `[]` | no |
| <a name="input_github_actions_iam_role_attributes"></a> [github\_actions\_iam\_role\_attributes](#input\_github\_actions\_iam\_role\_attributes) | Additional attributes to add to the role name | `list(string)` | `[]` | no |
| <a name="input_github_actions_iam_role_enabled"></a> [github\_actions\_iam\_role\_enabled](#input\_github\_actions\_iam\_role\_enabled) | Flag to toggle creation of an IAM Role that GitHub Actions can assume to access AWS resources | `bool` | `false` | no |
| <a name="input_github_oidc_trusted_role_arns"></a> [github\_oidc\_trusted\_role\_arns](#input\_github\_oidc\_trusted\_role\_arns) | A list of IAM Role ARNs allowed to assume this cluster's GitHub OIDC role | `list(string)` | `[]` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | The destination for the health check request | `string` | `"/health"` | no |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | The port to use to connect with the target. Valid values are either ports 1-65536, or `traffic-port`. Defaults to `traffic-port` | `string` | `"traffic-port"` | no |
| <a name="input_iam_policy_enabled"></a> [iam\_policy\_enabled](#input\_iam\_policy\_enabled) | If set to true will create IAM policy in AWS | `bool` | `false` | no |
| <a name="input_iam_policy_statements"></a> [iam\_policy\_statements](#input\_iam\_policy\_statements) | Map of IAM policy statements to use in the policy. This can be used with or instead of the `var.iam_source_json_url`. | `any` | `{}` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_kinesis_enabled"></a> [kinesis\_enabled](#input\_kinesis\_enabled) | Enable Kinesis | `bool` | `false` | no |
| <a name="input_kms_key_alias"></a> [kms\_key\_alias](#input\_kms\_key\_alias) | ID of KMS key | `string` | `"default"` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_lb_catch_all"></a> [lb\_catch\_all](#input\_lb\_catch\_all) | Should this service act as catch all for all subdomain hosts of the vanity domain | `bool` | `false` | no |
| <a name="input_logs"></a> [logs](#input\_logs) | Feed inputs into cloudwatch logs module | `any` | `{}` | no |
| <a name="input_memory_utilization_high_alarm_actions"></a> [memory\_utilization\_high\_alarm\_actions](#input\_memory\_utilization\_high\_alarm\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High Alarm action | `list(string)` | `[]` | no |
| <a name="input_memory_utilization_high_evaluation_periods"></a> [memory\_utilization\_high\_evaluation\_periods](#input\_memory\_utilization\_high\_evaluation\_periods) | Number of periods to evaluate for the alarm | `number` | `1` | no |
| <a name="input_memory_utilization_high_ok_actions"></a> [memory\_utilization\_high\_ok\_actions](#input\_memory\_utilization\_high\_ok\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High OK action | `list(string)` | `[]` | no |
| <a name="input_memory_utilization_high_period"></a> [memory\_utilization\_high\_period](#input\_memory\_utilization\_high\_period) | Duration in seconds to evaluate for the alarm | `number` | `300` | no |
| <a name="input_memory_utilization_high_threshold"></a> [memory\_utilization\_high\_threshold](#input\_memory\_utilization\_high\_threshold) | The maximum percentage of Memory utilization average | `number` | `80` | no |
| <a name="input_memory_utilization_low_alarm_actions"></a> [memory\_utilization\_low\_alarm\_actions](#input\_memory\_utilization\_low\_alarm\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low Alarm action | `list(string)` | `[]` | no |
| <a name="input_memory_utilization_low_evaluation_periods"></a> [memory\_utilization\_low\_evaluation\_periods](#input\_memory\_utilization\_low\_evaluation\_periods) | Number of periods to evaluate for the alarm | `number` | `1` | no |
| <a name="input_memory_utilization_low_ok_actions"></a> [memory\_utilization\_low\_ok\_actions](#input\_memory\_utilization\_low\_ok\_actions) | A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low OK action | `list(string)` | `[]` | no |
| <a name="input_memory_utilization_low_period"></a> [memory\_utilization\_low\_period](#input\_memory\_utilization\_low\_period) | Duration in seconds to evaluate for the alarm | `number` | `300` | no |
| <a name="input_memory_utilization_low_threshold"></a> [memory\_utilization\_low\_threshold](#input\_memory\_utilization\_low\_threshold) | The minimum percentage of Memory utilization average | `number` | `20` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_retention_period"></a> [retention\_period](#input\_retention\_period) | Length of time data records are accessible after they are added to the stream | `number` | `48` | no |
| <a name="input_shard_count"></a> [shard\_count](#input\_shard\_count) | Number of shards that the stream will use | `number` | `1` | no |
| <a name="input_shard_level_metrics"></a> [shard\_level\_metrics](#input\_shard\_level\_metrics) | List of shard-level CloudWatch metrics which can be enabled for the stream | `list(string)` | <pre>[<br>  "IncomingBytes",<br>  "IncomingRecords",<br>  "IteratorAgeMilliseconds",<br>  "OutgoingBytes",<br>  "OutgoingRecords",<br>  "ReadProvisionedThroughputExceeded",<br>  "WriteProvisionedThroughputExceeded"<br>]</pre> | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_stickiness_cookie_duration"></a> [stickiness\_cookie\_duration](#input\_stickiness\_cookie\_duration) | The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. The range is 1 second to 1 week (604800 seconds). The default value is 1 day (86400 seconds) | `number` | `86400` | no |
| <a name="input_stickiness_enabled"></a> [stickiness\_enabled](#input\_stickiness\_enabled) | Boolean to enable / disable `stickiness`. Default is `true` | `bool` | `true` | no |
| <a name="input_stickiness_type"></a> [stickiness\_type](#input\_stickiness\_type) | The type of sticky sessions. The only current possible value is `lb_cookie` | `string` | `"lb_cookie"` | no |
| <a name="input_stream_mode"></a> [stream\_mode](#input\_stream\_mode) | Stream mode details for the Kinesis stream | `string` | `"PROVISIONED"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_task"></a> [task](#input\_task) | Feed inputs into ecs\_alb\_service\_task module | `any` | `{}` | no |
| <a name="input_task_enabled"></a> [task\_enabled](#input\_task\_enabled) | Whether or not to use the ECS task module | `bool` | `true` | no |
| <a name="input_task_policy_arns"></a> [task\_policy\_arns](#input\_task\_policy\_arns) | The IAM policy ARNs to attach to the ECS task IAM role | `list(string)` | <pre>[<br>  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",<br>  "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"<br>]</pre> | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_use_lb"></a> [use\_lb](#input\_use\_lb) | Whether use load balancer for the service | `bool` | `false` | no |
| <a name="input_use_rds_client_sg"></a> [use\_rds\_client\_sg](#input\_use\_rds\_client\_sg) | Use the RDS client security group | `bool` | `false` | no |
| <a name="input_vanity_alias"></a> [vanity\_alias](#input\_vanity\_alias) | The vanity aliases to use for the public LB. | `list(string)` | `[]` | no |
| <a name="input_vanity_domain_enabled"></a> [vanity\_domain\_enabled](#input\_vanity\_domain\_enabled) | Whether to use the vanity domain alias for the service | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | Selected ECS cluster ARN |
| <a name="output_environment_map"></a> [environment\_map](#output\_environment\_map) | Environment variables to pass to the container, this is a map of key/value pairs, where the key is `containerName,variableName` |
| <a name="output_full_domain"></a> [full\_domain](#output\_full\_domain) | Domain to respond to GET requests |
| <a name="output_github_actions_iam_role_arn"></a> [github\_actions\_iam\_role\_arn](#output\_github\_actions\_iam\_role\_arn) | ARN of IAM role for GitHub Actions |
| <a name="output_github_actions_iam_role_name"></a> [github\_actions\_iam\_role\_name](#output\_github\_actions\_iam\_role\_name) | Name of IAM role for GitHub Actions |
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | Selected LB ARN |
| <a name="output_lb_listener_https"></a> [lb\_listener\_https](#output\_lb\_listener\_https) | Selected LB HTTPS Listener |
| <a name="output_lb_sg_id"></a> [lb\_sg\_id](#output\_lb\_sg\_id) | Selected LB SG ID |
| <a name="output_logs"></a> [logs](#output\_logs) | Output of cloudwatch logs module |
| <a name="output_service_image"></a> [service\_image](#output\_service\_image) | The image of the service container |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Selected subnet IDs |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | Selected VPC ID |
| <a name="output_vpc_sg_id"></a> [vpc\_sg\_id](#output\_vpc\_sg\_id) | Selected VPC SG ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/ecs-service) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
