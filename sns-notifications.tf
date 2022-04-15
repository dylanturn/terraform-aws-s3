resource "aws_kms_key" "s3_notify_kms_key" {
  for_each    = var.notifications
  description = "KMS Key for encrypting this buckets SNS notification topics"
  policy      = data.aws_iam_policy_document.s3_notify_topic_kms_key_policy_document[each.key].json
  tags        = local.resource_tags
}

data "aws_iam_policy_document" "s3_notify_topic_kms_key_policy_document" {
  for_each = var.notifications
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
      "kms:Decrypt"
    ]
    # The * doesn't mean ANY KMS key, it just means the KMS key this policy is attached to.
    resources = [
      "*"
    ]
  }
}

resource "aws_sns_topic" "s3_notify_topic" {
  for_each          = var.notifications
  name_prefix       = "${var.service_name}-${each.key}-notify-"
  kms_master_key_id = aws_kms_key.s3_notify_kms_key[each.key].id
  tags              = local.resource_tags
}

# Binds the topic policy document below to the topic above in order to avoid circular dependencies.
resource "aws_sns_topic_policy" "s3_notify_topic_policy" {
  for_each = var.notifications
  arn      = aws_sns_topic.s3_notify_topic[each.key].arn
  policy   = data.aws_iam_policy_document.s3_notify_topic_policy_document[each.key].json
}

data "aws_iam_policy_document" "s3_notify_topic_policy_document" {
  for_each  = var.notifications
  policy_id = "__s3_notification_policy"
  statement {
    sid    = "__s3_notification_publish"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [var.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:s3:::${aws_s3_bucket.service_bucket.bucket}"]
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.s3_notify_topic[each.key].arn]
  }


  statement {
    sid    = "__s3_notification_subscribe"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        var.account_id,
      ]
    }
    actions = [
      "sns:Subscribe",
      "sns:Receive"
    ]
    resources = [
      aws_sns_topic.s3_notify_topic[each.key].arn
    ]
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  for_each = var.notifications
  bucket   = aws_s3_bucket.service_bucket.bucket
  topic {
    topic_arn     = aws_sns_topic.s3_notify_topic[each.key].arn
    events        = each.value.events
    filter_prefix = each.value.filter_prefix
    filter_suffix = each.value.filter_suffix
  }
}