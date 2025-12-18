# Structure
static-web-app-deployment/modules/*         # S3 and cloudFront terraform files
static-web-app-deployment/website/*         # html files
static-web-app-deployment/main.tf           # root module
static-web-app-deployment/variables.tf      # input variables
static-web-app-deployment/terraform.tfvars  # variables values (env-specific)
static-web-app-deployment/versions.tf       # terraform and provider version

static-web-app-deployment/backend.tf        # remote state and locking configuration

# Needs
- Terraform >= 1.6.0
- AWS CLI configured with appropriate credentials

# Start
1. clone and configure
```bash
git clone https://github.com/Qday12/static-web-app-deployment
cd static-web-app-deployment

nvim terraform.tfvars
```
2. Initialize
```bash
terraform init
```
3. review
```bash
terraform plan
```
4. apply
```bash
terraform apply
```
5. acces website on url provided by terraform apply

# Bootstrap the backend (one-time setup)
```bash
# Create S3 bucket for state
aws s3 mb s3://static-web-app-deployment-2115-state --region us-central-1

# Enable versioning on the bucket
aws s3api put-bucket-versioning \
    --bucket static-web-app-deployment-2115-state \
    --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region us-central-1
```
## Enable Remote State

Edit `backend.tf` and uncomment the backend block:

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

Then reinitialize Terraform:

```bash
terraform init -migrate-state
```

## How State Locking Works

When any engineer runs `terraform apply`:

1. Terraform acquires a lock in DynamoDB
2. Other engineers attempting changes see: "Error acquiring the state lock"
3. After completion, the lock is released
4. State is stored centrally in S3, ensuring everyone uses the latest version

# To destroy all resources
```bash
terraform destroy
```