locals {
  kms_key_arn = var.kms_key_arn == null ? aws_kms_key.service_bucket_key[0].arn : var.kms_key_arn
}

resource "aws_kms_grant" "key_grant" {
  count             = length(var.principals)
  grantee_principal = var.principals[count.index]["arn"]
  key_id            = local.kms_key_arn
  operations = [
    "GenerateDataKey",
    "Decrypt",
    "Encrypt"
  ]
}

resource "aws_kms_key" "service_bucket_key" {
  count       = (var.kms_key_arn == null) ? 1 : 0
  description = "This key is used to encrypt bucket objects for ${local.bucket_name}"
  policy      = data.aws_iam_policy_document.service_bucket_key_policy_document.json
  tags        = local.resource_tags
}

data "aws_iam_policy_document" "service_bucket_key_policy_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "s3.amazonaws.com"
      ]
    }
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:Encrypt"
    ]
    # The * doesn't mean ANY KMS key, it just means the KMS key this policy is attached to.
    resources = [
      "*"
    ]
  }

  dynamic "statement" {
    for_each = var.principals
    content {
      effect = "Allow"
      actions = [
        "GenerateDataKey",
        "Decrypt",
        "Encrypt"
      ]
      resources = [
        "*"
      ]
      principals {
        type = statement.value["type"]
        identifiers = [
          statement.value["arn"]
        ]
      }
    }
  }
}