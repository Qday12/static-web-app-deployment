
variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Name of the project, used for resource naming and tagging"
  type        = string
  default     = "static-web-app-deployment"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for static website hosting."
  type        = string
}

variable "website_index_document" {
  description = "The index document for the static website"
  type        = string
  default     = "index.html"
}

variable "website_error_document" {
  description = "The error document for the static website"
  type        = string
  default     = "error.html"
}

variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}
