
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
