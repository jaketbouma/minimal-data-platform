#
# Upload sample data

resource "aws_s3_bucket" "bookstore" {
  bucket_prefix = "bookstore"
  force_destroy = true
  tags = {
    Name = "Sample bookstore data"
    Environment = "Sandbox"
    Source = "https://help.tableau.com/current/pro/desktop/en-us/bookshop_data.htm"
    Domain = "Bookstore Warehouse"
  }
}

resource "aws_s3_object" "csv_files" {
  for_each = fileset("${path.module}/sample_data", "*.csv")
  bucket   = aws_s3_bucket.bookstore.bucket
  key      = "tableau_bookstore_sample/${each.value}"
  source   = "${path.module}/sample_data/${each.value}"
  etag     = filemd5("${path.module}/sample_data/${each.value}")

  tags = {
    Domain = "Bookstore Warehouse"
  }
}