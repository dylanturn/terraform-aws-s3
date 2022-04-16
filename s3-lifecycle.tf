#resource "aws_s3_bucket_lifecycle_configuration" "example" {
#  bucket = aws_s3_bucket.service_bucket.bucket
#
#  dynamic "tag" {
#    for_each = var.tags
#
#    content {
#      key   = tag.key
#      value = tag.value
#    }
#  }
#
#  dynamic "rule" {
#    for_each = { for rule in var.lifecycle_rules : lookup(rule, "id") => rule }
#
#    content {
#      id     = lookup(rule.value, "id", null)
#      prefix = lookup(rule.value, "prefix", null)
#      status = title(rule.value)
#
#      dynamic "abort_incomplete_multipart_upload" {
#        for_each = lookup(rule.value, "abort_incomplete_multipart_upload_days", null) == null ? [] : [lookup(rule.value, "abort_incomplete_multipart_upload_days")]
#
#        content {
#          days_after_initiation = abort_incomplete_multipart_upload.value
#        }
#      }
#
#      dynamic "filter"{
#        for_each = [lookup(rule.value, "filter", null)]
#        content {
#
#        }
#      }
#
#
#
#      # Max 1 block - expiration
#      dynamic "expiration" {
#        for_each = length(keys(lookup(rule.value, "expiration", {}))) == 0 ? [] : [lookup(rule.value, "expiration", {})]
#
#        content {
#          date                         = lookup(expiration.value, "date", null)
#          days                         = lookup(expiration.value, "days", null)
#          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
#        }
#      }
#
#      # Several blocks - transition
#      dynamic "transition" {
#        for_each = lookup(rule.value, "transition", [])
#
#        content {
#          date          = lookup(transition.value, "date", null)
#          days          = lookup(transition.value, "days", null)
#          storage_class = transition.value.storage_class
#        }
#      }
#
#      # Max 1 block - noncurrent_version_expiration
#      dynamic "noncurrent_version_expiration" {
#        for_each = length(keys(lookup(rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [lookup(rule.value, "noncurrent_version_expiration", {})]
#
#        content {
#          noncurrent_days = lookup(noncurrent_version_expiration.value, "days", null)
#        }
#      }
#
#      # Several blocks - noncurrent_version_transition
#      dynamic "noncurrent_version_transition" {
#        for_each = lookup(rule.value, "noncurrent_version_transition", [])
#
#        content {
#          noncurrent_days = lookup(noncurrent_version_transition.value, "days", null)
#          storage_class   = lookup(noncurrent_version_transition.value, "storage_class", null)
#        }
#      }
#    }
#  }
#}