# Component: `api-gateway-rest-api`

This component is responsible for deploying an API Gateway REST API.

## Usage

**Stack Level**: Regional

The following is a snippet for how to use this component:

```yaml
components:
  terraform:
    api-gateway-rest-api:
      vars:
        enabled: true
        name: api
        openapi_config:
          openapi: 3.0.1
          info:
            title: Example API Gateway
            version: 1.0.0
          paths:
            "/":
              get:
                x-amazon-apigateway-integration:
                  httpMethod: GET
                  payloadFormatVersion: 1.0
                  type: HTTP_PROXY
                  uri: https://api.ipify.org
            "/{proxy+}":
              get:
                x-amazon-apigateway-integration:
                  httpMethod: GET
                  payloadFormatVersion: 1.0
                  type: HTTP_PROXY
                  uri: https://api.ipify.org
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.0 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`acm` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`api_gateway_rest_api` | 0.3.1 | [`cloudposse/api-gateway/aws`](https://registry.terraform.io/modules/cloudposse/api-gateway/aws/0.3.1) | n/a
`dns_delegated` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`nlb` | 0.12.0 | [`cloudposse/nlb/aws`](https://registry.terraform.io/modules/cloudposse/nlb/aws/0.12.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


## Resources

The following resources are used by this module:

  - [`aws_api_gateway_base_path_mapping.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_base_path_mapping) (resource)(main.tf#53)
  - [`aws_api_gateway_domain_name.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_domain_name) (resource)(main.tf#41)
  - [`aws_route53_record.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) (resource)(main.tf#66)

## Data Sources

The following data sources are used by this module:

  - [`aws_acm_certificate.issued`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) (data source)
  - [`aws_route53_zone.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) (data source)

## Outputs

<dl>
  <dt><code>arn</code></dt>
  <dd>
    The ARN of the REST API<br/>

  </dd>
  <dt><code>created_date</code></dt>
  <dd>
    The date the REST API was created<br/>

  </dd>
  <dt><code>execution_arn</code></dt>
  <dd>
        The execution ARN part to be used in lambda_permission's source_arn when allowing API Gateway to invoke a Lambda<br/>
        function, e.g., arn:aws:execute-api:eu-west-2:123456789012:z4675bid1j, which can be concatenated with allowed stage,<br/>
        method and resource path.The ARN of the Lambda function that will be executed.<br/>
    <br/>

  </dd>
  <dt><code>id</code></dt>
  <dd>
    The ID of the REST API<br/>

  </dd>
  <dt><code>invoke_url</code></dt>
  <dd>
    The URL to invoke the REST API<br/>

  </dd>
  <dt><code>root_resource_id</code></dt>
  <dd>
    The resource ID of the REST API's root<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
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
>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>



## Optional Variables
### `access_log_format` (`string`) <i>optional</i>


The format of the access log file.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"  {\n  \"requestTime\": \"$context.requestTime\",\n  \"requestId\": \"$context.requestId\",\n  \"httpMethod\": \"$context.httpMethod\",\n  \"path\": \"$context.path\",\n  \"resourcePath\": \"$context.resourcePath\",\n  \"status\": $context.status,\n  \"responseLatency\": $context.responseLatency,\n  \"xrayTraceId\": \"$context.xrayTraceId\",\n  \"integrationRequestId\": \"$context.integration.requestId\",\n  \"functionResponseStatus\": \"$context.integration.status\",\n  \"integrationLatency\": \"$context.integration.latency\",\n  \"integrationServiceStatus\": \"$context.integration.integrationStatus\",\n  \"authorizeResultStatus\": \"$context.authorize.status\",\n  \"authorizerServiceStatus\": \"$context.authorizer.status\",\n  \"authorizerLatency\": \"$context.authorizer.latency\",\n  \"authorizerRequestId\": \"$context.authorizer.requestId\",\n  \"ip\": \"$context.identity.sourceIp\",\n  \"userAgent\": \"$context.identity.userAgent\",\n  \"principalId\": \"$context.authorizer.principalId\",\n  \"cognitoUser\": \"$context.identity.cognitoIdentityId\",\n  \"user\": \"$context.identity.user\"\n}\n"</code>
>   </dd>
> </dl>
>


### `deregistration_delay` (`number`) <i>optional</i>


The amount of time to wait in seconds before changing the state of a deregistering target to unused<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>15</code>
>   </dd>
> </dl>
>


### `enable_private_link_nlb` (`bool`) <i>optional</i>


A flag to indicate whether to enable private link.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `enable_private_link_nlb_deletion_protection` (`bool`) <i>optional</i>


A flag to indicate whether to enable private link deletion protection.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `endpoint_type` (`string`) <i>optional</i>


The type of the endpoint. One of - PUBLIC, PRIVATE, REGIONAL<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"REGIONAL"</code>
>   </dd>
> </dl>
>


### `fully_qualified_domain_name` (`string`) <i>optional</i>


The fully qualified domain name of the API.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `logging_level` (`string`) <i>optional</i>


The logging level of the API. One of - OFF, INFO, ERROR<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"INFO"</code>
>   </dd>
> </dl>
>


### `metrics_enabled` (`bool`) <i>optional</i>


A flag to indicate whether to enable metrics collection.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `openapi_config` (`any`) <i>optional</i>


The OpenAPI specification for the API<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `rest_api_policy` (`string`) <i>optional</i>


The IAM policy document for the API.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `xray_tracing_enabled` (`bool`) <i>optional</i>


A flag to indicate whether to enable X-Ray tracing.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>



## Context Variables

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
>
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
>
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
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>    {
>      "additional_tag_map": {},
>      "attributes": [],
>      "delimiter": null,
>      "descriptor_formats": {},
>      "enabled": true,
>      "environment": null,
>      "id_length_limit": null,
>      "label_key_case": null,
>      "label_order": [],
>      "label_value_case": null,
>      "labels_as_tags": [
>        "unset"
>      ],
>      "name": null,
>      "namespace": null,
>      "regex_replace_chars": null,
>      "stage": null,
>      "tags": {},
>      "tenant": null
>    }
>    ```
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
>
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
>
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
>
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
>
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
>
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
>
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
>
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
>
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
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>    [
>      "default"
>    ]
>    ```
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
>
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
>
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
>
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
>
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
>
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
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/TODO) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
