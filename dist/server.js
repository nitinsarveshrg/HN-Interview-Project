import express from 'express';
import morgan from 'morgan';
import helmet from 'helmet';
import cors from 'cors';
import { register, collectDefaultMetrics, Histogram, Counter } from 'prom-client';
import productsRouter from './transport/http/products.routes.js';
const app = express();
// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
// Structured request logging
app.use(morgan('combined'));
// Metrics
collectDefaultMetrics();
const httpRequestDurationSeconds = new Histogram({
    name: 'http_request_duration_seconds',
    help: 'Duration of HTTP requests in seconds',
    labelNames: ['method', 'route', 'status_code'],
    buckets: [0.05, 0.1, 0.3, 0.5, 1, 2, 5]
});
const httpRequestsTotal = new Counter({
    name: 'http_requests_total',
    help: 'Total number of HTTP requests',
    labelNames: ['method', 'route', 'status_code']
});
app.use((req, res, next) => {
    const start = process.hrtime.bigint();
    res.on('finish', () => {
        const end = process.hrtime.bigint();
        const durationSeconds = Number(end - start) / 1e9;
        const route = (req.route && req.route.path) || req.path || 'unknown';
        const statusCode = res.statusCode.toString();
        httpRequestDurationSeconds
            .labels(req.method, route, statusCode)
            .observe(durationSeconds);
        httpRequestsTotal.labels(req.method, route, statusCode).inc();
    });
    next();
});
// Health
app.get('/health', (_req, res) => {
    res.status(200).json({ status: 'ok' });
});
// Metrics endpoint
app.get('/metrics', async (_req, res) => {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
});
// Routes
app.use('/products', productsRouter);
// Not found handler
app.use((req, res) => {
    res.status(404).json({ error: 'Not Found' });
});
// Error handler
// eslint-disable-next-line @typescript-eslint/no-unused-vars
app.use((err, _req, res, _next) => {
    console.error('Unhandled error', err);
    res.status(500).json({ error: 'Internal Server Error' });
});
const port = process.env.PORT ? Number(process.env.PORT) : 3000;
if (process.env.NODE_ENV !== 'test') {
    app.listen(port, () => {
        console.log(`Server listening on port ${port}`);
    });
}
export default app;
