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

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules

    content {
      id                                     = lookup(lifecycle_rule.value, "id", null)
      prefix                                 = lookup(lifecycle_rule.value, "prefix", null)
      tags                                   = lookup(lifecycle_rule.value, "tags", null)
      abort_incomplete_multipart_upload_days = lookup(lifecycle_rule.value, "abort_incomplete_multipart_upload_days", null)
      enabled                                = lifecycle_rule.value.enabled

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "expiration", {})]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "noncurrent_version_expiration", {})]

        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", [])

        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }
    }
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