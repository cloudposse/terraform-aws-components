# Database Migration Service requires
# the below IAM Roles to be created before
# replication instances can be created.
# The roles should be provisioned only once per account.
# https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Security.html
# https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Security.html#CHAP_Security.APIRole
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_instance
#  * dms-vpc-role
#  * dms-cloudwatch-logs-role
#  * dms-access-for-endpoint

module "dms_iam" {
  source  = "cloudposse/dms/aws//modules/dms-iam"
  version = "0.1.1"

  context = module.this.context
}
