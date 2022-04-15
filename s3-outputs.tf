output "name" {
  description = "The name of the bucket this bucket logs to"
  value       = aws_s3_bucket.service_bucket.bucket
}

output "id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.service_bucket.id
}

output "arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = aws_s3_bucket.service_bucket.arn
}

output "region" {
  description = "The AWS region this bucket resides in."
  value       = aws_s3_bucket.service_bucket.region
}

output "bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       = aws_s3_bucket.service_bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The regional domain name for this service bucket"
  value       = aws_s3_bucket.service_bucket.bucket_regional_domain_name
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt this bucket."
  value       = local.kms_key_arn
}

output "kms_policy_arn" {
  description = "The ARN of the IAM policy needed to use this S3 buckets KMS key."
  value       = length(aws_iam_policy.service_bucket_kms_policy) == 0 ? null : aws_iam_policy.service_bucket_kms_policy[0].arn
}