# Defaults for Synthetics

This folder should contain the default synthetic test yaml configurations that should be applied to every stage and tenant.

This is the base folder for deep merges, meaning the yaml contained in this directory will be merged with specific environment folders' yaml files.

## Example Yaml Configuration:

```yaml
echo-server:
  name: "[${tenant} ${stage}] Echo Server Synthetics Check"
  message: "Echo Server Error - browser test error on [{{tenant}} {{stage}}]"
  type: browser
  subtype: http
  tags:
    - "ManagedBy:Terraform"
  status: "live"
  locations:
    - "all"
  request_definition:
    url: "" # This gets overridden
    method: GET
  request_headers:
#    Accept-Charset: "utf-8, iso-8859-1;q=0.5"
    Accept: "text/html"
  options_list:
    tick_every: 1800
    no_screenshot: false
    follow_redirects: false
    retry:
      count: 2
      interval: 10
    monitor_options:
      renotify_interval: 300
  browser_step:
    - name: "Check current URL"
      type: assertCurrentUrl
      params:
        check: contains
        value: "echo"
  device_ids:
    - laptop_large

```
