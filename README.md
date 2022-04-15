# terraform-aws-s3
Terraform module for deploying appropriately configured and secured AWS S3 resources

## Service Bucket
* Creates an encrypted s3 bucket
* Includes a policy to block and ignore all public access points

## Access-Log Bucket
* Creates an encrypted s3 access logging bucket
* Creates a rule that moves log objects to cheaper storage after 7 days
* Makes objects in the bucket read-only for 13months (403 days) when they're created
* Deletes access log objects after 13months and a day
* Includes a policy to block and ignore all public access points

```
principals = [
  {
    type            = "AWS"
    name            = "asdf-roke-name"
    arn             = "asdf-roke-arn"
    attach          = true
    access_profiles = ["bucket_read", "object_read", "object_write"]
  }
]

access_profiles = {
  "bucket_read" = {
    effect = "Allow"
    actions = [
      "s3:ListBucketVersions",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    include_bucket = true
    prefixes       = []
    condition      = []
  }
  "object_read" = {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersion",
      "s3:GetObjectAcl",
      "s3:GetObject"
    ],
    include_bucket = false
    prefixes       = ["/*"]
    condition      = []
  }
  "object_write" = {
    effect = "Allow"
    actions = [
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:DeleteObjectVersion",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload"
    ]
    include_bucket = false
    prefixes       = ["/*"]
    condition      = []
  }
}
```