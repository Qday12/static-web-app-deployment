output "bucket_id" {
  description = "ID of the logging bucket"
  value       = aws_s3_bucket.logs.id
}

output "bucket_arn" {
  description = "ARN of the logging bucket"
  value       = aws_s3_bucket.logs.arn
}

output "bucket_domain_name" {
  description = "Domain name of the logging bucket"
  value       = aws_s3_bucket.logs.bucket_domain_name
}
