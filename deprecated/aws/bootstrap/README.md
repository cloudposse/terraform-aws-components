# bootstrap

This module provisions an AWS user along with a bootstrap role suitable for bootstrapping an AWS multi-account architecture as found in our [reference architectures](https://github.com/cloudposse/reference-architecutres). 

These user and role are intended to be used as a **temporary fixture** and should be deprovisioned after all accounts have been provisioned in order to maintain a secure environment.

__WARNING:__ This module grants `AdministrativeAccess` in the current account along with the `OrganizationAccountAccessRole` to all `accounts_enabled` **without MFA**. We repeat, this module should *only* be used during the bootstrapping phase when provisioning your infrastructure for the first time.
