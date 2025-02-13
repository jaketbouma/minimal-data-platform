#
# Some demo data to test glue setup


resource "aws_s3_bucket" "demo" {
  bucket_prefix = "demo-data"
  force_destroy = true
  tags = {
    Name = "My demo data"
    Environment = "Sandbox"
  }
}

resource "aws_s3_object" "dog_walks" {
  bucket = aws_s3_bucket.demo.bucket
  key    = "dog_walks.json"
  content = <<EOF
[
  {"date": "2023-10-01", "duration": 30, "distance": 2.5},
  {"date": "2023-10-02", "duration": 45, "distance": 3.0},
  {"date": "2023-10-03", "duration": 20, "distance": 1.5},
  {"date": "2023-10-04", "duration": 50, "distance": 4.0},
  {"date": "2023-10-05", "duration": 35, "distance": 2.8}
]
EOF

  tags = {
    Name = "Dog Walks Data"
  }
}

resource "aws_glue_catalog_table" "dog_walks" {
  name = "dog_walks"
  database_name = aws_glue_catalog_database.platform.name
  catalog_id = local.account_id
  table_type = "EXTERNAL_TABLE"
  parameters = {
    EXTERNAL = "TRUE"
  }
  storage_descriptor {
    location = aws_s3_bucket.demo.bucket
    input_format = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    ser_de_info {
      name = "dog_walks"
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
}
