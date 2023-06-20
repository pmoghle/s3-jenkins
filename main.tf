provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = var.bucket_name
  acl    = "private"

  lifecycle {
    prevent_destroy = false
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = aws_s3_bucket.logs_bucket.id
    target_prefix = "logs/"
  }

  # Set up bucket policy to allow access from whitelisted IPs
  resource "aws_s3_bucket_policy" "bucket_policy" {
    bucket = aws_s3_bucket.example_bucket.id

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowIPs",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.example_bucket.id}",
        "arn:aws:s3:::${aws_s3_bucket.example_bucket.id}/*"
      ],
      "Condition": {
        "NotIpAddress": {
          "aws:SourceIp": ["${var.whitelisted_ips}"]
        }
      }
    }
  ]
}
EOF
  }
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket = var.logs_bucket_name
  acl    = "log-delivery-write"

  lifecycle {
    prevent_destroy = false
  }
}

