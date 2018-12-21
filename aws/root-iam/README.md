# root-iam

This module is responsible for settnig up the access groups in the root account. 

If provisioning this during a cold-start process, make sure you first provision a temporary [`bootstrap`](../bootstrap) role and set your `TF_VAR_aws_assume_role_arn=bootstrap`.
