#!/bin/bash
set -e

# Configuration
REGION="us-east-1"
BUCKET_NAME="wander-ai-tf-state-$(aws sts get-caller-identity --query Account --output text)"
TABLE_NAME="wander-ai-tf-lock"

echo "🚀 Bootstrapping Terraform Remote State"
echo "Region: $REGION"
echo "Bucket: $BUCKET_NAME"
echo "Table:  $TABLE_NAME"
echo ""

# 1. Create S3 Bucket
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "✅ Bucket $BUCKET_NAME already exists."
else
    echo "Creating S3 Bucket..."
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
    
    # Enable Versioning
    aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
    echo "✅ Bucket created with versioning enabled."
fi

# 2. Create DynamoDB Table for Locking
if aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" >/dev/null 2>&1; then
    echo "✅ DynamoDB Table $TABLE_NAME already exists."
else
    echo "Creating DynamoDB Table..."
    aws dynamodb create-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "$REGION"
    echo "✅ DynamoDB Table created."
fi

echo ""
echo "🎉 Remote State Infrastructure Ready!"
echo "-----------------------------------"
echo "Update terraform/provider.tf with:"
echo ""
echo "backend \"s3\" {"
echo "  bucket         = \"$BUCKET_NAME\""
echo "  key            = \"terraform.tfstate\""
echo "  region         = \"$REGION\""
echo "  dynamodb_table = \"$TABLE_NAME\""
echo "  encrypt        = true"
echo "}"
echo ""
