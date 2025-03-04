#
# let's see what it takes to integrate external data

locals {
  domain_data_location_arns = {
    "bookstore" = "arn:aws:s3:::bookstore20250225101419468000000001/tableau_bookstore_sample/"
  }
  domain_database_names = {
    "bookstore" = "bookstore"
  }
}

resource "aws_lakeformation_resource" "domain_locations" {
  for_each                = local.domain_data_location_arns
  arn                     = each.value
  use_service_linked_role = true
  hybrid_access_enabled   = true
}

resource "aws_glue_catalog_database" "domain_databases" {
  for_each   = local.domain_database_names
  name       = each.value
  catalog_id = local.account_id
}


#
# let's test one...
resource "aws_glue_catalog_table" "bookstore_author" {
  name          = "author"
  database_name = aws_glue_catalog_database.domain_databases["bookstore"].name
  catalog_id    = local.account_id
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://bookstore20250225101419468000000001/tableau_bookstore_sample/author"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    ser_de_info {
      name                  = "OpenCSVSerde"
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"
      parameters = {
        "separatorChar"          = ";"
        "skip.header.line.count" = "1"
      }
    }
    columns {
      name = "authid"
      type = "string"
    }
    columns {
      name = "first name"
      type = "string"
    }
    columns {
      name = "last name"
      type = "string"
    }
    columns {
      name = "birthday"
      type = "string"
    }
    columns {
      name = "country of residence"
      type = "string"
    }
    columns {
      name = "hrs writing per day"
      type = "string"
    }
  }
  parameters = {
    "iac"    = "terraform/minimal-data-platform/platform"
    "domain" = "bookstore"
  }
}

resource "aws_glue_catalog_table" "author_raw" {
  name          = "author_raw"
  database_name = aws_glue_catalog_database.domain_databases["bookstore"].name
  catalog_id    = local.account_id
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://bookstore20250225101419468000000001/tableau_bookstore_sample/author"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    ser_de_info {
      name                  = "dog_walks_raw"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "line.delim" = "\n"
      }
    }
    columns {
      name = "value"
      type = "string"
    }
  }
  parameters = {
    "iac"    = "terraform/minimal-data-platform/platform"
    "domain" = "demo"
  }
}

/*
resource "aws_lakeformation_permissions" "bookstore_database_permissions" {
  for_each = {
    "admin"          = local.sso_lakeformation_admin_role_arn
    # "data_engineers" = "arn:aws:identitystore:::group/${aws_identitystore_group.lakeformation_data_engineers.group_id}"
  }
  permissions = ["DESCRIBE"]
  principal   = each.value
  database {
    name = aws_glue_catalog_database.domain_databases["bookstore"].name
  }
}
*/

/* # hits bug
resource "aws_lakeformation_permissions" "bookstore_table_permissions" {
  for_each = {
    "admin"          = local.sso_lakeformation_admin_role_arn,
    "data_engineers" = local.sso_lakeformation_data_engineer_role_arn
  }
  permissions = ["SELECT"]
  principal   = each.value
  table {
    database_name = aws_glue_catalog_database.domain_databases["bookstore"].name
    name          = aws_glue_catalog_table.author_raw.name
  }
}
*/