#
# Upload sample data
resource "aws_s3_bucket" "bookstore" {
  bucket_prefix = "bookstore"
  force_destroy = true
  tags = {
    Name        = "Sample bookstore data"
    Environment = "Sandbox"
    Source      = "https://help.tableau.com/current/pro/desktop/en-us/bookshop_data.htm"
    Domain      = "Bookstore Warehouse"
  }
}

data "aws_iam_policy_document" "bookstore_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.lake_formation_data_access_role_arn]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.bookstore.arn}",
      "${aws_s3_bucket.bookstore.arn}/*"
    ]
  }
}


resource "aws_s3_bucket_policy" "bookstore_policy" {
  bucket = aws_s3_bucket.bookstore.id
  policy = data.aws_iam_policy_document.bookstore_policy.json
}

locals {
  bookstore_csv_files = {
    for file in fileset("${path.module}/sample-data", "*.csv") :
    lower(replace(split(".", file)[0], " ", "_")) => file
  }
}
resource "aws_s3_object" "csv_files" {
  for_each = local.bookstore_csv_files
  bucket   = aws_s3_bucket.bookstore.bucket
  key      = "tableau_bookstore_sample/${each.key}/${each.value}"
  source   = "${path.module}/sample-data/${each.value}"
  etag     = filemd5("${path.module}/sample-data/${each.value}")

  tags = {
    Domain = "Bookstore Warehouse"
  }
}