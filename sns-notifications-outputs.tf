output "bucket_notification_topic_arn_map" {
  description = "A map of the SNS topic names and arns created by this module."
  value       = zipmap([for key in keys(aws_sns_topic.s3_notify_topic) : key], [for key in keys(aws_sns_topic.s3_notify_topic) : aws_sns_topic.s3_notify_topic[key].arn])
}

output "bucket_notification_kms_arn_map" {
  description = "A map of the SNS topic names and the KMS key arns used to encrypt those topics."
  value       = zipmap([for key in keys(aws_kms_key.s3_notify_kms_key) : key], [for key in keys(aws_kms_key.s3_notify_kms_key) : aws_kms_key.s3_notify_kms_key[key].arn])
}