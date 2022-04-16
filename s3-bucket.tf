resource "aws_s3_bucket" "service_bucket" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy
  tags = merge({
    name       = local.bucket_name,
    log_target = var.access_log_bucket
    },
  local.resource_tags)

  lifecycle {
    ignore_changes = [
      bucket
    ]
  }
}

resource "aws_s3_bucket_acl" "service_bucket_acl" {
  bucket = aws_s3_bucket.service_bucket.bucket
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "service_bucket_versioning" {
  bucket = aws_s3_bucket.service_bucket.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "service_bucket_encryption_configuration" {
  bucket = aws_s3_bucket.service_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "service_bucket_logging" {
  count = var.access_log_bucket == null ? 0 : 1

  bucket                = aws_s3_bucket.service_bucket.bucket
  expected_bucket_owner = var.account_id

  target_bucket = var.access_log_bucket
  target_prefix = var.access_log_prefix == null ? "s3/" : "s3/${var.access_log_prefix}/"
}