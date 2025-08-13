# 🚀 Deployment Checklist

Use this checklist to ensure your HN Interview Project is successfully deployed to AWS.

## ✅ Pre-Deployment Checklist

### 1. Local Environment
- [ ] Node.js 18+ installed (or Docker available)
- [ ] Docker running and accessible
- [ ] AWS CLI configured with appropriate credentials
- [ ] Terraform installed (v1.5.0+)

### 2. AWS Configuration
- [ ] AWS account with appropriate permissions
- [ ] AWS CLI configured (`aws configure`)
- [ ] Default VPC exists in your region
- [ ] Sufficient AWS service limits (ECS, ECR, etc.)

### 3. GitHub Repository
- [ ] Repository pushed to GitHub
- [ ] GitHub Actions secrets configured:
  - [ ] `AWS_ACCESS_KEY_ID`
  - [ ] `AWS_SECRET_ACCESS_KEY`
- [ ] Repository has access to Actions

## 🚀 Deployment Options

### Option 1: Automated Deployment (Recommended)

1. **Push to main branch** - This triggers the CI/CD pipeline
2. **Monitor GitHub Actions** - Check the workflow execution
3. **Verify AWS resources** - Check ECR, ECS, and Load Balancer

### Option 2: Manual Deployment

1. **Run deployment script**:
   ```bash
   ./deploy/deploy.sh
   ```

2. **Or deploy step by step**:
   ```bash
   # Build and push Docker image
   docker build -t hn-interview-app .
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com
   docker tag hn-interview-app:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/hn-interview-app:latest
   docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/hn-interview-app:latest
   
   # Deploy infrastructure
   cd infra
   terraform init
   terraform plan
   terraform apply
   ```

## 🔍 Post-Deployment Verification

### 1. Check ECR Repository
```bash
aws ecr describe-repositories --repository-names hn-interview-app
```

### 2. Check ECS Cluster
```bash
aws ecs describe-clusters --clusters multi-api-cluster
```

### 3. Check ECS Service
```bash
aws ecs describe-services --cluster multi-api-cluster --services hn-interview-app
```

### 4. Check Load Balancer
```bash
aws elbv2 describe-load-balancers --names multi-api-alb
```

### 5. Test Application
```bash
# Get load balancer DNS
LB_DNS=$(aws elbv2 describe-load-balancers --names multi-api-alb --query 'LoadBalancers[0].DNSName' --output text)

# Test health endpoint
curl http://$LB_DNS/hn-interview-app/health

# Test products endpoint
curl http://$LB_DNS/hn-interview-app/products
```

## 🚨 Troubleshooting

### Common Issues and Solutions

#### 1. ECR Authentication Failed
```bash
# Re-authenticate with ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com
```

#### 2. ECS Service Not Starting
```bash
# Check service events
aws ecs describe-services --cluster multi-api-cluster --services hn-interview-app --query 'services[0].events'

# Check task definition
aws ecs describe-task-definition --task-definition hn-interview-app
```

#### 3. Load Balancer Not Responding
```bash
# Check target group health
aws elbv2 describe-target-health --target-group-arn $(aws elbv2 describe-target-groups --names hn-interview-app-tg --query 'TargetGroups[0].TargetGroupArn' --output text)

# Check security groups
aws ec2 describe-security-groups --group-ids $(aws elbv2 describe-load-balancers --names multi-api-alb --query 'LoadBalancers[0].SecurityGroups[0]' --output text)
```

#### 4. Terraform Apply Fails
```bash
# Check AWS credentials
aws sts get-caller-identity

# Check Terraform state
terraform show

# Destroy and recreate if needed
terraform destroy
terraform apply
```

## 📊 Monitoring and Logs

### 1. CloudWatch Logs
```bash
# View application logs
aws logs tail /ecs/hn-interview-app --follow
```

### 2. ECS Metrics
```bash
# Check service metrics
aws cloudwatch get-metric-statistics --namespace AWS/ECS --metric-name CPUUtilization --dimensions Name=ServiceName,Value=hn-interview-app Name=ClusterName,Value=multi-api-cluster --start-time $(date -d '1 hour ago' --iso-8601) --end-time $(date --iso-8601) --period 300 --statistics Average
```

### 3. Load Balancer Metrics
```bash
# Check ALB metrics
aws cloudwatch get-metric-statistics --namespace AWS/ApplicationELB --metric-name RequestCount --dimensions Name=LoadBalancer,Value=app/multi-api-alb/$(aws elbv2 describe-load-balancers --names multi-api-alb --query 'LoadBalancers[0].LoadBalancerArn' --output text | cut -d'/' -f3) --start-time $(date -d '1 hour ago' --iso-8601) --end-time $(date --iso-8601) --period 300 --statistics Sum
```

## 🧹 Cleanup

### 1. Destroy Infrastructure
```bash
cd infra
terraform destroy
```

### 2. Remove ECR Images
```bash
aws ecr batch-delete-image --repository-name hn-interview-app --image-ids imageTag=latest
```

### 3. Remove ECR Repository
```bash
aws ecr delete-repository --repository-name hn-interview-app --force
```

## 📞 Support

If you encounter issues:

1. **Check the logs** - Use the monitoring commands above
2. **Verify permissions** - Ensure IAM user has required policies
3. **Check service limits** - Verify AWS service quotas
4. **Review Terraform state** - Check for configuration issues

## 🎯 Success Criteria

Your deployment is successful when:

- [ ] ECR repository contains the Docker image
- [ ] ECS service is running with desired count = 1
- [ ] Load balancer is accessible
- [ ] Health endpoint returns `{"status":"ok"}`
- [ ] Products endpoint responds without errors
- [ ] Application is accessible via load balancer URL
