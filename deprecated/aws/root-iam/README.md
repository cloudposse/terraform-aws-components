# root-iam

This module is responsible for setting up the access groups in the root account. 

If provisioning this during a cold-start process, make sure you have `TF_VAR_aws_assume_role_arn` set to nil.
