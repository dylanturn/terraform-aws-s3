
locals {
  bucket_name        = "${var.organization_name}-${var.environment}-${var.service_name}-${var.service_function}.${lookup(local.region_abbrs, var.region, null)}"
  resource_tags = merge(
    map(
      "service", var.service_name,
      "environment", var.environment,
      "terraform-module", "terraform-aws-s3"
    ),
    var.tags
  )

  ### TODO: Come up with a nicer way to store these kinds of constants
  region_abbrs = map(
    "us-east-1", "use1",       # US East (N. Virginia)
    "us-east-2", "use2",       # US East (Ohio)
    "us-west-1", "usw1",       # US West (N. California)
    "us-west-2", "usw2",       # US West (Oregon)
    "af-south-1", "afs1",      # Africa (Cape Town)
    "ap-east-1", "ape1",       # Asia Pacific (Hong Kong)
    "ap-south-1", "aps1",      # Asia Pacific (Mumbai)
    "ap-northeast-3", "apne3", # Asia Pacific (Osaka-Local)
    "ap-northeast-2", "apne2", # Asia Pacific (Seoul)
    "ap-northeast-1", "apne1", # Asia Pacific (Tokyo)
    "ap-southeast-1", "apse1", # Asia Pacific (Singapore)
    "ap-southeast-2", "apse2", # Asia Pacific (Sydney)
    "ca-central-1", "cac1",    # Canada (Central)
    "cn-north-1", "cnn1",      # China (Beijing)
    "cn-northwest-1", "cnnw1", # China (Ningxia)
    "eu-central-1", "euc1",    # Europe (Frankfurt)
    "eu-west-1", "euw1",       # Europe (Ireland)
    "eu-west-2", "euw2",       # Europe (London)
    "eu-south-1", "eus1",      # Europe (Milan)
    "eu-west-3", "euw3",       # Europe (Paris)
    "eu-north-1", "eun1",      # Europe (Stockholm)
    "me-south-1", "mes1",      # Middle East (Bahrain)
    "sa-east-1", "sae1",       # South America (São Paulo)
    "us-gov-east-1", "usge1",  # AWS GovCloud (US-East)
    "us-gov-west-1", "usgw1"   # AWS GovCloud (US)
  )
}