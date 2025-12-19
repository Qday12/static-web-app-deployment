
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      {
        Project     = var.project_name
        Environment = var.environment
        ManagedBy   = "terraform"
      },
      var.default_tags
    )
  }
}
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = merge(
      {
        Project     = var.project_name
        Environment = var.environment
        ManagedBy   = "terraform"
      },
      var.default_tags
    )
  }
}

# S3
module "s3_static_website" {
  source = "./modules/s3-static-website"

  bucket_name            = var.bucket_name
  website_index_document = var.website_index_document
  website_error_document = var.website_error_document
}

# WAF
module "waf" {
  source = "./modules/waf"
  providers = {
    aws = aws.us_east_1
  }
  project_name = var.project_name
}

# CloudFront
module "cloudfront" {
  source = "./modules/cloudfront"

  web_acl_arn                    = module.waf.web_acl_arn
  s3_bucket_id                   = module.s3_static_website.bucket_id
  s3_bucket_arn                  = module.s3_static_website.bucket_arn
  s3_bucket_regional_domain_name = module.s3_static_website.bucket_regional_domain_name
  default_root_object            = var.website_index_document
  price_class                    = var.cloudfront_price_class
  project_name                   = var.project_name
  logging_bucket_domain_name     = module.s3_logging_bucket.bucket_domain_name

}

# Logging Bucket
module "s3_logging_bucket" {
  source = "./modules/s3-logging-bucket"
  project_name = var.project_name
}
# CloudWatch
module "cloudwatch" {
  source = "./modules/cloudwatch"
  project_name               = var.project_name
  cloudfront_distribution_id = module.cloudfront.distribution_id
  waf_web_acl_name           = module.waf.web_acl_name
}

# Upload Website Content
resource "aws_s3_object" "index_html" {
  bucket       = module.s3_static_website.bucket_id
  key          = "index.html"
  source       = "${path.module}/website/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/website/index.html")
}

# Upload the error.html file to S3
resource "aws_s3_object" "error_html" {
  bucket       = module.s3_static_website.bucket_id
  key          = "error.html"
  source       = "${path.module}/website/error.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/website/error.html")
}


# S3 Bucket Policy for CloudFront OAC
resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = module.s3_static_website.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.s3_static_website.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = module.cloudfront.distribution_arn
          }
        }
      }
    ]
  })
}
