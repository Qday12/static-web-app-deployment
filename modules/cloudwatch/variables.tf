variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for metrics"
  type        = string
}

variable "waf_web_acl_name" {
  description = "WAF Web ACL name for metrics"
  type        = string
}
