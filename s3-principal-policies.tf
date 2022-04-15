locals {
  # [[role_name, access_profile], ...]
  attachment_chunks = chunklist(flatten([for data in var.principals : (data.attach ? setproduct([data.name], data.access_profiles) : [])]), 2)
  attachments = [
    for chunk in local.attachment_chunks :
    {
      role_name      = chunk[0]
      access_profile = chunk[1]
    }
  ]
}

resource "aws_iam_role_policy_attachment" "services" {
  count = length(local.attachments)

  role       = local.attachments[count.index]["role_name"]
  policy_arn = aws_iam_policy.services[local.attachments[count.index]["access_profile"]].arn
}

resource "aws_iam_policy" "services" {
  for_each = var.access_profiles

  name_prefix = "${var.service_name}-${var.service_function}-${replace(each.key, "_", "-")}-"
  policy      = data.aws_iam_policy_document.services[each.key].json
}

data "aws_iam_policy_document" "services" {
  for_each = var.access_profiles

  statement {
    actions   = each.value.actions
    effect    = each.value.effect
    resources = concat((each.value.include_bucket ? [aws_s3_bucket.service_bucket.arn] : []), [for prefix in each.value.prefixes : "${aws_s3_bucket.service_bucket.arn}${prefix}"])

    dynamic "condition" {
      for_each = each.value.condition

      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}