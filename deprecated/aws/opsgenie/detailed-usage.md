## Opsgenie Resources

The following Opsgenie resources are configured (see [resources](resources)):

  - [API Integrations](resources/api_integrations.yaml)
  - [Teams](resources/teams.yaml)
  - [Users](resources/existing_users.yaml)
  - [Notification Policies](resources/notification_policies.yaml)
  - [Alert Policies](resources/alert_policies.yaml)
  - [Services](resources/services)
  - [Service Incident Rules](resources/services)
  - [Escalations](resources/escalations.yaml)


<br>

### `api_integrations.yaml`

__NOTE:__ We provision a Datadog integration without specifying the owning team.
Because of that, all alerts coming to Opsgenie from Datadog do not get assigned to a team automatically (if we specified the owning team,
then all alerts would go to the members of the team).
We assign alerts to the teams in the Alert Policies - when the filter conditions are `true`, the incoming alert gets assigned to a team.
This way, we can filter out and assigns to the teams only the actionable alerts (you can still view all alerts in the Opsgenie UI).


```yaml
api_integrations:

  - name: datadog
    type: Datadog
    # Use an empty value for `owner_team_name` to make it a global integration
    owner_team_name:
```

See [Opsgenie API Integration](https://docs.opsgenie.com/docs/api-integration) for more details.

<br>

### `teams.yaml`

Users are assigned to teams in `teams.yaml`.

We can assign the existing users (those that already present in Opsgenie, e.g. from Jira), or we can create new users and assign them to teams.

Describe the existing users in `existing_users.yaml` (see below). These users will be looked up using the data source `data "opsgenie_user"`.

Describe new users in `users.yaml` (see below). These users will be created in Opsgenie.

__NOTE:__ The user's `username` is email and must be unique.

__NOTE:__ Once a user is created by the module, it's not possible to destroy it using Terraform (not supported by the Opsgenie Terraform provider).


<br>

```yaml
teams:
  - name: devops
    description: "Infrastructure Team"
    members:
      - username: user1@example.com
        role: admin
      - username: user2@example.com
        role: user

  - name: example-team
    description: "Example Team"
    members:
      - username: user3@example.com
        role: admin
      - username: user4@example.com
        role: user
```

See [Opsgenie Teams](https://docs.opsgenie.com/docs/teams) for more details.

<br>

### `existing_users.yaml`

The existing users (those that are already in Opsgenie) are described here.

These users will be looked up using the data source `data "opsgenie_user"`.


```yaml
existing_users:
  - username: user1@example.com
  - username: user2@example.com
  - username: user3@example.com
  - username: user4@example.com
```

See [Opsgenie Users](https://docs.opsgenie.com/docs/users) for more details.

<br>

### `users.yaml`

New users (to be created by the module) are described here.

__NOTE:__ Once a user is created by the module, it's not possible to destroy it using Terraform (not supported by the Opsgenie Terraform provider).


```yaml
users:
  - username: user5@example.com
    full_name: New User
    role: User
    locale: "en_US"
    timezone: "America/New_York"
```

See [Opsgenie Users](https://docs.opsgenie.com/docs/users) for more details.

<br>


### `notification_policies.yaml`

Notification Policies are used to apply different operations (e.g. `delay/suppress`, `auto restart`, and `auto close`) to all team alert notifications.


```yaml
notification_policies:

  - name: auto-close-based-on-priority
    team_name: test
    auto_close_action:
      time_unit: minutes
      time_amount: 120
    filter:
      type: match-all-conditions
      conditions:
        - field: priority
          operation: less-than
          expected_value: P3
```

See [Opsgenie Notification Policy](https://docs.opsgenie.com/docs/team-policies#notification-policy) for more details.

<br>

### `escalations.yaml`

Escalations are used to escalate the alerts and incidents to a top-level Team
if they do not get acknowledged during the specified amount of time.

Escalations are also used to notify responders according to a given order.


```yaml
escalations:
  - name: example-team-escalation-to-devops
    description: "Escalate to 'devops' team if 'example-team' does not acknowledge in 10 minutes"
    owner_team_name: example-team
    rule:
      condition: if-not-acked
      notify_type: all
      delay: 10
      recipients:
        - type: team
          team_name: devops
    repeat:
      wait_interval: 10
      count: 2
      reset_recipient_states: false
      close_alert_after_all: false
```

See [Opsgenie Escalations](https://docs.opsgenie.com/docs/escalations) for more details.

<br>

## Flow

The following flow of events is supported:

  - Datadog sends alerts to Opsgenie. All incoming alerts are shown in the Opsgenie UI, but the alerts don't get assigned to teams automatically.

  - The Alert Policies get evaluated by looking for a specific text in the alert's message or description.
    If the filter conditions in any Alert Policy are evaluated to `true`, the policy gets executed and the alert gets assigned to the team specified in the Alert Policy.
    Also, a tag with the name of the service gets added to the alert.

  - The Service Incident Rules get evaluated.
    If the filter conditions in any Service Incident Rules are evaluated to `true`, the rule gets executed, and an incident is created for the service
    and assigned to the team the service belongs to. The users of the team get notifications about the incident (via the configured channels, e.g. email, SMS, Opsgenie app, etc.).
    On the other hand, if the filter conditions in any Service Incident Rules are evaluated to `false`, Opsgenie does not create an incident,
    but instead notifies the users of the team about the alert via the configured channels.

  - If the alert or incident is not acknowledged by any of the team members during the specified amount of time, the Team's Escalations get evaluated. If Opsgenie finds
    an Escalation for the team, it sends notifications to the recipients of the Escalation (e.g. to the users of a top-level Team).

<br>

## New Service Setup

The Opsgenie resources for a new service are provided in a separate YAML config file (for readability and easy of management).

To add a new service configuration, create a new YAML file with the name of the service.

See [resources/services](resources/services) for details on each service.

Each service's config file contains the three sections:

  - `service` - provides the name of the service and the name of the team the service belongs to
  - `alert_policies` - a list of Opsgenie [Alert Policies](https://docs.opsgenie.com/docs/global-policies#alert-policy) for the service
  - `service_incident_rules` - a list of Opsgenie [Service Incident Rules](https://docs.opsgenie.com/docs/service-incident-rules-api) for the service

Below are the steps to create Datadog monitors and Opsgenie alert policies and incident rules for a new service.

__NOTE:__ We will be using `example-service` as an example.

  - In the [datadog-monitor](../datadog-monitor) project, add a new YAML file with Datadog monitor configurations for the new service.
    For the `example-service`, the file name is [example-service.yaml](../datadog-monitor/monitors/example-service.yaml).

  - Configure Datadog monitors for the service.
    For example, to monitor the error rate on `prod`, add the following configuration:

  ```yaml
    example-service-prod-high-error-rate:
      name: "(example-service) Service example-service has a high error rate on env:prod"
      type: query alert
      query: |
        sum(last_10m):( sum:trace.flask.request.errors{service:example-service,env:prod}.as_count() / sum:trace.flask.request.hits{service:example-service,env:prod}.as_count() ) > 0.05
      message: |
        example-service error rate is too high on env:prod
      escalation_message: ""
      tags:
        - "ManagedBy:Terraform"
        - "service:example-service"
        - "env:prod"
        - "alert:high-error-rate"
      notify_no_data: false
      notify_audit: true
      require_full_window: false
      enable_logs_sample: false
      force_delete: true
      include_tags: true
      locked: false
      renotify_interval: 0
      timeout_h: 0
      evaluation_delay: 60
      new_host_delay: 300
      no_data_timeframe: 10
      threshold_windows: { }
      thresholds:
        critical: 0.05
        warning: 0.01
  ```

   Note that the `tags` added to the monitor can be used in Opsgenie alert policies and incident rules to match specific alerts from Datadog.

  - Add the users responsible for the service to [Opsgenie Users](resources/existing_users.yaml)
    (or to `users.yaml` if the users don't yet exist in Opsgenie, and you want to create them with Terraform).

  ```yaml
    existing_users:
      - username: user1@example.com
  ```

  - Assign the users to the [Opsgenie Team](resources/teams.yaml)

  ```yaml
    - name: example-team
      description: "Example Team"
      members:
        - username: user1@example.com
          role: admin
  ```

  - Add [The service and Opsgenie Alert Policies and Service Incident Rules](resources/services/example-service.yaml)

      NOTE: The alert policy will assign the Team specified in the `responders` section to the alerts.
      The `responders` section is a list, so you can assign many teams as responders to the alerts.

  ```yaml
    service:
      - name: example-service
        team_name: example-team


    alert_policies:
      - name: example-service-alert-policy
        owner_team_name:
        tags:
          - "ManagedBy:terraform"
          - "service:example-service"
        filter:
          type: match-any-condition
          conditions:
            - field: description
              operation: contains
              expected_value: "example-service"
            - field: message
              operation: contains
              expected_value: "example-service"
        continue_policy: true
        ignore_original_responders: true
        responders:
          - type: team
            team_name: example-team


    service_incident_rules:
      - name: example-service-incident-rule
        service_name: example-service
        incident_rule:
          condition_match_type: match-any-condition

          conditions:
            - field: tags
              operation: contains
              expected_value: "service:example-service"

          incident_properties:
            message: example-service is having issues
            priority: P2
            stakeholder_properties:
              message: example-service is having issues
              enable: true
  ```

   NOTE: In the Alert Policy, `condition_match_type: match-any-condition` is a logical `OR`, which means if any condition is `true`, the alert will be
   assigned to the service's team. In the example above, alerts will be assigned to the `example-team` team if the alert's message or description contains `example-service`.
   If the condition matches, we also add the tag `service:example-service` to the alert, which we use in the conditions of the Service Incident Rule.

   NOTE: In the Service Incident Rule, we check if the alert's tags contain the service name tag (`service:example-service` in this case).
   If the condition matches, we create an incident and assign it to the team, the members of which get notifications about the incident.

  - Provision the `datadog-monitor` and `opsgenie` projects with Terraform.
    Datadog will monitor the `example-service` with the provisioned monitors and send alerts to Opsgenie.
