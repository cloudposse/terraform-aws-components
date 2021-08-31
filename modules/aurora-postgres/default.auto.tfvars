enabled = false

name = "pg"

cluster_name = "shared"

secondary_region_enabled = true

region_secondary = "us-west-2"

environment_secondary = "uw2"

deletion_protection = true

storage_encrypted = true

engine = "aurora-postgresql"

engine_mode = "provisioned"

# https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Updates.20180305.html
# https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_UpgradeDBInstance.PostgreSQL.html
# aws rds describe-db-engine-versions --engine aurora-postgresql --query 'DBEngineVersions[].EngineVersion'
engine_version = "12.6"

# engine and cluster family are notoriously hard to find.
# If you know the engine version (example here is "12.4"), use Engine and DBParameterGroupFamily from:
#    aws rds describe-db-engine-versions --engine aurora-postgresql --query "DBEngineVersions[]" | \
#    jq '.[] | select(.EngineVersion == "12.4") |
#       { Engine: .Engine, EngineVersion: .EngineVersion, DBParameterGroupFamily: .DBParameterGroupFamily }'
# For Aurora Postgres 12.4:
# engine: "postgresql"
# cluster_family: "aurora-postgresql12"
cluster_family = "aurora-postgresql12"

cluster_size = 1

cluster_type = "global"

admin_user = "postgres"

admin_password = ""

iam_database_authentication_enabled = false

db_name = "postgres"

db_port = 5432

# https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html
# smallest r5
instance_type = "db.r5.large"

# Allow Spacelift (or anything in the `automation` account private subnets) to access the cluster
allowed_cidr_blocks = [
  "10.96.0.0/18",
  "10.96.64.0/18",
]

skip_final_snapshot = false

# Creating read-only users or additional databases requires Spacelift
read_only_users_enabled = false

# strong dm

sdm_enabled = false

sdm_ssm_account = "network"

sdm_ssm_region = "us-east-2"

# ignore required vars

subnets = null
vpc_id  = null
