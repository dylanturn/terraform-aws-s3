### Service Bucket Policies ###
resource "aws_s3_bucket_policy" "bucket_policy" {
  # This count exists because if we don't specify access_profiles or principals then Terraform will attempt to set the bucket policy to null.
  count      = length(var.access_profiles) > 0 ? 1 : 0
  bucket     = aws_s3_bucket.service_bucket.bucket
  policy     = data.aws_iam_policy_document.bucket.json
  depends_on = [aws_s3_bucket_public_access_block.service_bucket_public_access_block]
}

data "aws_iam_policy_document" "bucket" {
  dynamic "statement" {
    for_each = var.access_profiles

    content {
      actions = statement.value.actions
      effect  = statement.value.effect

      resources = concat((statement.value.include_bucket ? [aws_s3_bucket.service_bucket.arn] : []), [for prefix in statement.value.prefixes : "${aws_s3_bucket.service_bucket.arn}${prefix}"])

      dynamic "principals" {
        for_each = {
          for data in var.principals :
          data.name => data if contains(data.access_profiles, statement.key)
        }
        content {
          type        = principals.value["type"]
          identifiers = [principals.value["arn"]]
        }
      }

      dynamic "condition" {
        for_each = statement.value.condition

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "service_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.service_bucket.bucket
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
  depends_on              = [aws_s3_bucket.service_bucket]
}

resource "aws_iam_policy" "service_bucket_kms_policy" {
  count       = var.kms_key_arn == null ? 1 : 0
  name_prefix = "${var.service_name}-${var.service_function}-kms-policy-"
  policy      = data.aws_iam_policy_document.service_bucket_kms_policy_document[0].json
}

data "aws_iam_policy_document" "service_bucket_kms_policy_document" {
  count = var.kms_key_arn == null ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]
    resources = [
      aws_kms_key.service_bucket_key[0].arn
    ]
  }
}