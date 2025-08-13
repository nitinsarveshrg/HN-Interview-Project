# HN Interview Project

A simple Node.js + Express product catalog microservice with CI/CD and Docker deployment to AWS.

## 🚀 Features

- **Product Catalog API**: CRUD operations for products
- **Health Check Endpoint**: `/health` for monitoring
- **Docker Containerization**: Ready for cloud deployment
- **CI/CD Pipeline**: GitHub Actions with automated testing and deployment
- **AWS Infrastructure**: ECS Fargate with Application Load Balancer
- **Infrastructure as Code**: Terraform configuration

## 🏗️ Architecture

- **Backend**: Node.js + Express
- **Container**: Docker with Node.js 20 Alpine
- **Orchestration**: AWS ECS Fargate
- **Load Balancer**: AWS Application Load Balancer
- **Registry**: AWS ECR
- **Infrastructure**: Terraform

## 📋 Prerequisites

- Node.js 18+
- Docker
- AWS CLI configured
- Terraform installed
- GitHub repository with secrets configured

## 🚀 Quick Start

### Local Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Run tests
npm test

# Build and start production
npm run build
npm start
```

### Docker

```bash
# Build image
docker build -t hn-interview-app .

# Run container
docker run -p 3000:3000 hn-interview-app

# Test health endpoint
curl http://localhost:3000/health
```

## 🚀 Deployment

### Option 1: Automated Deployment (Recommended)

The GitHub Actions workflow will automatically:
1. Run tests on every push
2. Build and push Docker image to ECR on main branch
3. Deploy infrastructure using Terraform

**Required GitHub Secrets:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

### Option 2: Manual Deployment

```bash
# Run the deployment script
./deploy/deploy.sh

# Or deploy step by step:
cd infra
terraform init
terraform plan
terraform apply
```

### Option 3: AWS App Runner (Alternative)

See [deploy/aws-apprunner/README.md](deploy/aws-apprunner/README.md) for App Runner deployment instructions.

## 🔧 Configuration

### Environment Variables

- `PORT`: Server port (default: 3000)
- `NODE_ENV`: Environment (production/development)

### AWS Configuration

- **Region**: us-east-1 (configurable in `infra/terraform.tfvars`)
- **ECS**: Fargate with 256 CPU units and 512MB memory
- **Load Balancer**: Application Load Balancer with HTTP on port 80

## 📊 API Endpoints

- `GET /health` - Health check
- `GET /products` - List all products
- `POST /products` - Create a product
- `GET /products/:id` - Get a specific product
- `PUT /products/:id` - Update a product
- `DELETE /products/:id` - Delete a product
- `GET /products/search?query=...` - Search products

## 🧪 Testing

```bash
# Run tests
npm test

# Run tests in watch mode
npm run test:watch
```

Tests include:
- Health check endpoint
- Product CRUD operations
- API validation

## 📁 Project Structure

```
├── src/                    # Source code
│   ├── server.js          # Express server
│   ├── services/          # Business logic
│   ├── repository/        # Data access layer
│   └── transport/         # HTTP routes
├── infra/                 # Terraform configuration
├── deploy/                # Deployment scripts
├── tests/                 # Test files
├── Dockerfile             # Docker configuration
└── .github/workflows/     # CI/CD pipeline
```

## 🔍 Monitoring

- **Health Check**: `/health` endpoint
- **Logs**: CloudWatch logs for each service
- **Metrics**: Prometheus format at `/metrics` (if configured)

## 🛠️ Troubleshooting

### Common Issues

1. **Docker build fails**: Ensure Node.js version compatibility
2. **Terraform apply fails**: Check AWS credentials and region
3. **ECS service not starting**: Verify ECR image exists and is accessible
4. **Load balancer not responding**: Check security groups and target group health

### Useful Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster multi-api-cluster --services hn-interview-app

# View ECS logs
aws logs tail /ecs/hn-interview-app --follow

# Check load balancer health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

## 📝 License

This project is for interview purposes.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request


