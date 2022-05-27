# This file is included by default in terraform plans

enabled = false

database_grants = ["MODIFY", "MONITOR", "USAGE"]
schema_grants   = ["MODIFY", "MONITOR", "USAGE", "CREATE TABLE", "CREATE VIEW"]
table_grants    = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES"]
view_grants     = ["SELECT", "REFERENCES"]
