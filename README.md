<!-- This file was automatically generated by the `build-harness`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->
[![README Header][readme_header_img]][readme_header_link]

[![Cloud Posse][logo]](https://cpco.io/homepage)

# terraform-root-modules [![Build Status](https://travis-ci.org/cloudposse/terraform-root-modules.svg?branch=master)](https://travis-ci.org/cloudposse/terraform-root-modules) [![Codefresh Build Status](https://g.codefresh.io/api/badges/build?repoOwner=cloudposse&repoName=terraform-root-modules&branch=master&pipelineName=terraform-root-modules&accountName=cloudposse&type=cf-1)](https://g.codefresh.io/pipelines/terraform-root-modules/builds) [![Latest Release](https://img.shields.io/github/release/cloudposse/terraform-root-modules.svg)](https://github.com/cloudposse/terraform-root-modules/releases/latest) [![Slack Community](https://slack.cloudposse.com/badge.svg)](https://slack.cloudposse.com)


This is a collection of reusable [Terraform "root modules" invocations](https://docs.cloudposse.com/terraform-modules/root/) for CloudPosse AWS accounts.

Terraform defines a "root module" as the current working directory holding the Terraform configuration files where the terraform apply or terraform get is run.


---

This project is part of our comprehensive ["SweetOps"](https://cpco.io/sweetops) approach towards DevOps. 
[<img align="right" title="Share via Email" src="https://docs.cloudposse.com/images/ionicons/ios-email-outline-2.0.1-16x16-999999.svg"/>][share_email]
[<img align="right" title="Share on Google+" src="https://docs.cloudposse.com/images/ionicons/social-googleplus-outline-2.0.1-16x16-999999.svg" />][share_googleplus]
[<img align="right" title="Share on Facebook" src="https://docs.cloudposse.com/images/ionicons/social-facebook-outline-2.0.1-16x16-999999.svg" />][share_facebook]
[<img align="right" title="Share on Reddit" src="https://docs.cloudposse.com/images/ionicons/social-reddit-outline-2.0.1-16x16-999999.svg" />][share_reddit]
[<img align="right" title="Share on LinkedIn" src="https://docs.cloudposse.com/images/ionicons/social-linkedin-outline-2.0.1-16x16-999999.svg" />][share_linkedin]
[<img align="right" title="Share on Twitter" src="https://docs.cloudposse.com/images/ionicons/social-twitter-outline-2.0.1-16x16-999999.svg" />][share_twitter]




It's 100% Open Source and licensed under the [APACHE2](LICENSE).












## Introduction

In this repo you'll find real-world examples of how we've implemented various common patterns using our [terraform modules](https://cpco.io/terraform-modules) for our customers. 

The "root modules" form the module catalog of your organization. It's from this catalog that other developers in your organization will pick and choose from anytime they need to deploy some new capability.

Normally, a company should build up their own service catalog of terraform modules like this one, which is just a collection of terraform modules that capture the business logic, opinions, "best practices" and non-functional requirements of the organization.
No two companies will ever have the same assembly of `terraform-root-modules`.

The root modules are the most opinionated incarnations of modules that seldom translate verbatim across organizations. This is your secret sauce. We could never implement this in a sufficiently generic way without creating crazy bloat and complexity. Therefore treat the terraform-root-modules in this repository as your “starting off point” where you hardfork/diverge. 
These modules are very specific to how we do things in our environment, so they might not "drop in" smoothly in other environments as they make a lot of assumptions on how things are organized.

A company writes their own root modules. It’s their flavor of how to leverage the [generic building blocks](https://cpco.io/terraform-modules) to achieve the specific customizations that are required without needing to write everything from the ground up because they are leveraging our general purpose modules.
The idea is to write all of the [`terraform-aws-*`](https://cpco.io/terraform-modules) type modules very generically so they are easily composable inside of other modules.

These `terraform-root-modules` make a lot of assumptions about how we've configured our environments. That said, they can still serve as an excellent reference for others.

We recommend that you start with your clean `terraform-root-module` repo. Then start by creating a new project in there to describe the infrastructure that you want.

## Best Practices

* Every "root module" should include a `Makefile` that defines `init`, `plan`, and `apply` targets. 
  This establishes a common interface for interacting with terraform without the need of a wrapper like `terragrunt`.
* Never compose "root modules" inside of other root modules. If or when this is desired, then the module should be split off into a new repository and versioned independently as a standalone module.

## Example Makefile

Here's a good example of a `Makefile` for a terraform project:

```
## Initialize terraform remote state
init:
	[ -f .terraform/terraform.tfstate ] || init-terraform

## Clean up the project
clean:
	rm -rf .terraform *.tfstate*

## Pass arguments through to terraform which require remote state
apply console destroy graph plan output providers show: init
	terraform $@

## Pass arguments through to terraform which do not require remote state
get fmt validate version:
	terraform $@
```

## Usage

Use the `terraform-root-modules` Docker image as the base image in the application `Dockerfile`, and copy the modules from `/aws` folder into `/conf` folder.

```dockerfile
FROM cloudposse/terraform-root-modules:0.3.2 as terraform-root-modules

FROM cloudposse/geodesic:0.9.18

# Copy root modules into /conf folder
COPY --from=terraform-root-modules /aws/ /conf/

WORKDIR /conf/
```




## Examples

For example usage, refer to the "Related Projects" section. This is were we use `terraform-root-modules` to provision essential account-level infrastructure, among other services.



## Makefile Targets
```
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen

```




## Share the Love 

Like this project? Please give it a ★ on [our GitHub](https://github.com/cloudposse/terraform-root-modules)! (it helps us **a lot**) 

Are you using this project or any of our other projects? Consider [leaving a testimonial][testimonial]. =)


## Related Projects

Check out these related projects.

- [reference-architectures](https://github.com/cloudposse/reference-architectures) - Get up and running quickly with one of our reference architecture using our fully automated cold-start process.
- [audit.cloudposse.co](https://github.com/cloudposse/audit.cloudposse.co) - Example Terraform Reference Architecture of a Geodesic Module for an Audit Logs Organization in AWS.
- [prod.cloudposse.co](https://github.com/cloudposse/prod.cloudposse.co) - Example Terraform Reference Architecture of a Geodesic Module for a Production Organization in AWS.
- [staging.cloudposse.co](https://github.com/cloudposse/staging.cloudposse.co) - Example Terraform Reference Architecture of a Geodesic Module for a Staging Organization in AWS.
- [dev.cloudposse.co](https://github.com/cloudposse/dev.cloudposse.co) - Example Terraform Reference Architecture of a Geodesic Module for a Development Sandbox Organization in AWS.




## References

For additional context, refer to some of these links. 

- [Cloud Posse Documentation](https://docs.cloudposse.com) - Complete documentation for the Cloud Posse solution


## Help

**Got a question?**

File a GitHub [issue](https://github.com/cloudposse/terraform-root-modules/issues), send us an [email][email] or join our [Slack Community][slack].

[![README Commercial Support][readme_commercial_support_img]][readme_commercial_support_link]

## Commercial Support

Work directly with our team of DevOps experts via email, slack, and video conferencing. 

We provide [*commercial support*][commercial_support] for all of our [Open Source][github] projects. As a *Dedicated Support* customer, you have access to our team of subject matter experts at a fraction of the cost of a full-time engineer. 

[![E-Mail](https://img.shields.io/badge/email-hello@cloudposse.com-blue.svg)][email]

- **Questions.** We'll use a Shared Slack channel between your team and ours.
- **Troubleshooting.** We'll help you triage why things aren't working.
- **Code Reviews.** We'll review your Pull Requests and provide constructive feedback.
- **Bug Fixes.** We'll rapidly work to fix any bugs in our projects.
- **Build New Terraform Modules.** We'll [develop original modules][module_development] to provision infrastructure.
- **Cloud Architecture.** We'll assist with your cloud strategy and design.
- **Implementation.** We'll provide hands-on support to implement our reference architectures. 




## Slack Community

Join our [Open Source Community][slack] on Slack. It's **FREE** for everyone! Our "SweetOps" community is where you get to talk with others who share a similar vision for how to rollout and manage infrastructure. This is the best place to talk shop, ask questions, solicit feedback, and work together as a community to build totally *sweet* infrastructure.

## Newsletter

Signup for [our newsletter][newsletter] that covers everything on our technology radar.  Receive updates on what we're up to on GitHub as well as awesome new projects we discover. 

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/terraform-root-modules/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing this project or [help out](https://cpco.io/help-out) with our other projects, we would love to hear from you! Shoot us an [email][email].

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!


## Copyright

Copyright © 2017-2019 [Cloud Posse, LLC](https://cpco.io/copyright)



## License 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

See [LICENSE](LICENSE) for full details.

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









## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## About

This project is maintained and funded by [Cloud Posse, LLC][website]. Like it? Please let us know by [leaving a testimonial][testimonial]!

[![Cloud Posse][logo]][website]

We're a [DevOps Professional Services][hire] company based in Los Angeles, CA. We ❤️  [Open Source Software][we_love_open_source].

We offer [paid support][commercial_support] on all of our projects.  

Check out [our other projects][github], [follow us on twitter][twitter], [apply for a job][jobs], or [hire us][hire] to help with your cloud strategy and implementation.



### Contributors

|  [![Erik Osterman][osterman_avatar]][osterman_homepage]<br/>[Erik Osterman][osterman_homepage] | [![Igor Rodionov][goruha_avatar]][goruha_homepage]<br/>[Igor Rodionov][goruha_homepage] | [![Andriy Knysh][aknysh_avatar]][aknysh_homepage]<br/>[Andriy Knysh][aknysh_homepage] |
|---|---|---|

  [osterman_homepage]: https://github.com/osterman
  [osterman_avatar]: https://github.com/osterman.png?size=150
  [goruha_homepage]: https://github.com/goruha
  [goruha_avatar]: https://github.com/goruha.png?size=150
  [aknysh_homepage]: https://github.com/aknysh
  [aknysh_avatar]: https://github.com/aknysh.png?size=150



[![README Footer][readme_footer_img]][readme_footer_link]
[![Beacon][beacon]][website]

  [logo]: https://cloudposse.com/logo-300x69.svg
  [docs]: https://cpco.io/docs
  [website]: https://cpco.io/homepage
  [github]: https://cpco.io/github
  [jobs]: https://cpco.io/jobs
  [hire]: https://cpco.io/hire
  [slack]: https://cpco.io/slack
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://cpco.io/twitter
  [testimonial]: https://cpco.io/leave-testimonial
  [newsletter]: https://cpco.io/newsletter
  [email]: https://cpco.io/email
  [commercial_support]: https://cpco.io/commercial-support
  [we_love_open_source]: https://cpco.io/we-love-open-source
  [module_development]: https://cpco.io/module-development
  [terraform_modules]: https://cpco.io/terraform-modules
  [readme_header_img]: https://cloudposse.com/readme/header/img?repo=cloudposse/terraform-root-modules
  [readme_header_link]: https://cloudposse.com/readme/header/link?repo=cloudposse/terraform-root-modules
  [readme_footer_img]: https://cloudposse.com/readme/footer/img?repo=cloudposse/terraform-root-modules
  [readme_footer_link]: https://cloudposse.com/readme/footer/link?repo=cloudposse/terraform-root-modules
  [readme_commercial_support_img]: https://cloudposse.com/readme/commercial-support/img?repo=cloudposse/terraform-root-modules
  [readme_commercial_support_link]: https://cloudposse.com/readme/commercial-support/link?repo=cloudposse/terraform-root-modules
  [share_twitter]: https://twitter.com/intent/tweet/?text=terraform-root-modules&url=https://github.com/cloudposse/terraform-root-modules
  [share_linkedin]: https://www.linkedin.com/shareArticle?mini=true&title=terraform-root-modules&url=https://github.com/cloudposse/terraform-root-modules
  [share_reddit]: https://reddit.com/submit/?url=https://github.com/cloudposse/terraform-root-modules
  [share_facebook]: https://facebook.com/sharer/sharer.php?u=https://github.com/cloudposse/terraform-root-modules
  [share_googleplus]: https://plus.google.com/share?url=https://github.com/cloudposse/terraform-root-modules
  [share_email]: mailto:?subject=terraform-root-modules&body=https://github.com/cloudposse/terraform-root-modules
  [beacon]: https://ga-beacon.cloudposse.com/UA-76589703-4/cloudposse/terraform-root-modules?pixel&cs=github&cm=readme&an=terraform-root-modules
