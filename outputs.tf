
output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = module.cloudfront.distribution_id
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = module.cloudfront.distribution_arn
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.cloudfront.domain_name
}

output "website_url" {
  description = "The full HTTPS URL of the website"
  value       = "https://${module.cloudfront.domain_name}"
}

output "s3_bucket_id" {
  description = "The name of the S3 bucket"
  value       = module.s3_static_website.bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.s3_static_website.bucket_arn
}
