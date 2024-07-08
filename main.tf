provider "aws" {
  region = var.aws_region
}

resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "website-bucket" {
  bucket        = "max-static-website-terra-bucket-dos"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "test-blog" {
  bucket = aws_s3_bucket.website-bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.website-bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "upload_object" {
  for_each     = fileset("html/", "*")
  bucket       = aws_s3_bucket.website-bucket.id
  key          = each.value
  source       = "html/${each.value}"
  etag         = filemd5("html/${each.value}")
  content_type = "text/html"
}
