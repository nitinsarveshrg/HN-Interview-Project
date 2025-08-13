# GitHub Actions Setup Guide

This guide will help you set up the required secrets and permissions for the CI/CD pipeline to work with AWS.

## 🔐 Required GitHub Secrets

You need to add these secrets to your GitHub repository:

1. Go to your repository on GitHub
2. Click on **Settings** tab
3. Click on **Secrets and variables** → **Actions**
4. Click **New repository secret**

### AWS Credentials

#### `AWS_ACCESS_KEY_ID`
- **Description**: Your AWS access key ID
- **Value**: The access key ID from your AWS IAM user

#### `AWS_SECRET_ACCESS_KEY`
- **Description**: Your AWS secret access key
- **Value**: The secret access key from your AWS IAM user

## 🏗️ AWS IAM User Setup

Create an IAM user with the following permissions:

### 1. Create IAM User
```bash
aws iam create-user --user-name github-actions-deploy
```

### 2. Create Access Keys
```bash
aws iam create-access-key --user-name github-actions-deploy
```

### 3. Attach Required Policies

#### ECR Policy
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload"
            ],
            "Resource": "*"
        }
    ]
}
```

#### ECS Policy
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:DescribeServices",
                "ecs:DescribeTaskDefinition",
                "ecs:DescribeTasks",
                "ecs:ListTasks",
                "ecs:RegisterTaskDefinition",
                "ecs:UpdateService"
            ],
            "Resource": "*"
        }
    ]
}
```

#### IAM Policy
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "arn:aws:iam::*:role/ecs-task-exec"
        }
    ]
}
```

#### CloudWatch Logs Policy
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups"
            ],
            "Resource": "*"
        }
    ]
}
```

#### Load Balancer Policy
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeleteListener"
            ],
            "Resource": "*"
        }
    ]
}
```

#### VPC Policy
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeNetworkInterfaces"
            ],
            "Resource": "*"
        }
    ]
}
```

### 4. Attach Policies to User
```bash
# Create policy documents first, then attach them
aws iam put-user-policy --user-name github-actions-deploy --policy-name ECRPolicy --policy-document file://ecr-policy.json
aws iam put-user-policy --user-name github-actions-deploy --policy-name ECSPolicy --policy-document file://ecs-policy.json
# ... repeat for other policies
```

## 🔒 Alternative: Use IAM Role (Recommended for Production)

For production environments, consider using IAM roles with OIDC instead of access keys:

1. **Create OIDC Identity Provider** in AWS
2. **Create IAM Role** with trust relationship to GitHub
3. **Update GitHub Actions** to use `aws-actions/configure-aws-credentials@v4` with role-based authentication

## ✅ Verification

After setting up the secrets:

1. **Push to main branch** - This will trigger the deployment pipeline
2. **Check GitHub Actions** - Monitor the workflow execution
3. **Verify AWS Resources** - Check ECR, ECS, and Load Balancer in AWS Console

## 🚨 Security Notes

- **Never commit secrets** to your repository
- **Use least privilege** - Only grant necessary permissions
- **Rotate access keys** regularly
- **Consider using IAM roles** for production deployments
- **Monitor AWS CloudTrail** for suspicious activity

## 🆘 Troubleshooting

### Common Issues

1. **"Access Denied" errors**: Check IAM permissions
2. **ECR login fails**: Verify ECR permissions
3. **ECS service creation fails**: Check ECS and IAM permissions
4. **Load balancer creation fails**: Verify ELB permissions

### Debug Commands

```bash
# Test AWS credentials
aws sts get-caller-identity

# Test ECR access
aws ecr describe-repositories

# Test ECS access
aws ecs list-clusters
```
