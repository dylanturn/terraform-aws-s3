##################################
#### Organization Information ####
##################################

variable "account_id" {
  type        = string
  description = "The ID of this account"
}

variable "organization_name" {
  type = string
  description = "The name of the organization this bucket is being previsioned for"
}

variable "region" {
  type        = string
  description = "The region this service instance is being created in"
}

variable "environment" {
  type        = string
  description = "The environment this service instance is being created in"
}

variable "tags" {
  type        = map(string)
  description = "Extra tags to include with the resources created by this module"
  default     = {}
}