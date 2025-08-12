## AWS App Runner deployment (simple manual steps)

Prerequisites:
- AWS account and AWS CLI configured
- ECR public or private repo (optional; App Runner can build directly from GitHub)

Option A: Deploy from source (GitHub) via console
1. Push this repo to GitHub.
2. Open AWS App Runner → Create service → Source code repository.
3. Connect to your GitHub repo, select branch `main`.
4. Build settings:
   - Runtime: `Node.js 20`
   - Build command: `npm ci && npm run build`
   - Start command: `node dist/server.js`
5. Port: `3000`. Health check path: `/health`.
6. Create service. After deploy, test `https://<your-app>.awsapprunner.com/health`.

Option B: Deploy container image from ECR
1. Build and push image:
   ```bash
   export ECR_REPO=product-catalog-service
   aws ecr create-repository --repository-name $ECR_REPO || true
   aws ecr get-login-password | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$(aws configure get region).amazonaws.com
   docker build -t $ECR_REPO:latest .
   docker tag $ECR_REPO:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$(aws configure get region).amazonaws.com/$ECR_REPO:latest
   docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$(aws configure get region).amazonaws.com/$ECR_REPO:latest
   ```
2. Create App Runner service from ECR image in the console. Port `3000`, health `/health`.

Environment variables:
- `PORT` (default 3000)

Observability:
- Metrics exposed at `/metrics` in Prometheus format.
- Logs to stdout/stderr.


