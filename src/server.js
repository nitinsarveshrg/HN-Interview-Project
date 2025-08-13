import express from 'express';
import morgan from 'morgan';
import helmet from 'helmet';
import cors from 'cors';
import productsRouter from './transport/http/products.routes.js';

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan('combined'));

app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.use('/products', productsRouter);

app.use((req, res) => {
  res.status(404).json({ error: 'Not Found' });
});

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


