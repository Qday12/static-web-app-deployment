
variable "s3_bucket_id" {
  description = "The ID of the S3 bucket to use as origin"
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket"
  type        = string
}

variable "default_root_object" {
  description = "The default root object"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "The price class for the CloudFront distribution"
  type        = string
  default     = "PriceClass_100"
}

variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "min_ttl" {
  description = "Minimum TTL for cached objects"
  type        = number
  default     = 0
}

variable "default_ttl" {
  description = "Default TTL for cached objects"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum TTL for cached objects"
  type        = number
  default     = 86400
}
