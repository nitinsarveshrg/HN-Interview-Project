#!/bin/bash

# HN Interview Project Deployment Script
set -e

# Configuration
AWS_REGION=${AWS_REGION:-"us-east-1"}
ECR_REPOSITORY="hn-interview-app"
ECR_TAG=${ECR_TAG:-"latest"}

echo "🚀 Starting deployment to AWS..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "📦 Building Docker image..."
docker build -t ${ECR_REPOSITORY}:${ECR_TAG} .

echo "🔐 Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

echo "🏷️  Tagging image..."
docker tag ${ECR_REPOSITORY}:${ECR_TAG} ${ECR_REGISTRY}/${ECR_REPOSITORY}:${ECR_TAG}

echo "📤 Pushing image to ECR..."
docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${ECR_TAG}

echo "🏗️  Deploying infrastructure with Terraform..."
cd infra

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo "🔧 Initializing Terraform..."
    terraform init
fi

# Plan and apply
echo "📋 Planning Terraform changes..."
terraform plan -out=tfplan

echo "🚀 Applying Terraform changes..."
terraform apply tfplan

# Clean up plan file
rm -f tfplan

echo "✅ Deployment completed successfully!"
echo ""
echo "📊 Deployment Summary:"
echo "   ECR Repository: ${ECR_REGISTRY}/${ECR_REPOSITORY}"
echo "   Image Tag: ${ECR_TAG}"
echo "   Region: ${AWS_REGION}"
echo ""
echo "🔗 Application URLs:"
terraform output -raw application_url 2>/dev/null || echo "   Load Balancer: $(terraform output -raw load_balancer_dns 2>/dev/null || echo 'Not available')"
echo ""
echo "📝 To check the deployment status:"
echo "   aws ecs describe-services --cluster multi-api-cluster --services hn-interview-app --region ${AWS_REGION}"
echo ""
echo "🌐 To access the application:"
echo "   curl $(terraform output -raw application_url 2>/dev/null || echo 'http://$(terraform output -raw load_balancer_dns)/hn-interview-app')"
