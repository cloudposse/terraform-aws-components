
# This file creates a table for Athena to query centralized Cloudtrail logs in S3.
# https://docs.aws.amazon.com/athena/latest/ug/cloudtrail-logs.html#create-cloudtrail-table-ct

locals {
  cloudtrail_enabled    = module.this.enabled && length(var.cloudtrail_database) > 0
  cloudtrail_table_name = "%s_cloudtrail_logs"

  # s3://cloudtrail_bucket_name/AWSLogs/organization_id/Account_ID/CloudTrail/
  organization_id         = module.account_map.outputs.org.id
  cloudtrail_s3_bucket_id = module.cloudtrail_bucket[0].outputs.cloudtrail_bucket_id
  cloudtrail_s3_location  = "s3://${local.cloudtrail_s3_bucket_id}/AWSLogs/${local.organization_id}/%s/CloudTrail/"

  cloudtrail_query_create_table = <<EOT
CREATE EXTERNAL TABLE ${local.cloudtrail_table_name} (
eventversion STRING,
useridentity STRUCT<
               type:STRING,
               principalid:STRING,
               arn:STRING,
               accountid:STRING,
               invokedby:STRING,
               accesskeyid:STRING,
               userName:STRING,
  sessioncontext:STRUCT<
    attributes:STRUCT<
               mfaauthenticated:STRING,
               creationdate:STRING>,
    sessionissuer:STRUCT<
               type:STRING,
               principalId:STRING,
               arn:STRING,
               accountId:STRING,
               userName:STRING>,
    ec2RoleDelivery:string,
    webIdFederationData:map<string,string>
  >
>,
eventtime STRING,
eventsource STRING,
eventname STRING,
awsregion STRING,
sourceipaddress STRING,
useragent STRING,
errorcode STRING,
errormessage STRING,
requestparameters STRING,
responseelements STRING,
additionaleventdata STRING,
requestid STRING,
eventid STRING,
resources ARRAY<STRUCT<
               arn:STRING,
               accountid:STRING,
               type:STRING>>,
eventtype STRING,
apiversion STRING,
readonly STRING,
recipientaccountid STRING,
serviceeventdetails STRING,
sharedeventid STRING,
vpcendpointid STRING,
tlsDetails struct<
  tlsVersion:string,
  cipherSuite:string,
  clientProvidedHostHeader:string>
)
PARTITIONED BY (account string, region string, year string, month string, day string)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS INPUTFORMAT 'com.amazon.emr.cloudtrail.CloudTrailInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION '${local.cloudtrail_s3_location}'
EOT


  account_name  = lookup(module.this.descriptors, "account_name", module.this.stage)
  account_id    = module.account_map.outputs.full_account_map[local.account_name]
  timestamp     = timestamp()
  current_year  = formatdate("YYYY", local.timestamp)
  current_month = formatdate("MM", local.timestamp)
  current_day   = formatdate("DD", local.timestamp)

  cloudtrail_query_alter_table = <<EOT
ALTER TABLE ${local.cloudtrail_table_name} ADD
PARTITION (account='${local.account_id}',
region='${var.region}',
year='${local.current_year}',
month='${local.current_month}',
day='${local.current_day}')
LOCATION '${local.cloudtrail_s3_location}'
EOT
}


resource "aws_athena_named_query" "cloudtrail_query_create_tables" {
  for_each = local.cloudtrail_enabled ? module.account_map.outputs.full_account_map : {}

  name      = "cloudtrail_query_create_table_${each.key}"
  workgroup = module.athena.workgroup_id
  database  = var.cloudtrail_database
  query     = format(local.cloudtrail_query_create_table, replace(each.key, "-", "_"), each.value)
}

resource "aws_athena_named_query" "cloudtrail_query_alter_tables" {
  for_each = local.cloudtrail_enabled ? module.account_map.outputs.full_account_map : {}

  name      = "cloudtrail_query_alter_table_${each.key}"
  workgroup = module.athena.workgroup_id
  database  = var.cloudtrail_database
  query     = format(local.cloudtrail_query_alter_table, replace(each.key, "-", "_"), each.value)
}
