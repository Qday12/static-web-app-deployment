# =============================================================================
# BACKEND CONFIGURATION
# =============================================================================
# This configuration prevents concurrent changes by:
# 1. Storing state in S3 (centralized location)
# 2. Using DynamoDB for state locking (prevents simultaneous modifications)
#
# IMPORTANT: You must create the S3 bucket and DynamoDB table BEFORE running
# terraform init. See README.md for bootstrap instructions.
# =============================================================================

# Uncomment this block after creating the backend resources
terraform {
  backend "s3" {
    bucket         = "static-web-app-deployment-2115-state" # Change this
    key            = "static-website/terraform.tfstate"
    region         = "eu-central-1" # Change this
    encrypt        = true
    dynamodb_table = "terraform-state-lock" # For state locking
  }
}
