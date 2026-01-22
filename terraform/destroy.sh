#!/bin/bash

set -e

echo "🗑️  Destroying WanderAI Infrastructure"
echo "======================================"
echo ""

cd "$(dirname "$0")"

echo "⚠️  This will destroy all resources including:"
echo "  - Lambda functions"
echo "  - API Gateway"
echo "  - DynamoDB table (and all data)"
echo ""

read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Destroying infrastructure..."
terraform destroy -auto-approve

echo ""
echo "✅ Infrastructure destroyed"
echo ""

# Clean up frontend .env
if [ -f "../frontend/.env" ]; then
    echo "Removing frontend/.env..."
    rm "../frontend/.env"
fi

echo "✅ Cleanup complete"
