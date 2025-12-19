
# Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC for ${var.project_name} S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  comment             = "CloudFront distribution for ${var.project_name}"
  price_class         = var.price_class
  web_acl_id          = var.web_acl_arn

  # Wait for deployment to complete
  wait_for_deployment = true


  dynamic "logging_config" {
    for_each = var.logging_bucket_domain_name != null ? [1] : []
    content {
      bucket          = var.logging_bucket_domain_name
      prefix          = var.logging_prefix
      include_cookies = false
    }
  }

  # Origin Configuration
  origin {
    domain_name              = var.s3_bucket_regional_domain_name
    origin_id                = "S3-${var.s3_bucket_id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }

  # Default Cache Behavior
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.s3_bucket_id}"

    # Redirect HTTP to HTTPS
    viewer_protocol_policy = "redirect-to-https"

    compress = true

    min_ttl     = var.min_ttl
    default_ttl = var.default_ttl
    max_ttl     = var.max_ttl

    # Use the managed CachingOptimized policy for static content
    # This is recommended for S3 origins
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  # Custom Error Responses
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/error.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/error.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 500
    response_code         = 500
    response_page_path    = "/error.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 502
    response_code         = 502
    response_page_path    = "/error.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 503
    response_code         = 503
    response_page_path    = "/error.html"
    error_caching_min_ttl = 10
  }


  # Restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # SSL Certificate

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
