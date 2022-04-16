##################################
## Resource Specific Variables ###
##################################

variable "service_name" {
  type        = string
  description = "The name of the service to associate this bucket with"
}

variable "service_function" {
  type        = string
  description = "A name that describes the purpose of this bucket (e.g. sftp-data)"
}

variable "force_destroy" {
  type        = string
  description = "Should we force destroy"
  default     = false
}

variable "principals" {
  type = list(object({
    type            = string
    name            = string
    arn             = string
    attach          = bool
    access_profiles = list(string)
  }))
}

variable "access_profiles" {
  type = map(object({
    effect         = string
    actions        = list(string)
    include_bucket = bool
    prefixes       = list(string)
    condition = list(object({
      test     = string
      variable = string
      values   = list(string)
    }))
  }))
}

variable "kms_key_arn" {
  type    = string
  default = null
}

variable "access_log_retention_days" {
  type        = number
  description = "The number of days to retain access logs for this bucket. Default is 403 days"
  default     = 403
}

#variable "lifecycle_rules" {
#  type        = any
#  description = "List of maps containing configuration of object lifecycle management"
#  default     = []
#}

variable "block_public_acls" {
  type        = bool
  description = "Whether Amazon S3 should block public ACLs for this bucket"
  default     = true
}

variable "block_public_policy" {
  type        = bool
  description = "Whether Amazon S3 should block public bucket policies for this bucket"
  default     = true
}

variable "ignore_public_acls" {
  type        = bool
  description = "Whether Amazon S3 should ignore public ACLs for this bucket"
  default     = true
}

variable "restrict_public_buckets" {
  type        = bool
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
  default     = true
}

variable "notifications" {
  type        = map(object({ filter_prefix : string, filter_suffix : string, events : list(string) }))
  description = "A map of configuration blocks that define the suffixes and prefixes to notify on."
  default     = {}
}