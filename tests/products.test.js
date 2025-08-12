import request from 'supertest';
import app from '../src/server.js';

describe('Products API', () => {
    it('health check works', async () => {
        const res = await request(app).get('/health');
        expect(res.status).toBe(200);
        expect(res.body.status).toBe('ok');
    });
    it('can create, list, get, update, delete a product', async () => {
        const createRes = await request(app)
            .post('/products')
            .send({ name: 'Phone', description: 'Smartphone', price: 499.99, category: 'Electronics' });
        expect(createRes.status).toBe(201);
        const product = createRes.body;
        const listRes = await request(app).get('/products');
        expect(listRes.status).toBe(200);
        expect(listRes.body.length).toBeGreaterThan(0);
        const getRes = await request(app).get(`/products/${product.id}`);
        expect(getRes.status).toBe(200);
        expect(getRes.body.name).toBe('Phone');
        const updateRes = await request(app).put(`/products/${product.id}`).send({ price: 599.99 });
        expect(updateRes.status).toBe(200);
        expect(updateRes.body.price).toBe(599.99);
        const deleteRes = await request(app).delete(`/products/${product.id}`);
        expect(deleteRes.status).toBe(204);
    });
});
