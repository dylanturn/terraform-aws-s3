#############################
#### Logging Information ####
#############################

variable "access_log_prefix" {
  type        = string
  description = "The prefix access logs for this bucket will be stored under"
  default     = null
}
variable "access_log_bucket" {
  type        = string
  description = "The ARN of the S3 access log bucket to use for S3 access logs"
}