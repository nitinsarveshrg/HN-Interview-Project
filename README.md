# HN Interview Project


## Features

- **Product Catalog API**: CRUD operations for products
- **Health Check Endpoint**: `/health` for monitoring
- **Docker Containerization**: Ready for cloud deployment
- **CI/CD Pipeline**: GitHub Actions with automated testing and deployment
- **AWS Infrastructure**: ECS Fargate with Application Load Balancer
- **Infrastructure as Code**: Terraform configuration


## Prerequisites

- Node.js 18+
- Docker
- AWS CLI configured
- Terraform installed
- GitHub repository with secrets configured

## Quick Start

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

## Deployment

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

## Configuration

### Environment Variables

- `PORT`: Server port (default: 3000)
- `NODE_ENV`: Environment (production/development)

### AWS Configuration

- **Region**: us-east-1 (configurable in `infra/terraform.tfvars`)
- **ECS**: Fargate with 256 CPU units and 512MB memory
- **Load Balancer**: Application Load Balancer with HTTP on port 80

## API Endpoints

- `GET /health` - Health check
- `GET /products` - List all products
- `POST /products` - Create a product
- `GET /products/:id` - Get a specific product
- `PUT /products/:id` - Update a product
- `DELETE /products/:id` - Delete a product
- `GET /products/search?query=...` - Search products

## Testing

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


