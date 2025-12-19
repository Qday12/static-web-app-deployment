# Static Web App Deployment

AWS static website infrastructure with CloudFront, WAF, and monitoring.

## Structure

```
static-web-app-deployment/
├── modules/
│   ├── s3-static-website/    # S3 bucket for website content
│   ├── cloudfront/           # CloudFront distribution with OAC
│   ├── waf/                  # WAF with rate limiting
│   ├── s3-logging-bucket/    # S3 bucket for CloudFront access logs
│   └── cloudwatch/           # CloudWatch dashboard for monitoring
├── website/                  # HTML files (index.html, error.html)
├── .github/workflows/        # CI/CD pipeline
├── main.tf                   # Root module
├── variables.tf              # Input variables
├── outputs.tf                # Output values
├── versions.tf               # Terraform and provider versions
├── backend.tf                # Remote state configuration
└── terraform.tfvars          # Variable values (env-specific)
```

## Requirements

- Terraform >= 1.6.0
- AWS CLI configured with appropriate credentials

## Quick Start

1. Clone and configure
```bash
git clone https://github.com/Qday12/static-web-app-deployment
cd static-web-app-deployment
nvim terraform.tfvars
```

2. Initialize
```bash
terraform init
```

3. Review
```bash
terraform plan
```

4. Apply
```bash
terraform apply
```

5. Access website on URL provided by terraform output

## Error Pages

Custom error pages are served for HTTP errors. To test:

| Error Code    | How to Trigger 
|---------------|------------------------------------------
| 404           | Visit `https://<cloudfront-domain>/nonexistent-page`
| 403           | Access denied errors (blocked by WAF)
| 500, 502, 503 | Origin server errors

All errors display `/error.html`. To customize, edit `website/error.html`.

## Access Logs

CloudFront access logs are stored in an S3 bucket with automatic expiration.

Logs are retained for 30 days (configurable via `retention_days` variable).

## CloudWatch Dashboard

A CloudWatch dashboard is created with metrics for:
- Total CloudFront requests
- WAF blocked requests
- 4xx error rate
- 5xx error rate

## CI/CD Pipeline

The GitHub Actions workflow has three stages:

### Pipeline Stages

| Stage     | Trigger               | Description 
|-----------|-----------------------|------------------------------
| **init**  | Push to main, Manual  | Format check, validate, TFLint 
| **plan**  | After init            | Creates execution plan, uploads artifact 
| **apply** | Manual only           | Applies the plan from artifact 

### Running the Pipeline

**Automatic (push to main):**
- Runs `init` and `plan` stages only
- Plan artifact is saved for later apply

**Manual trigger (validate + plan only):**
1. Go to Actions > Terraform
2. Click "Run workflow"
3. Leave "Run apply at the end" unchecked
4. Click "Run workflow"

**Manual trigger (with apply):**
1. Go to Actions > Terraform
2. Click "Run workflow"
3. Check "Run apply at the end"
4. Click "Run workflow"

### Required Secrets

Configure these in GitHub repository settings:

| Secret               | Description 
|----------------------|----------------------------------------
| `AWS_PLAN_ROLE_ARN`  | IAM role ARN for terraform plan (read-only) |
| `AWS_APPLY_ROLE_ARN` | IAM role ARN for terraform apply (write) |

## Backend Configuration

### Bootstrap (one-time setup)

```bash
# Create S3 bucket for state
aws s3 mb s3://static-web-app-deployment-2115-state --region eu-central-1

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket static-web-app-deployment-2115-state \
    --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region eu-central-1
```

### Enable Remote State

Edit `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "static-web-app-deployment-2115-state"
    key            = "static-website/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

Then reinitialize:

```bash
terraform init -migrate-state
```

### How State Locking Works

1. Terraform acquires a lock in DynamoDB
2. Other engineers attempting changes see: "Error acquiring the state lock"
3. After completion, the lock is released
4. State is stored centrally in S3

## Destroy Resources

```bash
terraform destroy
```
