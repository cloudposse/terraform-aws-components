<!-- markdownlint-disable -->
<a href="https://cpco.io/homepage"><img src=".github/banner.png?raw=true" alt="Project Banner"/></a><br/>
    <p align="right">
<a href="https://github.com/cloudposse/terraform-aws-components/releases/latest"><img src="https://img.shields.io/github/release/cloudposse/terraform-aws-components.svg?style=for-the-badge" alt="Latest Release"/></a><a href="https://github.com/cloudposse/terraform-aws-components/commits/main/"><img src="https://img.shields.io/github/last-commit/cloudposse/terraform-aws-components/main?style=for-the-badge" alt="Last Update"/></a><a href="https://slack.cloudposse.com"><img src="https://slack.cloudposse.com/for-the-badge.svg" alt="Slack Community"/></a></p>
<!-- markdownlint-restore -->

<!--




  ** DO NOT EDIT THIS FILE
  **
  ** This file was automatically generated by the `cloudposse/build-harness`.
  ** 1) Make all changes to `README.yaml`
  ** 2) Run `make init` (you only need to do this once)
  ** 3) Run`make readme` to rebuild this file.
  **
  ** (We maintain HUNDREDS of open source projects. This is how we maintain our sanity.)
  **





-->

This is a collection of reusable [AWS Terraform components](https://atmos.tools/core-concepts/components/) for provisioning infrastructure used by the Cloud Posse [reference architectures](https://cloudposse.com).
They work really well with [Atmos](https://atmos.tools), our open-source tool for managing infrastructure as code with Terraform.


---
> [!NOTE]
> This project is part of Cloud Posse's comprehensive ["SweetOps"](https://cpco.io/homepage?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-components&utm_content=) approach towards DevOps.
> <details><summary><strong>Learn More</strong></summary>
>
> It's 100% Open Source and licensed under the [APACHE2](LICENSE).
>
> </details>

<a href="https://cloudposse.com/readme/header/link?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-components&utm_content=readme_header_link"><img src="https://cloudposse.com/readme/header/img"/></a>


## Introduction

In this repo you'll find real-world examples of how we've implemented various common patterns using our [terraform modules](https://cpco.io/terraform-modules) for our customers.

The [component library](https://docs.cloudposse.com/components/) captures the business logic, opinions, best practices and non-functional requirements.

It's from this library that other developers in your organization will pick and choose from anytime they need to deploy some new capability.

These components make a lot of assumptions about how we've configured our environments. That said, they can still serve as an excellent reference for others.



## Usage




Please take a look at each [component's README](https://docs.cloudposse.com/components/) for specific usage.

> [!TIP]
> ## 👽 Use Atmos with Terraform
> To orchestrate multiple environments with ease using Terraform, Cloud Posse recommends using [Atmos](https://atmos.tools),
> our open-source tool for Terraform automation.
>
> <details>
> <summary><strong>Watch demo of using Atmos with Terraform</strong></summary>
> <img src="https://github.com/cloudposse/atmos/blob/master/docs/demo.gif?raw=true"/><br/>
> <strong>Example of running <a href="https://atmos.tools">`atmos`</a> to describe infrastructure.</strong>
> </detalis>

Generally, you can use these components in [Atmos](https://atmos.tools/core-concepts/components/) by adding something like the following
code into your [stack manifest](https://atmos.tools/core-concepts/stacks/):

```yaml
components:                      # List of components to include in the stack
  terraform:                     # The toolchain being used for configuration
    vpc:                         # The name of the component (e.g. terraform "root" module)
      vars:                      # Terraform variables (e.g. `.tfvars`)
        cidr_block: 10.0.0.0/16  # A variable input passed to terraform via `.tfvars`
```

## Automated Updates of Components using GitHub Actions

Leverage our [GitHub Action](https://atmos.tools/integrations/github-actions/component-updater) to automate the creation and management of pull requests for component updates.

This is done by creating a new file (e.g. `atmos-component-updater.yml`) in the `.github/workflows` directory of your repository.

The file should contain the following:

```yaml
jobs:
update:
  runs-on:
    - "ubuntu-latest"
  steps:
    - name: Checkout Repository
      uses: actions/checkout@v4
      with:
        fetch-depth: 1

    - name: Update Atmos Components
      uses: cloudposse/github-action-atmos-component-updater@v2
      env:
        # https://atmos.tools/cli/configuration/#environment-variables
        ATMOS_CLI_CONFIG_PATH: ${{ github.workspace }}/rootfs/usr/local/etc/atmos/
      with:
        github-access-token: ${{ secrets.GITHUB_TOKEN }}
        log-level: INFO
        max-number-of-prs: 10

    - name: Delete abandoned update branches
      uses: phpdocker-io/github-actions-delete-abandoned-branches@v2
      with:
        github_token: ${{ github.token }}
        last_commit_age_days: 0
        allowed_prefixes: "component-update/"
        dry_run: no
```

For the full documentation on how to use the Component Updater GitHub Action, please see the [Atmos Intergations](https://atmos.tools/integrations/github-actions/component-updater) documentation.

## Using `pre-commit` Hooks

This repository uses [pre-commit](https://pre-commit.com/) and [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform) to enforce consistent Terraform code and documentation. This is accomplished by triggering hooks during `git commit` to block commits that don't pass checks (E.g. format, and module documentation). You can find the hooks that are being executed in the [`.pre-commit-config.yaml`](.pre-commit-config.yaml) file.

You can install [pre-commit](https://pre-commit.com/) and this repo's pre-commit hooks on a Mac machine by running the following commands:

```bash
brew install pre-commit gawk terraform-docs coreutils
pre-commit install --install-hooks
```

Then run the following command to rebuild the docs for all Terraform components:

```bash
make rebuild-docs
```

> [!IMPORTANT]
> ## Deprecated Components
> Terraform components which are no longer actively maintained are kept in the [`deprecated/`](deprecated/) folder.
>
> Many of these deprecated components are used in our older reference architectures.
>
> We intend to eventually delete, but are leaving them for now in the repo.






<!-- markdownlint-disable -->
## Makefile Targets
```text
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  rebuild-docs                        Rebuild README for all Terraform components
  rebuild-mixins-docs                 Rebuild README for Terraform Mixins
  upstream-component                  Upstream a given component

```
<!-- markdownlint-restore -->


## Related Projects

Check out these related projects.

- [Cloud Posse Terraform Modules](https://docs.cloudposse.com/modules/) - Our collection of reusable Terraform modules used by our reference architectures.
- [Atmos](https://atmos.tools) - Atmos is like docker-compose but for your infrastructure


## References

For additional context, refer to some of these links.

- [Cloud Posse Documentation](https://docs.cloudposse.com) - Complete documentation for the Cloud Posse solution
- [Reference Architectures](https://cloudposse.com/) - Launch effortlessly with our turnkey reference architectures, built either by your team or ours.


## ✨ Contributing

This project is under active development, and we encourage contributions from our community.
Many thanks to our outstanding contributors:

<a href="https://github.com/cloudposse/terraform-aws-components/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudposse/terraform-aws-components&max=24" />
</a>

### 🐛 Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/terraform-aws-components/issues) to report any bugs or file feature requests.

### 💻 Developing

If you are interested in being a contributor and want to get involved in developing this project or help out with Cloud Posse's other projects, we would love to hear from you! 
Hit us up in [Slack](https://cpco.io/slack?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-components&utm_content=slack), in the `#cloudposse` channel.

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.
 1. Review our [Code of Conduct](https://github.com/cloudposse/terraform-aws-components/?tab=coc-ov-file#code-of-conduct) and [Contributor Guidelines](https://github.com/cloudposse/.github/blob/main/CONTRIBUTING.md).
 2. **Fork** the repo on GitHub
 3. **Clone** the project to your own machine
 4. **Commit** changes to your own branch
 5. **Push** your work back up to your fork
 6. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!

### 🌎 Slack Community

Join our [Open Source Community](https://cpco.io/slack?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-components&utm_content=slack) on Slack. It's **FREE** for everyone! Our "SweetOps" community is where you get to talk with others who share a similar vision for how to rollout and manage infrastructure. This is the best place to talk shop, ask questions, solicit feedback, and work together as a community to build totally *sweet* infrastructure.

### 📰 Newsletter

Sign up for [our newsletter](https://cpco.io/newsletter?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-components&utm_content=newsletter) and join 3,000+ DevOps engineers, CTOs, and founders who get insider access to the latest DevOps trends, so you can always stay in the know.
Dropped straight into your Inbox every week — and usually a 5-minute read.

### 📆 Office Hours <a href="https://cloudposse.com/office-hours?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-components&utm_content=office_hours"><img src="https://img.cloudposse.com/fit-in/200x200/https://cloudposse.com/wp-content/uploads/2019/08/Powered-by-Zoom.png" align="right" /></a>

[Join us every Wednesday via Zoom](https://cloudposse.com/office-hours?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-components&utm_content=office_hours) for your weekly dose of insider DevOps trends, AWS news and Terraform insights, all sourced from our SweetOps community, plus a _live Q&A_ that you can’t find anywhere else.
It's **FREE** for everyone!

## About

This project is maintained by <a href="https://cpco.io/homepage?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-components&utm_content=">Cloud Posse, LLC</a>.
<a href="https://cpco.io/homepage?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-components&utm_content="><img src="https://cloudposse.com/logo-300x69.svg" align="right" /></a>

We are a [**DevOps Accelerator**](https://cpco.io/commercial-support?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-components&utm_content=commercial_support) for funded startups and enterprises.
Use our ready-to-go terraform architecture blueprints for AWS to get up and running quickly.
We build it with you. You own everything. Your team wins. Plus, we stick around until you succeed.

<a href="https://cpco.io/commercial-support?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-components&utm_content=commercial_support"><img alt="Learn More" src="https://img.shields.io/badge/learn%20more-success.svg?style=for-the-badge"/></a>

*Your team can operate like a pro today.*

Ensure that your team succeeds by using our proven process and turnkey blueprints. Plus, we stick around until you succeed.

<details>
  <summary>📚 <strong>See What's Included</strong></summary>

- **Reference Architecture.** You'll get everything you need from the ground up built using 100% infrastructure as code.
- **Deployment Strategy.** You'll have a battle-tested deployment strategy using GitHub Actions that's automated and repeatable.
- **Site Reliability Engineering.** You'll have total visibility into your apps and microservices.
- **Security Baseline.** You'll have built-in governance with accountability and audit logs for all changes.
- **GitOps.** You'll be able to operate your infrastructure via Pull Requests.
- **Training.** You'll receive hands-on training so your team can operate what we build.
- **Questions.** You'll have a direct line of communication between our teams via a Shared Slack channel.
- **Troubleshooting.** You'll get help to triage when things aren't working.
- **Code Reviews.** You'll receive constructive feedback on Pull Requests.
- **Bug Fixes.** We'll rapidly work with you to fix any bugs in our projects.
</details>

<a href="https://cloudposse.com/readme/commercial-support/link?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-components&utm_content=readme_commercial_support_link"><img src="https://cloudposse.com/readme/commercial-support/img"/></a>
## License

<a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=for-the-badge" alt="License"></a>

<details>
<summary>Preamble to the Apache License, Version 2.0</summary>
<br/>
<br/>
Complete license is available in the [`LICENSE`](LICENSE) file.
```text
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
```
</details>

## Trademarks

All other trademarks referenced herein are the property of their respective owners.
---
Copyright © 2017-2024 [Cloud Posse, LLC](https://cpco.io/copyright)


<a href="https://cloudposse.com/readme/footer/link?utm_source=github&utm_medium=readme&utm_campaign=cloudposse/terraform-aws-components&utm_content=readme_footer_link"><img alt="README footer" src="https://cloudposse.com/readme/footer/img"/></a>

<img alt="Beacon" width="0" src="https://ga-beacon.cloudposse.com/UA-76589703-4/cloudposse/terraform-aws-components?pixel&cs=github&cm=readme&an=terraform-aws-components"/>
