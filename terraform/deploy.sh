#!/bin/bash

# WanderAI Local Deployment Script (Full Stack)
# Deploys Backend (Lambda/DynamoDB) + Frontend (S3/CloudFront) via Terraform

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🚀 WanderAI Full Stack Deployment${NC}"
echo "=================================="

# 1. Check for Prerequisites
# --------------------------
cd "$(dirname "$0")"

if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}⚠️  terraform.tfvars not found${NC}"
    # ... (existing logic to create tfvars from .env) ...
    if [ -f "../.env" ]; then
        source ../.env
    fi
    if [ -z "$OPENAI_API_KEY" ]; then
        echo -e "${RED}❌ Error: OPENAI_API_KEY not found in ../.env${NC}"
        exit 1
    fi
    cp terraform.tfvars.example terraform.tfvars
    # Cross-platform sed
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|sk-your-openai-api-key-here|$OPENAI_API_KEY|g" terraform.tfvars
    else
        sed -i "s|sk-your-openai-api-key-here|$OPENAI_API_KEY|g" terraform.tfvars
    fi
fi

# 2. Terraform Deploy
# -------------------
echo -e "${GREEN}📦 Terraform Init & Apply...${NC}"
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
rm -f tfplan

# 3. Get Outputs
# --------------
API_URL=$(terraform output -raw api_endpoint 2>/dev/null)
BUCKET_NAME=$(terraform output -raw frontend_bucket_name 2>/dev/null)
CLOUDFRONT_URL=$(terraform output -raw frontend_url 2>/dev/null)

if [ -z "$API_URL" ] || [ -z "$BUCKET_NAME" ]; then
   echo -e "${RED}❌ Error: Failed to retrieve Terraform outputs.${NC}"
   exit 1
fi

echo -e "${GREEN}✅ Infrastructure Deployed!${NC}"
echo "   API Endpoint: $API_URL"
echo "   S3 Bucket:    $BUCKET_NAME"
echo "   CloudFront:   $CLOUDFRONT_URL"
echo ""

# 4. Build & Deploy Frontend
# --------------------------
echo -e "${GREEN}🏗️  Building Frontend...${NC}"
cd ../frontend

# Update .env for build
echo "VITE_API_URL=$API_URL" > .env

npm install
npm run build

echo -e "${GREEN}📤 Syncing to S3...${NC}"
aws s3 sync dist "s3://$BUCKET_NAME" --delete

# 5. Invalidate CloudFront (Optional but recommended)
# ---------------------------------------------------
echo -e "${YELLOW}🔄 Invalidating CloudFront Cache...${NC}"
# Get distribution ID from state (hacky but effective for local scripts)
cd ../terraform
DIST_ID=$(terraform state show aws_cloudfront_distribution.frontend_distribution | grep id | head -1 | awk '{print $3}' | tr -d '"')

if [ -n "$DIST_ID" ]; then
    aws cloudfront create-invalidation --distribution-id "$DIST_ID" --paths "/*"
    echo -e "${GREEN}✅ Invalidation started.${NC}"
else
    echo -e "${YELLOW}⚠️  Could not find Distribution ID, skipping invalidation.${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Full Sack Deployment Complete!${NC}"
echo -e "   Frontend is live at: ${GREEN}$CLOUDFRONT_URL${NC}"
