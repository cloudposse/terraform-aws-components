variable "region" {
  type        = string
  description = "AWS Region"
}

variable "catalog_table_name" {
  type        = string
  description = "Name of the table"
  default     = null
}

variable "catalog_table_description" {
  type        = string
  description = "Description of the table"
  default     = null
}

variable "catalog_id" {
  type        = string
  description = "ID of the Glue Catalog and database to create the table in. If omitted, this defaults to the AWS Account ID plus the database name"
  default     = null
}

variable "owner" {
  type        = string
  description = "Owner of the table"
  default     = null
}

variable "parameters" {
  type        = map(string)
  description = "Properties associated with this table, as a map of key-value pairs"
  default     = null
}

variable "partition_index" {
  type = object({
    index_name = string
    keys       = list(string)
  })
  description = "Configuration block for a maximum of 3 partition indexes"
  default     = null
}

variable "partition_keys" {
  #  type = object({
  #    comment = string
  #    name    = string
  #    type    = string
  #  })
  # Using `type = map(string)` since some of the the fields are optional and we don't want to force the caller to specify all of them and set to `null` those not used
  type        = map(string)
  description = "Configuration block of columns by which the table is partitioned. Only primitive types are supported as partition keys"
  default     = null
}

variable "retention" {
  type        = number
  description = "Retention time for the table"
  default     = null
}

variable "table_type" {
  type        = string
  description = "Type of this table (`EXTERNAL_TABLE`, `VIRTUAL_VIEW`, etc.). While optional, some Athena DDL queries such as `ALTER TABLE` and `SHOW CREATE TABLE` will fail if this argument is empty"
  default     = null
}

variable "target_table" {
  type = object({
    catalog_id    = string
    database_name = string
    name          = string
  })
  description = "Configuration block of a target table for resource linking"
  default     = null
}

variable "view_expanded_text" {
  type        = string
  description = "If the table is a view, the expanded text of the view; otherwise null"
  default     = null
}

variable "view_original_text" {
  type        = string
  description = "If the table is a view, the original text of the view; otherwise null"
  default     = null
}

variable "storage_descriptor" {
  #  type = object({
  #    # List of reducer grouping columns, clustering columns, and bucketing columns in the table
  #    bucket_columns = list(string)
  #    # Configuration block for columns in the table
  #    columns = list(object({
  #      comment    = string
  #      name       = string
  #      parameters = map(string)
  #      type       = string
  #    }))
  #    # Whether the data in the table is compressed
  #    compressed = bool
  #    # Input format: SequenceFileInputFormat (binary), or TextInputFormat, or a custom format
  #    input_format = string
  #    # Physical location of the table. By default this takes the form of the warehouse location, followed by the database location in the warehouse, followed by the table name
  #    location = string
  #    #  Must be specified if the table contains any dimension columns
  #    number_of_buckets = number
  #    # Output format: SequenceFileOutputFormat (binary), or IgnoreKeyTextOutputFormat, or a custom format
  #    output_format = string
  #    # User-supplied properties in key-value form
  #    parameters = map(string)
  #    # Object that references a schema stored in the AWS Glue Schema Registry
  #    # When creating a table, you can pass an empty list of columns for the schema, and instead use a schema reference
  #    schema_reference = object({
  #      # Configuration block that contains schema identity fields. Either this or the schema_version_id has to be provided
  #      schema_id = object({
  #        # Name of the schema registry that contains the schema. Must be provided when schema_name is specified and conflicts with schema_arn
  #        registry_name = string
  #        # ARN of the schema. One of schema_arn or schema_name has to be provided
  #        schema_arn = string
  #        # Name of the schema. One of schema_arn or schema_name has to be provided
  #        schema_name = string
  #      })
  #      # Unique ID assigned to a version of the schema. Either this or the schema_id has to be provided
  #      schema_version_id     = string
  #      schema_version_number = number
  #    })
  #    # Configuration block for serialization and deserialization ("SerDe") information
  #    ser_de_info = object({
  #      # Name of the SerDe
  #      name = string
  #      # Map of initialization parameters for the SerDe, in key-value form
  #      parameters = map(string)
  #      # Usually the class that implements the SerDe. An example is org.apache.hadoop.hive.serde2.columnar.ColumnarSerDe
  #      serialization_library = string
  #    })
  #    # Configuration block with information about values that appear very frequently in a column (skewed values)
  #    skewed_info = object({
  #      # List of names of columns that contain skewed values
  #      skewed_column_names = list(string)
  #      # List of values that appear so frequently as to be considered skewed
  #      skewed_column_value_location_maps = list(string)
  #      # Map of skewed values to the columns that contain them
  #      skewed_column_values = map(string)
  #    })
  #    # Configuration block for the sort order of each bucket in the table
  #    sort_columns = object({
  #      # Name of the column
  #      column = string
  #      # Whether the column is sorted in ascending (1) or descending order (0)
  #      sort_order = number
  #    })
  #    # Whether the table data is stored in subdirectories
  #    stored_as_sub_directories = bool
  #  })

  # Using `type = any` since some of the the fields are optional and we don't want to force the caller to specify all of them and set to `null` those not used
  type        = any
  description = "Configuration block for information about the physical storage of this table"
  default     = null
}

variable "glue_iam_component_name" {
  type        = string
  description = "Glue IAM component name. Used to get the Glue IAM role from the remote state"
  default     = "glue/iam"
}

variable "glue_catalog_database_component_name" {
  type        = string
  description = "Glue catalog database component name where the table metadata resides. Used to get the Glue catalog database from the remote state"
}

variable "lakeformation_permissions_enabled" {
  type        = bool
  description = "Whether to enable adding Lake Formation permissions to the IAM role that is used to access the Glue table"
  default     = true
}

variable "lakeformation_permissions" {
  type        = list(string)
  description = "List of permissions granted to the principal. Refer to https://docs.aws.amazon.com/lake-formation/latest/dg/lf-permissions-reference.html for more details"
  default     = ["ALL"]
}
