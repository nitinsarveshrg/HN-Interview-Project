## Product Catalog Service (Node.js + Express, JavaScript/ESM)

A simple backend microservice exposing CRUD and search for products. Includes Dockerfile, CI workflow, health and metrics endpoints, and deployment notes for AWS App Runner. In-memory repository by default.


### API
- `GET /health` – healthcheck
- `GET /metrics` – Prometheus metrics
- `GET /products` – list products
- `GET /products/:id` – get a product
- `POST /products` – create product
  - body: `{ name: string, description: string, price: number, category: string }`
- `PUT /products/:id` – update product (partial allowed)
- `DELETE /products/:id` – delete product
- `GET /products/search?query=foo` – search by name or category

### Run locally
Prereq: Node.js 20+

```bash
npm install
npm run dev
# or
npm test
```

### Docker
```bash
docker build -t product-catalog-service:local .
docker run -p 3000:3000 product-catalog-service:local
```

### CI/CD
GitHub Actions at `.github/workflows/ci.yml` installs deps, runs tests, builds app and Docker image.

### Deploy to AWS App Runner
See `deploy/aws-apprunner/README.md` for console-based steps or ECR image deploy. Health: `/health`, port `3000`.

### Kubernetes (Bonus)
See `k8s/deployment.yaml`. Replace image with your registry path.

### Logging & Monitoring
- HTTP logs via `morgan` to stdout
- Prometheus metrics at `/metrics`

### Notes
- Storage is in-memory for simplicity. Swap with a DB by implementing `ProductRepository` to use SQLite/Postgres.


