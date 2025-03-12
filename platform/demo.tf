#
# Some demo data to test glue setup
resource "aws_glue_catalog_database" "demo" {
  name        = "demo"
  catalog_id  = local.account_id
  description = "Some play play data"
}

/*
resource "aws_lakeformation_permissions" "demo" {
  permissions = ["DESCRIBE"]
  principal   = "703671920730"
  database {
    name = aws_glue_catalog_database.demo.name
  }
}*/

/*
resource "aws_lakeformation_permissions" "demo__dog_walks" {
  permissions = ["ALL"]
  principal   = "arn:aws:identitystore:::group/${aws_identitystore_group.lakeformation_data_engineers.group_id}"
  database {
    name = aws_glue_catalog_database.demo.name
  }
}*/

# this wokrs...
# aws lakeformation grant-permissions --principal DataLakePrincipalIdentifier=arn:aws:identitystore:::group/b0cc49ec-1091-704b-30c0-fb9457005b07 --resource '{ "Database": {"Name":"demo"}}' --permissions "ALL" --profile platform

resource "aws_s3_bucket" "demo" {
  bucket_prefix = "demo-data"
  force_destroy = true
  tags = {
    Name        = "My demo data"
    Environment = "Sandbox"
  }
}

resource "aws_lakeformation_resource" "demo" {
  arn                     = aws_s3_bucket.demo.arn
  use_service_linked_role = true
  hybrid_access_enabled   = true
}

resource "aws_s3_object" "dog_walks" {
  bucket  = aws_s3_bucket.demo.bucket
  key     = "/dog_walks/data.json"
  content = <<EOF
  {"date": "2023-10-01", "duration": 30, "distance": 2.5}
  {"date": "2023-10-02", "duration": 45, "distance": 3.0}
  {"date": "2023-10-03", "duration": 20, "distance": 1.5}
  {"date": "2023-10-04", "duration": 50, "distance": 4.0}
  {"date": "2023-10-05", "duration": 35, "distance": 2.8}
EOF

  tags = {
    Name = "Dog Walks Data"
  }
}

resource "aws_glue_catalog_table" "dog_walks" {
  name          = "dog_walks"
  database_name = aws_glue_catalog_database.demo.name
  catalog_id    = local.account_id
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.demo.bucket}/dog_walks"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    ser_de_info {
      name                  = "dog_walks"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
      parameters = {
        paths = "date,duration,distance"
      }
    }
    columns {
      name = "date"
      type = "string"
    }
    columns {
      name = "duration"
      type = "int"
    }
    columns {
      name = "distance"
      type = "double"
    }
  }
  parameters = {
    "raw"    = aws_glue_catalog_table.dog_walks_raw.id
    "iac"    = "terraform/minimal-data-platform/platform"
    "domain" = "demo"
  }
}
resource "aws_glue_catalog_table" "dog_walks_raw" {
  name          = "dog_walks_raw"
  database_name = aws_glue_catalog_database.demo.name
  catalog_id    = local.account_id
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.demo.bucket}/dog_walks"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    ser_de_info {
      name                  = "dog_walks_raw"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        #"field.delim" = ","
        #"escape.delim" = "\\"
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


# https://github.com/hashicorp/terraform-provider-aws/issues/21539
# open issue...
/*
resource "aws_lakeformation_permissions" "dog_walks" {
  principal   = "arn:aws:identitystore:::group/${aws_identitystore_group.lakeformation_data_engineers.group_id}"
  permissions = ["SELECT"]

  table {
    name          = aws_glue_catalog_table.dog_walks.name
    database_name = aws_glue_catalog_table.dog_walks.database_name
    catalog_id    = aws_glue_catalog_table.dog_walks.catalog_id
  }
}*/