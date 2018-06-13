![Cloud Posse](https://cloudposse.com/logo-300x69.png)

# terraform-root-modules ![Build Status](https://g.codefresh.io/api/badges/build?repoOwner=cloudposse&repoName=terraform-root-modules&branch=master&pipelineName=terraform-root-modules&accountName=cloudposse)


This is a collection of reusable root modules for CloudPosse AWS accounts.


## Usage

Use the `terraform-root-modules` Docker image as the base image in the application `Dockerfile`, and copy the modules from `/aws` folder into `/conf` folder

```dockerfile
FROM cloudposse/terraform-root-modules:0.3.5 as terraform-root-modules

FROM cloudposse/geodesic:0.9.18

# Copy root modules into /conf folder
COPY --from=terraform-root-modules /aws/ /conf/

WORKDIR /conf/
```

Then provision the rest of the Terraform modules required for the project.


## Cold Start

Here we describe the `cold start` process, when you start with just one master AWS account and need to provision infrastructure for different stages.

At Cloud Posse, we use the following accounts:

* [root](https://github.com/cloudposse/root.cloudposse.co) - Root account that we use to provision the IAM users to grant access to all other accounts
* [prod](https://github.com/cloudposse/prod.cloudposse.co) - main Production account
* [staging](https://github.com/cloudposse/staging.cloudposse.co) - Staging account
* [audit](https://github.com/cloudposse/audit.cloudposse.co) - Audit account
* [dev](https://github.com/cloudposse/dev.cloudposse.co) - Development account
* [testing](https://github.com/cloudposse/testing.cloudposse.co) - Testing account used for fast provisioning and destroying infrastructure for testing purposes

We provision each stage into a separate AWS account, which gives us the following benefits:

* **Complete separation of resources** - you can't affect anything in one account (e.g. `prod`) by doing something in another (e.g. `staging`)
* **Better security** - each account has its own users, roles, and permissions. Users can only access the accounts for which they have the required permissions by assuming IAM roles, and won't be able to see anything else
* **Simpler DevOps** - you can destroy everything in one account (e.g. `terraform destroy`) without affecting any resources in the other accounts
* **Easier management** - it's much easier to manage users, roles and permissions per account than try to remember the web of dependencies of who can access what in a single account
* **Simpler audit and compliance** - we provision a `CloudTrail` state bucket only in the `audit` account to collect `CloudTrail` logs from all other accounts. 
`CloudTrail` logs are automatically separated into different folders per account in the S3 bucket. Only a restricted set of users can have access to the `audit` account

__NOTE:__ From the operational point of view, it would be easier (and faster) to provision all the infrastructure into just one AWS account.
However, we strongly recommend using multiple accounts for the benefits described above.
At Cloud Posse, we always follow these best practices.
Depending on your requirements, you might not need all the stages (e.g. the `audit` or `dev` stage might not be required).
You also might not need to provision all the resources (e.g. `backing-services/aurora-postgres` or `acm-cloudfront`).


### Prerequisites

* Choose an AWS region in which to provision all the resources - we use `us-west-2` for our reference architecture

* Select the parent DNS domain name for your infrastructure - in these examples we use `cloudposse.co`

* Choose the namespace for resource naming. We recommend using your company name or abbreviation as the namespace (e.g. `cloudposse`, `cp`, `cpco`) - we use `cpco` in all the examples

* We assume you already have an AWS account. If not create an account at `https://aws.amazon.com`. This account will be the `root`

* Login to the `root` account with the root credentials and do the following:
  * Create new IAM group `admin`
  * Assign `AdministratorAccess` policy to the group
  * Create an IAM user with the name `admin`
  * Add the user to the group
  * Enable MFA for the user (we recommend using Google Authenticator as Virtual MFA device)
  * Generate `Access Key ID` and `Secret Access Key` for the user (you'll need them in the next steps)

* Install and setup [aws-vault](https://github.com/99designs/aws-vault) to store IAM credentials in your operating system's secure keystore and then generate temporary credentials from those to expose to your shell and applications

You can install manually from [aws-vault](https://github.com/99designs/aws-vault/releases). On MacOS, you may use `homebrew cask`

```bash
brew cask install aws-vault
```

Then setup your secret credentials in `aws-vault` in the `cpco` profile (input the IAM `Access Key ID` and `Secret Access Key` when prompted)

__NOTE:__ Replace the profile name `cpco` with your own (for consistency, we recommend using the same name as the namespace in the Terraform modules)

```bash
export AWS_VAULT_BACKEND=file
aws-vault add cpco
```

__NOTE:__ You should set `AWS_VAULT_BACKEND=file` in your shell `rc` config (e.g. `~/.bashrc`) so it persists.

* Keep in mind that AWS has limits on the number of accounts in an organization (see [Organization reference limits](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_reference_limits.html)).
If you are planning on provisioning all the accounts (`prod`, `staging`, `dev`, `audit`, `testing`), contact AWS Support and request a limit increase.


## Cold Start Process

In this example, we'll provision resources for the following two accounts:

* `root` - always in use as the Root of the AWS accounts hierarchy and also as the main account to store all the IAM users and roles used to access the other accounts
* `testing` - we use it to quickly create and destroy infrastructure for testing 

The other stages (`prod`, `staging`, `dev`, `audit`) are similar (they might differ by the resources you provision), and as has been noticed before, you might not need all of them.


### Copy Cloud Posse Reference Architectures

Copy the [root](https://github.com/cloudposse/root.cloudposse.co) and [testing](https://github.com/cloudposse/testing.cloudposse.co) repos to your local workstation
into two different folders. For this example, we'll use `~/root.cloudposse.co` and `~/testing.cloudposse.co` respectively.

Update all ENV variables in the two `Dockefiles` in the repos with the values for your project:
 
 * Change `DOCKER_IMAGE`
 * Replace the namespace `cpco` with your own in all ENV vars
 * Change the domain names from `cloudposse.co` to your own
 * In root, update the account ID (`TF_VAR_account_id`) to your own `root` account ID
 * Change the IAM user names for the accounts
 * Update the account emails
 * In `testing`, select only the resources you need to provision (using `COPY --from=terraform-root-modules`)


### Add AWS Profile for `root`

We require all users to assume IAM roles to access all the accounts (including `root`).

But since we start with a new account with no users and roles created yet, in this step we use the `admin` user credentials to access the account without assuming roles.

We'll update this profile to use `role_arn` later after we provision the roles.

In `~/.aws/config` file, add this profile for the `root` account:

```
[profile cpco-root-admin]
region=us-west-2
mfa_serial=arn:aws:iam::323330167063:mfa/admin@cloudposse.co
source_profile=cpco

# This profile is required by aws-vault where it stores the Access Key ID and Secret Access Key as explained in Prerequisites
[profile cpco]
```

__NOTE:__ Set the namespace and profile name `cpco`, the region, the `root` account ID `323330167063` and the admin user `admin@cloudposse.co` to your own values.


### Build and Start Geodesic Module for `root`

Open a terminal window and execute the following commands:
 
```bash
cd ~/root.cloudposse.co

# Initialize the project's build-harness
make init

# Build docker image
make docker/build

# Install the wrapper shell
make install

# Run the shell
root.cloudposse.co

# Login to AWS as the admin user with your MFA device
assume-role
```

You should see the `Docker` image built, `geodesic` shell started, and after you run the `assume-role` command, you will be logged in to the `root` account as the `admin` user:

```
# Starting new root.cloudposse.co session from cloudposse/root.cloudposse.co:latest
# Exposing port 36682
# Started EC2 metadata service at http://169.254.169.254/latest

IMPORTANT:
* Your $HOME directory has been mounted to `/localhost`
* Use `aws-vault` to manage your sessions
* Run `assume-role` to start a session

Add your local private SSH key to the key chain. Hit ^C to skip.
Enter passphrase for /localhost/.ssh/id_rsa:
Identity added: /localhost/.ssh/id_rsa (/localhost/.ssh/id_rsa)
-> Run 'assume-role' to login to AWS
assume-role
Enter passphrase to unlock /conf/.awsvault/keys/:
* Assumed role arn:aws:iam::323330167063:user/admin@cloudposse.co
```

### Provision `tfstate-backend` project for `root`

We store Terraform state in an S3 bucket and use a DynamoDB table for state locking (allowing many users to work on the same project without affecting each other and corrupting the state).

But we don't have the state bucket and DynamoDB table provisioned yet, so we can't store Terraform state in them.

We will create the bucket and table using local state, and then import the state into the bucket.

Execute this sequence of steps in the `root` geodesic session:

```
cd tfstate-backend

Comment out the `backend          "s3"             {}` line in `tfstate-backend/main.tf`

Run `init-terraform`

Run `terraform plan` and then `terraform apply`

Re-enable `backend          "s3"             {}` line in `tfstate-backend/main.tf`

Re-run `init-terraform`

Re-run `terraform apply`, answer `yes` when asked to import state

```

__NOTE:__ You could use the following commands to comment out and then uncomment the `backend` line:

```bash
sed -i 's/backend          "s3"             {}/#backend          "s3"             {}/' main.tf
sed -i 's/#backend          "s3"             {}/backend          "s3"             {}/' main.tf
```

Now we have the S3 bucket and DynamoDB table provisioned, and Terraform state stored in the bucket itself.


### Provision `iam` project to create `root` IAM Role

As was mentioned before, we require that all users assume roles to access the AWS accounts.

We executed the steps above using the `admin` user credentials without using roles.

Now we need to create the roles for the `root` account and update the AWS profile.

__NOTE:__ Update the `TF_VAR_root_account_admin_user_names` variable in `Dockerfile` for the `root` account with your own values.

Execute these commands in the `root` geodesic session:

```
cd iam

Comment out the `assume_role` section in `iam/main.tf`

Run `init-terraform`

Run `terraform plan -target=module.organization_access_group_root`

Run `terraform apply -target=module.organization_access_group_root`

Re-enable the `assume_role` section in `iam/main.tf`
```

Now that we have the `root` role created, update the `root` AWS profile in `~/.aws/config` (again, make sure to change the values to your own):

```
[profile cpco-root-admin]
region=us-west-2
role_arn=arn:aws:iam::323330167063:role/cpco-root-admin
mfa_serial=arn:aws:iam::323330167063:mfa/admin@cloudposse.co
source_profile=cpco

# This profile is required by aws-vault where it stores the Access Key ID and Secret Access Key as explained in Prerequisites
[profile cpco]
```

Exit the `root` `geodesic` shell, run it again and then execute `assume-role`:

```bash
# Run the shell
root.cloudposse.co

# Login to AWS with your MFA device
assume-role
```

You should see the `cpco-root-admin` role assumed:

```
Enter passphrase for /localhost/.ssh/id_rsa:
Identity added: /localhost/.ssh/id_rsa (/localhost/.ssh/id_rsa)
-> Run 'assume-role' to login to AWS
 ⧉  root.cloudposse.co
❌   (none) ~ ➤  assume-role
Enter passphrase to unlock /conf/.awsvault/keys/:
* Assumed role arn:aws:iam::323330167063:role/cpco-root-admin
* Found SSH agent config
 ⧉  root.cloudposse.co
```

### Provision `organization` project for `root`

```bash
cd organization
init-terraform
terraform plan
terraform apply
```

__NOTE:__ If Organization was manually created for the `root` account (from the AWS console), you need to import it (change `o-cas6q267wf` to your organization ID):

```bash
terraform import aws_organizations_organization.default o-cas6q267wf
```


### Provision `accounts` project for `root`

```bash
cd accounts
init-terraform
terraform plan -target=aws_organizations_account.testing
terraform apply -target=aws_organizations_account.testing
```

__NOTE:__ For the purpose of this example, we create only the `testing` account. Use `-target` to add other accounts as needed.

Update the `TF_VAR_testing_account_id` variable in the `root` `Dockerfile`, then rebuild and restart the `root` `geodesic` shell:

```bash
exit
exit
make docker/build
root.cloudposse.co
assume-role
```

### Provision `iam` project in `root` to create IAM Roles for member accounts

Now we have the `testing` account ID and need to finish provisioning the `root` `iam` project.

```bash
cd iam
init-terraform
terraform plan -target=module.organization_access_group_root -target=module.organization_access_group_testing
terraform apply -target=module.organization_access_group_root -target=module.organization_access_group_testing
```

This will create `cpco-testing-admin` group in the `root` account and add the users (specified by `TF_VAR_testing_account_user_names`) to the group.

The group will be granted permissions to assume `OrganizationAccountAccessRole` in the member account (`testing`).

`OrganizationAccountAccessRole` is created automatically by AWS in all member accounts, and it has the administrator permissions to the accounts.

To summarize, now the users from `TF_VAR_testing_account_user_names` will be able to assume `OrganizationAccountAccessRole` and access the `testing` account.

The last thing to do to enable that is to add the `cpco-testing-admin` profile to `~/.aws/config`:

```
[profile cpco-testing-admin]
region=us-west-2
role_arn=arn:aws:iam::126450723953:role/OrganizationAccountAccessRole
mfa_serial=arn:aws:iam::323330167063:mfa/admin@cloudposse.co
source_profile=cpco

[profile cpco-root-admin]
region=us-west-2
role_arn=arn:aws:iam::323330167063:role/cpco-root-admin
mfa_serial=arn:aws:iam::323330167063:mfa/admin@cloudposse.co
source_profile=cpco

# This profile is required by aws-vault where it stores the Access Key ID and Secret Access Key as explained in Prerequisites
[profile cpco]
```

### Provision `root-dns` project in `root` to create `parent` and `root` DNS zones

Now we provision DNS for the `root` account, but without the `testing` Name Servers yet.

They will be provisioned later and then we'll come back to add them.


```bash
cd root-dns
init-terraform
terraform apply -target=aws_route53_zone.parent_dns_zone -target=aws_route53_record.parent_dns_zone_soa -target=aws_route53_zone.root_dns_zone -target=aws_route53_record.root_dns_zone_soa -target=aws_route53_record.root_dns_zone_ns
```

You should see Terraform output similar to this:

```
parent_name_servers = [
    ns-1154.awsdns-16.org,
    ns-1867.awsdns-41.co.uk,
    ns-54.awsdns-06.com,
    ns-704.awsdns-24.net
]
parent_zone_id = ZTNG19A4IP6XF
root_name_servers = [
    ns-1232.awsdns-26.org,
    ns-1785.awsdns-31.co.uk,
    ns-458.awsdns-57.com,
    ns-650.awsdns-17.net
]
root_zone_id = Z3AZCXQQNZKZ7E
```

__NOTE:__ If you did not buy the `parent` domain from Route53, you need to take the `parent` Name Servers from the Terraform output and update them in the registrar.


### Build and Start Geodesic Module for `testing`

Open a new terminal window and execute the following commands:
 
```bash
cd ~/testing.cloudposse.co

# Initialize the project's build-harness
make init

# Build docker image
make docker/build

# Install the wrapper shell
make install

# Run the shell
testing.cloudposse.co

# Login to AWS as the admin user with your MFA device
assume-role
```

You should see the `Docker` image built, `geodesic` shell started, and after you run the `assume-role` command, you will be logged in to the `testing` account:

```
Enter passphrase for /localhost/.ssh/id_rsa:
Identity added: /localhost/.ssh/id_rsa (/localhost/.ssh/id_rsa)
-> Run 'assume-role' to login to AWS
 ⧉  testing.cloudposse.co
❌   (none) ~ ➤  assume-role
Enter passphrase to unlock /conf/.awsvault/keys/:
* Assumed role arn:aws:iam::126450723953:role/OrganizationAccountAccessRole
* Found SSH agent config
 ⧉  testing.cloudposse.co
```


### Provision `tfstate-backend` project for `testing`

Execute this sequence of steps in the `testing` geodesic session:

```
cd tfstate-backend

Comment out the `backend          "s3"             {}` line in `tfstate-backend/main.tf`

Run `init-terraform`

Run `terraform plan` and then `terraform apply`

Re-enable `backend          "s3"             {}` line in `tfstate-backend/main.tf`

Re-run `init-terraform`

Re-run `terraform apply`, answer `yes` when asked to import state

```

Now we have the S3 bucket and DynamoDB table provisioned, and Terraform state stored in the bucket itself.


### Provision `account-dns` project in `testing` to create `testing` DNS zone

In `testing` `geodesic` shell, execute the following commands:

```bash
cd account-dns
init-terraform
terraform apply
```

You should see Terraform output similar to this:

```
name_servers = [
    ns-1416.awsdns-49.org,
    ns-1794.awsdns-32.co.uk,
    ns-312.awsdns-39.com,
    ns-619.awsdns-13.net
]
zone_id = Z3SO0TKDDQ0RGG
```

Take the Name Servers from the output and update them in the `root` `Dockerfile` (variable `TF_VAR_testing_name_servers`).


### Rebuild and restart the `root` `geodesic` shell

Rebuild and restart the `root` `geodesic` shell by executing the following commands:

```bash
exit
exit
make docker/build
root.cloudposse.co
assume-role
```


### Finish provisioning `root-dns` project in `root` to add `testing` Name Servers

__NOTE:__ We use DNS zone delegation since `root` and `testing` are in different AWS accounts

In the `root` `geodesic` shell execute the following commands:

```bash
cd root-dns
init-terraform
terraform apply -target=aws_route53_zone.parent_dns_zone -target=aws_route53_record.parent_dns_zone_soa -target=aws_route53_zone.root_dns_zone -target=aws_route53_record.root_dns_zone_soa -target=aws_route53_record.root_dns_zone_ns -target=aws_route53_record.testing_dns_zone_ns
```

__NOTE:__ DNS for `root` and `testing` should be done at this step.

__NOTE:__ `root` account provisioning should be completed now.


### Provision `acm` project in `testing` to request and validate SSL certificate

In `testing` `geodesic` shell, execute the following commands:

```bash
cd acm
init-terraform
terraform apply
```

You should see Terraform output similar to this:

```
certificate_arn = arn:aws:acm:us-west-2:126450723953:certificate/56897dfe-23ac-4eb3-834d-542505491f09
certificate_domain_name = testing.cloudposse.co
certificate_domain_validation_options = [
    {
        domain_name = testing.cloudposse.co,
        resource_record_name = _21b8879d14986e59b09f8e39d89ecf76.testing.cloudposse.co.,
        resource_record_type = CNAME,
        resource_record_value = _0a592ee754a4b9014464b16d382a129a.acm-validations.aws.
    },
    {
        domain_name = *.testing.cloudposse.co,
        resource_record_name = _21b8879d14986e59b09f8e39d89ecf76.testing.cloudposse.co.,
        resource_record_type = CNAME,
        resource_record_value = _0a592ee754a4b9014464b16d382a129a.acm-validations.aws.
    }
]
certificate_id = arn:aws:acm:us-west-2:126450723953:certificate/56897dfe-23ac-4eb3-834d-542505491f09
```

### Provision `chamber` project in `testing` to create an AIM user and KMS key for chamber

In `testing` `geodesic` shell, execute the following commands:

```bash
cd chamber
init-terraform
terraform apply
```

You should see Terraform output similar to this:

```
chamber_access_key_id = XXXXXXXXXXXXXXXXXXXXXXXX
chamber_kms_key_alias_arn = arn:aws:kms:us-west-2:126450723953:alias/cpco-testing-chamber
chamber_kms_key_alias_name = alias/cpco-testing-chamber
chamber_kms_key_arn = arn:aws:kms:us-west-2:126450723953:key/31a1918c-e194-4f80-bd09-bc6057447902
chamber_kms_key_id = 31a1928c-e094-4e80-bd09-bc6057447902
chamber_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXX
chamber_user_arn = arn:aws:iam::126450723953:user/cpco-testing-chamber-codefresh
chamber_user_name = cpco-testing-chamber-codefresh
chamber_user_unique_id = AIDAJKJKFLZIQ4KDUXAJ2
```

This should conclude the Cold Start process.

Now you'll be able to start a `geodesic` shell for any of the accounts and provision new or update the existing resources.

To provision more resources from the Reference Architecture (e.g. `kops`, `kops-aws-platform`, `kubernetes`, etc.), follow the `README` for the corresponding project:

* [prod](https://github.com/cloudposse/prod.cloudposse.co)
* [staging](https://github.com/cloudposse/staging.cloudposse.co)
* [audit](https://github.com/cloudposse/audit.cloudposse.co)
* [dev](https://github.com/cloudposse/dev.cloudposse.co)
* [testing](https://github.com/cloudposse/testing.cloudposse.co)


### Notes on using multiple AWS accounts

As we described before, we prefer and strongly recommend using multiple AWS accounts and provision a stage per account.

However, in some cases it might be not possible for operational, organizational or other reasons. 

We could have three cases here:

1. We are in control of the master account and can create Organization on top of it and member accounts in it
2. We are given one account (not the master) and we can’t create an Organization. But we can create (or request) more accounts under the same Organization
3. We have only one account in total

All three cases are covered by our Reference Architectures and the Cold Start process described above.

1. This is completely covered by the process description above

2. One of the member accounts will be named `root` and will behave as a root from the DevOps point of view, but not the root of the accounts hierarchy in an Organization.
The other accounts will be named by the stage names (`prod`, `staging`. etc.).
We just don’t provision an Organization.

3. In case of only one account, the `root` will be a virtual root, not the root of the Organization hierarchy.
We still work in a `geodesic` shell per virtual account.
Since we use the `label` pattern, resource naming should not be a problem and will not create any conflicts.
We don’t provision an Organization and member accounts.
In `~/.aws/config` we use profiles with the same names (e.g. `cpco-testing-admin`, `cpco-root-admin`).
The only difference is that in these profiles we use the same account name and don’t use `OrganizationAccountAccessRole`.

For example, instead of this:

```
[profile cpco-testing-admin]
region=us-west-2
role_arn=arn:aws:iam::126450723953:role/OrganizationAccountAccessRole
mfa_serial=arn:aws:iam::323330167063:mfa/admin@cloudposse.co
source_profile=cpco

[profile cpco-root-admin]
region=us-west-2
role_arn=arn:aws:iam::323330167063:role/cpco-root-admin
mfa_serial=arn:aws:iam::323330167063:mfa/admin@cloudposse.co
source_profile=cpco
```

we use this:

```
[profile cpco-testing-admin]
region=us-west-2
role_arn=arn:aws:iam::323330167063:role/cpco-testing-admin
mfa_serial=arn:aws:iam::323330167063:mfa/admin@cloudposse.co
source_profile=cpco

[profile cpco-root-admin]
region=us-west-2
role_arn=arn:aws:iam::323330167063:role/cpco-root-admin
mfa_serial=arn:aws:iam::323330167063:mfa/admin@cloudposse.co
source_profile=cpco
```

From different `geodesic` shells (`root` and `testing`) we will login to the same account under different IAM roles.


## Help

**Got a question?**

File a GitHub [issue](https://github.com/cloudposse/terraform-root-modules/issues), send us an [email](mailto:hello@cloudposse.com) or reach out to us on [Gitter](https://gitter.im/cloudposse/).


## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/terraform-root-modules/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing `terraform-root-modules`, we would love to hear from you! Shoot us an [email](mailto:hello@cloudposse.com).

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull request** so that we can review your changes

**NOTE:** Be sure to merge the latest from "upstream" before making a pull request!


## License

[APACHE 2.0](LICENSE) © 2018 [Cloud Posse, LLC](https://cloudposse.com)

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.


## About

This project is maintained and funded by [Cloud Posse, LLC][website].

![Cloud Posse](https://cloudposse.com/logo-300x69.png)


Like it? Please let us know at <hello@cloudposse.com>

We love [Open Source Software](https://github.com/cloudposse/)!

See [our other projects][community]
or [hire us][hire] to help build your next cloud platform.

  [website]: https://cloudposse.com/
  [community]: https://github.com/cloudposse/
  [hire]: https://cloudposse.com/contact/


## Contributors

| [![Erik Osterman][erik_img]][erik_web]<br/>[Erik Osterman][erik_web] | [![Andriy Knysh][andriy_img]][andriy_web]<br/>[Andriy Knysh][andriy_web] |[![Igor Rodionov][igor_img]][igor_web]<br/>[Igor Rodionov][igor_img]|[![Sarkis Varozian][sarkis_img]][sarkis_web]<br/>[Sarkis Varozian][sarkis_web] |
|-------------------------------------------------------|------------------------------------------------------------------|------------------------------------------------------------------|------------------------------------------------------------------|

[erik_img]: http://s.gravatar.com/avatar/88c480d4f73b813904e00a5695a454cb?s=144
[erik_web]: https://github.com/osterman/
[andriy_img]: https://avatars0.githubusercontent.com/u/7356997?v=4&u=ed9ce1c9151d552d985bdf5546772e14ef7ab617&s=144
[andriy_web]: https://github.com/aknysh/
[igor_img]: http://s.gravatar.com/avatar/bc70834d32ed4517568a1feb0b9be7e2?s=144
[igor_web]: https://github.com/goruha/
[sarkis_img]: https://avatars3.githubusercontent.com/u/42673?s=144&v=4
[sarkis_web]: https://github.com/sarkis/
